 #include "CXScheduler.h"
 #include "CXSchedulerDebug.h"
 #include "fixedPointUtils.h"
 #include "CXLink.h"
 #include "CXNetwork.h"
module CXSlaveSchedulerP{
  provides interface SplitControl;
  uses interface SplitControl as SubSplitControl;

  provides interface CXRequestQueue;
  uses interface CXRequestQueue as SubCXRQ;

  uses interface Receive as ScheduleReceive;
  uses interface Receive as AssignmentReceive;
  uses interface SkewCorrection;
  uses interface ScheduleParams;
  uses interface CXSchedulerPacket;
  uses interface CXNetworkPacket;
  uses interface CXLinkPacket;
  uses interface SlotNotify;
  uses interface Packet;
  uses interface RoutingTable;

  uses interface ScheduledAMSend as RequestSend;
  uses interface Random;
  uses interface ActiveMessageAddress;
} implementation {
  message_t msg_internal;
  message_t* schedMsg = &msg_internal;

  message_t requestMsg_internal;
  message_t* requestMsg = &requestMsg_internal;

  cx_schedule_t* sched;
  bool startDonePending = FALSE;
  
  //were we synchronized at the time that the last schedule was
  //received?
  bool synchReceived;
  bool scheduleReceived = FALSE;
  uint8_t missedCount = 0;
  am_addr_t masterId;


  
  enum { 
    S_OFF = 0x00,  
    S_SEARCH = 0x01,     //no schedule
    S_SYNCHED = 0x02,    //frame boundaries OK, got last schedule
    S_SOFT_SYNCH = 0x03, //frames are probably timed OK, but missed
                         //the last schedule.
  };

  uint8_t state = S_OFF;
  uint32_t lastCycleStart;
  
  uint16_t mySlot = INVALID_SLOT;
 

  enum {
    RS_UNASSIGNED = 0,
    RS_REQUEST_QUEUED = 1,
    RS_ASSIGN_WAIT = 2,
    RS_ASSIGNED = 3,
  };

  uint8_t requestState = RS_UNASSIGNED;

  uint8_t requestedIndex = 0;

  command uint32_t CXRequestQueue.nextFrame(bool isTX){
    uint32_t subNext = call SubCXRQ.nextFrame(isTX);
    if (subNext == INVALID_FRAME){
      return INVALID_FRAME;
    }
    if (isTX){
      if (state == S_SYNCHED){
        //we're synched, so we rely on the slot scheduler to figure
        //out when our next slot is.
        return subNext;
      } else {
        //not synched, so we won't permit any TX.
        return INVALID_FRAME;
      }
    }else{
      if (lastCycleStart != INVALID_FRAME && sched != NULL){
        //we have a schedule, so we can figure out when our sleep/wake
        //period is. cycleWake is the next wakeup, cycleSleep
        //is the immediately-preceding sleep.
        uint32_t cycleWake = lastCycleStart;
        uint32_t cycleSleep;
        while (cycleWake < subNext){
          cycleWake += sched->cycleLength;
        }
        cycleSleep = cycleWake 
          - (sched->cycleLength) 
          + (sched->slotLength)*(sched->activeSlots)
          + 1;
        
        //if subnext is during the sleep period, push it back to
        //1+wake
        if (subNext >= cycleSleep && subNext <= cycleWake){
          return cycleWake + 1;
        }else{
        //otherwise, it's good to go
          return subNext;
        }
      }else{
        //if we don't have a schedule, use result from below.
        return subNext;
      }
    }
  }

  command error_t CXRequestQueue.requestReceive(uint8_t layerCount, 
      uint32_t baseFrame, int32_t frameOffset, 
      bool useMicro, uint32_t microRef,
      uint32_t duration, 
      void* md, message_t* msg){
    if (msg == NULL){
      cwarn(SCHED, "sched.cxrq.rr null\r\n");
      return EINVAL;
    }
    if(duration == 0){
      switch(state){
        case S_SYNCHED:
          duration = RX_DEFAULT_WAIT;
          break;
        case S_SOFT_SYNCH:
          duration = RX_DEFAULT_WAIT*2;
          break;
        case S_SEARCH:
          duration = RX_MAX_WAIT;
          break;
      }
    }
    return call SubCXRQ.requestReceive(layerCount + 1,
      baseFrame, frameOffset, 
      useMicro, microRef,
      duration,
      NULL, msg);
  }

  event void SubCXRQ.receiveHandled(error_t error, 
      uint8_t layerCount,
      uint32_t atFrame, uint32_t reqFrame, 
      bool didReceive, 
      uint32_t microRef, uint32_t t32kRef,
      void* md, message_t* msg){
    if (didReceive){
      //frame timing acquired
      if (state == S_SEARCH){
        state = S_SOFT_SYNCH;
      }
      if (state == S_SOFT_SYNCH 
          && sched != NULL 
          && sched->sn == call CXSchedulerPacket.getScheduleNumber(msg)){
        state = S_SYNCHED;
        //bring forward lastCycleStart if needed
        while (atFrame > (lastCycleStart + sched->cycleLength)){
          lastCycleStart += sched->cycleLength;
        }
        call ScheduleParams.setCycleStart(lastCycleStart);
      }
    }else{
      //did not receive
      if (state == S_SEARCH){
        //TODO: handle fail-safe logic here. We should sleep the
        //  radio for a while and try again later.
      }else if (state == S_SOFT_SYNCH){
        //TODO: fail-safe logic: after N soft-synch RX's with no data,
        //go to search.
      }
    }
    //regardless of above logic, pass through handled events
    if (layerCount){
      signal CXRequestQueue.receiveHandled(error,
        layerCount - 1, 
        atFrame, reqFrame, didReceive, microRef, t32kRef,
        md, msg);
    }else{
      //there shouldn't be any RX requests originating at this layer.
      cerror(SCHED, "Unexpected rxHandled\r\n");
    }
  }

  command error_t CXRequestQueue.requestSend(uint8_t layerCount, 
      uint32_t baseFrame, int32_t frameOffset, 
      tx_priority_t txPriority,
      bool useMicro, uint32_t microRef, 
      void* md, message_t* msg){
    if (sched == NULL || state != S_SYNCHED){
      //ERETRY: reserved to mean "this transport protocol is already
      //busy and will eventually return a sendDone"
      return EOFF;
    }

    call CXSchedulerPacket.setScheduleNumber(msg, 
      sched->sn);
    call CXNetworkPacket.setTTL(msg, sched->maxDepth);
    call CXSchedulerPacket.setOriginFrame(msg, 
      baseFrame + frameOffset - lastCycleStart);
    return call SubCXRQ.requestSend(layerCount + 1, baseFrame,
      frameOffset, txPriority, useMicro, microRef, md, msg);
  }

  event void SubCXRQ.sendHandled(error_t error, 
      uint8_t layerCount,
      uint32_t atFrame, uint32_t reqFrame, 
      uint32_t microRef, uint32_t t32kRef,
      void* md, message_t* msg){
    if (layerCount){
      if (error == SUCCESS && state != S_SYNCHED){
        //we were not synched, so it might have been sent
        //off-schedule.
        error = ERETRY;
      }
      signal CXRequestQueue.sendHandled(error, 
        layerCount - 1,
        atFrame, reqFrame,
        microRef, t32kRef, 
        md, msg);
    }
  }

  task void reportSched(){
    cinfo(SCHED, "SCHED RX %u %u %lu %lu\r\n",
      sched->sn,
      call CXNetworkPacket.getSn(schedMsg),
      sched->cycleStartFrame,
      lastCycleStart);
//    cinfo(SCHED, ": %p %p sn %u cl %lu sl %u md %u ts %lu",
//      schedMsg,
//      sched, 
//      sched->sn,
//      sched->cycleLength, 
//      sched->slotLength, 
//      sched->maxDepth,
//      sched->timestamp);
//    cinfo(SCHED, "\r\n");
  }

  
  task void updateSkew(){
    error_t error = call SkewCorrection.addMeasurement(
      call CXLinkPacket.getSource(schedMsg),
      synchReceived,
      sched->timestamp,
      call CXNetworkPacket.getOriginFrameNumber(schedMsg),
      call CXNetworkPacket.getOriginFrameStart(schedMsg));
    if (SUCCESS != error){
      cwarn(SKEW, "sc.am: %lu %lu %lu\r\n",
        sched->timestamp,
      call CXNetworkPacket.getOriginFrameNumber(schedMsg),
      call CXNetworkPacket.getOriginFrameStart(schedMsg));
    }
  }

  task void claimSlotTask(){
    if (requestedIndex < MAX_VACANT){
      uint8_t ssi; 
      uint16_t slotNum; 
      cx_schedule_request_t* req = call RequestSend.getPayload(requestMsg,
        sizeof(cx_schedule_request_t));
      error_t error;
      uint8_t rand_i =call Random.rand16();
      cdbg(SCHED, "CST ri %u nv %u rand %u", 
        requestedIndex,
        sched->numVacant,
        rand_i);
      ssi = (rand_i)% (sched->numVacant - requestedIndex); 
      slotNum = sched->vacantSlots[ssi + requestedIndex];
      cdbg(SCHED, " -> %u -> %u: %u\r\n", 
        ssi, 
        ssi+requestedIndex,
        slotNum);
      call Packet.clear(requestMsg);
      //TODO: FUTURE allow nodes to request more than one slot.
      req->slotsRequested = 1;
      //So this will actually get handled as an RRBurst, but should be
      //marked as DATA and will therefore just get signalled right up to
      //master.
      if (slotNum != INVALID_SLOT){
        error = call RequestSend.send(masterId, requestMsg,
          sizeof(cx_schedule_request_t),
          lastCycleStart + (slotNum*sched->slotLength) + 1);
        if (error == SUCCESS){
          requestState = RS_REQUEST_QUEUED;
          //have to add 2 here so that:
          // - we can't re-select the same slot.
          // - we can't select a slot that has just started.
          requestedIndex += (ssi + 2);
        }else {
          requestState = RS_UNASSIGNED;
        }
        cinfo(SCHED, "csr %u %x\r\n", slotNum, error);
      }else{
        cdbg(SCHED, "slot inval, don't request\r\n");
        requestState = RS_UNASSIGNED;
      }
    }else{
      cinfo(SCHED, "not assigned to last vacant, skip\r\n");
    }
  }

  event message_t* ScheduleReceive.receive(message_t* msg, 
      void* payload, uint8_t len ){
    message_t* ret = schedMsg;
    cx_schedule_t* newSched = (cx_schedule_t*)payload;
    synchReceived = (state == S_SYNCHED);
    if (!synchReceived){
      cinfo(SCHED, "Synch gained\r\n");
    }

    //check to see if your slot has been freed.
    if (sched->sn != newSched->sn){
      uint8_t i;
      if (requestState == RS_ASSIGNED && mySlot != INVALID_SLOT){
        for (i=0; i < MAX_FREED; i++){
          if (mySlot == newSched->freedSlots[i]){
            requestState = RS_UNASSIGNED;
            mySlot = INVALID_SLOT;
          }
        }
        for (i=0; i < newSched->numVacant; i++){
          if (mySlot == newSched->vacantSlots[i]){
            requestState = RS_UNASSIGNED;
            mySlot = INVALID_SLOT;
          }
        }
      }
        
    }
    sched = newSched;
    schedMsg = msg;
    state = S_SYNCHED;
    scheduleReceived = TRUE;

    //frames-from-start = Master OFN - master start 
    //slave OFN - frames-from-start = slave start
    lastCycleStart = 
      call CXNetworkPacket.getOriginFrameNumber(msg) -
      call CXSchedulerPacket.getOriginFrame(msg);
    cdbg(SCHED, "LO %lu RO %lu RCSF %lu\r\n",
      call CXNetworkPacket.getOriginFrameNumber(msg),
      call CXSchedulerPacket.getOriginFrame(msg),
      sched->cycleStartFrame);

    call ScheduleParams.setSchedule(sched);
    call ScheduleParams.setCycleStart(lastCycleStart);
    masterId = call CXLinkPacket.getSource(msg);
    call ScheduleParams.setMasterId(masterId);

    call RoutingTable.setDefault(sched->maxDepth);

    post reportSched();
    if (requestState == RS_UNASSIGNED){
      //reset pointer in vacancy list
      requestedIndex = 0;
      post claimSlotTask();
    }
    post updateSkew();
    return ret;
  }

  command error_t CXRequestQueue.requestSleep(uint8_t layerCount, uint32_t baseFrame, 
      int32_t frameOffset){
    return call SubCXRQ.requestSleep(layerCount + 1, baseFrame, frameOffset);
  }

  event void SubCXRQ.sleepHandled(error_t error, uint8_t layerCount, uint32_t atFrame, 
      uint32_t reqFrame){
    if (layerCount){
      signal CXRequestQueue.sleepHandled(error, layerCount - 1, atFrame, reqFrame);
    }else{
    }
  }

  command error_t CXRequestQueue.requestWakeup(uint8_t layerCount, uint32_t baseFrame, 
      int32_t frameOffset, uint32_t refFrame, uint32_t refTime, int32_t correction){
    //probably won't have any calls to this coming in from above
    return call SubCXRQ.requestWakeup(layerCount + 1, baseFrame,
    frameOffset, refFrame, refTime, correction);
  }

  event void SubCXRQ.wakeupHandled(error_t error, 
      uint8_t layerCount,
      uint32_t atFrame, uint32_t reqFrame){
    if (layerCount){
      cdbg(SCHED, "wh up\r\n");
      signal CXRequestQueue.wakeupHandled(error, layerCount - 1, atFrame, reqFrame);
    }else {
      signal SlotNotify.slotStarted(0);
      if (startDonePending){
        startDonePending = FALSE;
        signal SplitControl.startDone(SUCCESS);
      } else {
        state = S_SOFT_SYNCH;
        //at this layer: wakeup is at start of cycle. This command not
        //only informs the SlotScheduler of the cycle start, but also
        //causes it to start slot-cycling.
        call ScheduleParams.setCycleStart(atFrame);
      }
    }
  }

  task void sleepToNextCycle(){
    error_t error;
    error = call SubCXRQ.requestSleep(0,
      lastCycleStart, 
      sched->slotLength*(sched->activeSlots) + 1);
    cdbg(SCHED, "stnc sleep lcs %lu %lu-%lu\r\n", 
      lastCycleStart,
      lastCycleStart + (sched->activeSlots)*sched->slotLength +1,
      lastCycleStart + sched->cycleLength);
    if (error == SUCCESS) {
      error = call SubCXRQ.requestWakeup(0,
        lastCycleStart,
        sched->cycleLength,
        call SkewCorrection.referenceFrame(masterId),
        call SkewCorrection.referenceTime(masterId),
        call SkewCorrection.getCorrection(masterId,
          sched->cycleLength));
      cdbg(SCHED, "req cw: %x\r\n",
        error);
    }else{
      cerror(SCHED, "req cycle sleep: %x\r\n",
       error);
    }
  }
  
  event void SlotNotify.lastSlot(){
    if (!scheduleReceived){
      missedCount++;
      cinfo(SCHED, "Missed %u\r\n", missedCount);
      lastCycleStart += sched->cycleLength;
      call ScheduleParams.setCycleStart(lastCycleStart);
    }else{
      scheduleReceived = FALSE;
      missedCount = 0;
    }
    if (missedCount < SCHEDULE_LOSS_THRESHOLD){
      post sleepToNextCycle();
    }else{
      //this should force the next RX to use MAX_WAIT.
      state = S_SEARCH;
      cinfo(SCHED, "synch lost\r\n");
    }
  }

  command error_t SplitControl.start(){
    return call SubSplitControl.start();
  }

  command error_t SplitControl.stop(){
    return call SubSplitControl.stop();
  }
  event void SubSplitControl.stopDone(error_t error){
    if (error == SUCCESS){
      state = S_OFF;
    }
    signal SplitControl.stopDone(error);
  }

  event void SubSplitControl.startDone(error_t error){
    if (error == SUCCESS){
      //TODO: why 2?
      error = call SubCXRQ.requestWakeup(0, 
        call SubCXRQ.nextFrame(FALSE), 2,
        INVALID_FRAME, INVALID_TIMESTAMP, 0);

    }
    if (error == SUCCESS){
      startDonePending = TRUE;
      state = S_SEARCH;
    }
  }

  event void RequestSend.sendDone(message_t* msg, error_t error){
    cdbg(SCHED, "rs.sd %x\r\n", error);
    if (error == SUCCESS){
      requestState = RS_ASSIGN_WAIT;
    }else {
      requestState = RS_UNASSIGNED;
    }
  }
  
  event void SlotNotify.slotStarted(uint16_t sn){
    cdbg(SCHED, "SN.SS %x \r\n", requestState);
    if (requestState == RS_ASSIGN_WAIT){
      requestState = RS_UNASSIGNED;
      cinfo(SCHED, "Requested, not assigned\r\n");
      post claimSlotTask();
    }
  }

  event message_t* AssignmentReceive.receive(message_t* msg, 
      void* payload, uint8_t len){
    cdbg(SCHED, "RX Ass\r\n");
    //TODO: move to task?
    if (requestState == RS_ASSIGN_WAIT){
      cx_assignment_msg_t* pl = (cx_assignment_msg_t*)payload;
      uint8_t i;
      cdbg(SCHED, "%u ass'd\r\n", pl->numAssigned);
      for (i = 0; i < pl->numAssigned; i++){
        cdbg(SCHED, "a %u to %x\r\n",
          pl->assignments[i].slotNumber,
          pl->assignments[i].owner);
        if (pl->assignments[i].owner == call ActiveMessageAddress.amAddress()){
          mySlot = pl->assignments[i].slotNumber;
          cinfo(SCHED, "A me to %u\r\n", mySlot);
          call ScheduleParams.setSlot(mySlot);
          requestState = RS_ASSIGNED;
        }
      }
    }else{
      cdbg(SCHED, "Ignore ass\r\n");
    }
    return msg;
  }

  async event void ActiveMessageAddress.changed(){ }
}
