 #include "CXScheduler.h"
 #include "CXSchedulerDebug.h"
 #include "fixedPointUtils.h"
module CXSlaveSchedulerP{
  provides interface SplitControl;
  uses interface SplitControl as SubSplitControl;

  provides interface CXRequestQueue;
  uses interface CXRequestQueue as SubCXRQ;

  uses interface CXSchedulerPacket;
  uses interface CXNetworkPacket;

  uses interface Receive as ScheduleReceive;
} implementation {
  message_t msg_internal;
  message_t* schedMsg = &msg_internal;

  cx_schedule_t* sched;
  bool startDonePending = FALSE;
  
  enum { 
    S_OFF = 0x00,  
    S_SEARCH = 0x01,     //no schedule
    S_SYNCHED = 0x02,    //frame boundaries OK, got last schedule
    S_SOFT_SYNCH = 0x03, //frames are probably timed OK, but missed
                         //the last schedule.
  };

  enum{
    S_UNKNOWN = 0x00,
    S_INACTIVE = 0x01,
    S_ACTIVE = 0x02,
  };
  uint8_t slotState = S_UNKNOWN;


  uint8_t state = S_OFF;
  uint32_t lastSlotStart;
  uint32_t lastCycleStart;

  uint32_t nextSleep;
  uint32_t nextWakeup;

  uint32_t mySlot = INVALID_SLOT;

  uint8_t wakeupPending = 0;

  uint32_t slotNumber(uint32_t frame){
    if (frame < lastCycleStart){
      return INVALID_SLOT;
    }else{
      return (frame - lastCycleStart)/sched->slotLength;
    }
  }

  uint32_t slotStart(uint32_t sn){
    return lastCycleStart + (sn * sched->slotLength);
  }

  uint32_t frameOfSlot(uint32_t frame){
    return frame - slotStart(frame);
  }

  bool isOwned(uint32_t frame){
    return slotNumber(frame) == mySlot;
  }

  uint32_t myNextSlotStart(uint32_t frame){
    if (mySlot == INVALID_SLOT){
      return INVALID_FRAME;
    }else{
      uint32_t ss = slotStart(mySlot);
      if (ss < frame){
        return ss + sched->cycleLength;
      } else {
        return ss;
      }
    }
  }

  command uint32_t CXRequestQueue.nextFrame(bool isTX){
    uint32_t subNext = call SubCXRQ.nextFrame(isTX);
    if (isTX){
      if (state == S_SYNCHED){
        if (isOwned(slotNumber(subNext) )){
          return subNext;
        }else{
          return myNextSlotStart(subNext);
        }
        return INVALID_FRAME;
      } else {
        //not synched, so we won't permit any TX.
        return INVALID_FRAME;
      }
    }else{
      //if the sub-layer says next frame is during duty-cycled period,
      //then push it forward to just after the next wakeup.
      if (subNext >= nextSleep && subNext <= nextWakeup + 1){
        return nextWakeup + 1;
      }else{
        //this is for the case where we didn't sleep this slot. avoid
        //the conflict here if we can see it coming.
        if (subNext == nextWakeup){
          return nextWakeup + 1;
        } else {
          return subNext;
        }
      }
    }
  }

  command error_t CXRequestQueue.requestReceive(uint8_t layerCount, 
      uint32_t baseFrame, int32_t frameOffset, 
      bool useMicro, uint32_t microRef,
      uint32_t duration, 
      void* md, message_t* msg){
    if (msg == NULL){
      printf("sched.cxrq.rr null\r\n");
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
      FALSE, 0,
      duration,
      NULL, msg);
  }

  task void sleepToNextSlot(){
    if (wakeupPending){
      error_t error = call SubCXRQ.requestSleep(0,
        call SubCXRQ.nextFrame(FALSE),
        0);
      if (error != SUCCESS){
        printf("req slot sleep: %x\r\n", error);
      }
    } else {
      printf("Slot sleep requested, but no wakeup pending\r\n");
    }
  }

  event void SubCXRQ.receiveHandled(error_t error, 
      uint8_t layerCount,
      uint32_t atFrame, uint32_t reqFrame, 
      bool didReceive, 
      uint32_t microRef, uint32_t t32kRef,
      void* md, message_t* msg){

    if ((state == S_SOFT_SYNCH || state == S_SYNCHED) 
        && !didReceive 
        && slotState == S_UNKNOWN 
        && frameOfSlot(atFrame) > sched -> maxDepth){
      //We didn't receive anything, we had not yet ascertained that
      //this was an active slot, and according to the schedule, we
      //should have received something by this point if anything was
      //being transmitted.
      //We assume the slot is not in use and sleep until the next slot
      //start.
      slotState = S_INACTIVE;
      post sleepToNextSlot();
    }else{
      if (didReceive){
        slotState = S_ACTIVE;
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
        }
      }else{
        //did not receive
        if (state == S_SEARCH){
          //TODO: handle fail-safe logic here. We should sleep the
          //  radio for a while and try again later.
        }
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
      printf("Unexpected rxHandled\r\n");
    }
  }

  command error_t CXRequestQueue.requestSend(uint8_t layerCount, 
      uint32_t baseFrame, 
      int32_t frameOffset, 
      bool useMicro, uint32_t microRef, 
      nx_uint32_t* tsLoc,
      void* md, message_t* msg){
    if (sched == NULL || state != S_SYNCHED){
      return ERETRY;
    }

    call CXSchedulerPacket.setScheduleNumber(msg, 
      sched->sn);
    return call SubCXRQ.requestSend(layerCount + 1, baseFrame,
      frameOffset, useMicro, microRef, tsLoc, md, msg);
  }

  event void SubCXRQ.sendHandled(error_t error, 
      uint8_t layerCount,
      uint32_t atFrame, uint32_t reqFrame, 
      uint32_t microRef, uint32_t t32kRef,
      void* md, message_t* msg){
    if (layerCount){
      signal SubCXRQ.sendHandled(error, 
        layerCount - 1,
        atFrame, reqFrame,
        microRef, t32kRef, 
        md, msg);
    }else{
      //TODO: from this layer: was a CLAIM packet.
    }
  }

  task void reportSched(){
    printf("RX Sched: %p sn %u cl %lu sl %lu md %u na %u ts %lu",
      sched, 
      sched->sn,
      sched->cycleLength, 
      sched->slotLength, 
      sched->maxDepth,
      sched->numAssigned,
      sched->timestamp);
//    printf(" p %x %x %x %x %x %x", 
//      sched->padding0,
//      sched->padding1,
//      sched->padding2,
//      sched->padding3,
//      sched->padding4,
//      sched->padding5);
    printf("\r\n");
  }
  

  uint32_t lastTimestamp = 0;
  uint32_t lastCapture = 0;
  uint32_t lastOriginFrame = 0;
  int32_t cumulativeTpf = 0;

  #ifndef TPF_DECIMAL_PLACES 
  #define TPF_DECIMAL_PLACES 16
  #endif
  
  //alpha is also fixed point.
  #define FP_1 (1L << TPF_DECIMAL_PLACES)

  #ifndef SKEW_EWMA_ALPHA_INVERSE
  #define SKEW_EWMA_ALPHA_INVERSE 2
  #endif

  int32_t alpha = FP_1 / SKEW_EWMA_ALPHA_INVERSE;

  #ifndef TPF_DECIMAL_PLACES 
  #define TPF_DECIMAL_PLACES 16
  #endif

  #define sfpMult(a, b) fpMult(a, b, TPF_DECIMAL_PLACES)
  #define stoFP(a) toFP(a, TPF_DECIMAL_PLACES)
  #define stoInt(a) toInt(a, TPF_DECIMAL_PLACES)
  int32_t lastDelta;
  task void printResults(){
    printf_SCHED(" Cumulative TPF: 0x%lx last delta: %li\r\n", 
      cumulativeTpf, lastDelta);
    printf_SCHED("  @50 %li @51 %li @100 %li @200 %li @300 %li @320 %li @400 %li @500 %li @1000 %li\r\n",
      stoInt(cumulativeTpf*50),
      stoInt(cumulativeTpf*51),
      stoInt(cumulativeTpf*100),
      stoInt(cumulativeTpf*200),
      stoInt(cumulativeTpf*300),
      stoInt(cumulativeTpf*320),
      stoInt(cumulativeTpf*400),
      stoInt(cumulativeTpf*500),
      stoInt(cumulativeTpf*1000));
  }

  task void updateSkew(){
    if (lastTimestamp != 0 && lastCapture != 0 && lastOriginFrame != 0){
      int32_t remoteElapsed = sched->timestamp - lastTimestamp;
      int32_t localElapsed = 
        call CXNetworkPacket.getOriginFrameStart(schedMsg) -
        lastCapture;
      int32_t framesElapsed = 
        call CXNetworkPacket.getOriginFrameNumber(schedMsg) -
        lastOriginFrame;
      //positive = we are slow = require shift forward
      int32_t delta = remoteElapsed - localElapsed;
      //this is fixed point, TPF_DECIMAL_PLACES bits after decimal
      int32_t deltaFP = (delta << TPF_DECIMAL_PLACES);

      int32_t tpf = deltaFP / framesElapsed;

      //next EWMA step
      //n.b. we let TPF = 0 initially to keep things simple. In
      //general, we should be reasonably close to this. 
      cumulativeTpf = sfpMult(cumulativeTpf, (FP_1 - alpha)) 
        + sfpMult(tpf, alpha);
      lastDelta = delta;
    }
    lastTimestamp = sched -> timestamp;
    lastCapture = call CXNetworkPacket.getOriginFrameStart(schedMsg);
    lastOriginFrame = call CXNetworkPacket.getOriginFrameNumber(schedMsg);
    post printResults();
  }

  task void sleepToNextCycle(){
    error_t error = call SubCXRQ.requestSleep(0,
      lastCycleStart, 
      sched->slotLength*sched->activeSlots);
    if (error == SUCCESS){
      nextSleep = lastCycleStart 
        + sched->slotLength*sched->activeSlots;

      //TODO: apply skew correction
      error = call SubCXRQ.requestWakeup(0,
        lastCycleStart,
        sched->cycleLength);
      if (error != SUCCESS){
        printf("req cycle wakeup: %x\r\n",
          error);
      }else{
        wakeupPending++;
        nextWakeup = lastCycleStart + sched->cycleLength;
      }
    }else{
      printf("req cycle sleep: %x\r\n",
       error);
    }
  }

  task void wakeupNextSlot(){
    //TODO: apply skew correction
    error_t error = call SubCXRQ.requestWakeup(0,
      lastCycleStart,
      sched->slotLength*(slotNumber(lastSlotStart)+1));
    if (error != SUCCESS){
      printf("req slot wakeup: %x\r\n",
        error);
    }else{
      wakeupPending ++; 
      nextWakeup = lastCycleStart +
        sched->slotLength*(slotNumber(lastSlotStart)+1);
    }
  }


  event message_t* ScheduleReceive.receive(message_t* msg, 
      void* payload, uint8_t len ){
    message_t* ret = schedMsg;
    sched = (cx_schedule_t*)payload;
    schedMsg = msg;
    state = S_SYNCHED;

    //frames-from-start = Master OFN - master start 
    //slave OFN - frames-from-start = slave start
    lastCycleStart = 
      call CXNetworkPacket.getOriginFrameNumber(msg) -
      (call CXSchedulerPacket.getOriginFrame(msg) 
       - sched->cycleStartFrame);
    lastSlotStart = lastCycleStart;
    
    if (!wakeupPending){
      post wakeupNextSlot();
    }

    post reportSched();
    #if CX_ENABLE_SKEW_CORRECTION == 1
    post updateSkew();
    #else
    #warning "CX skew correction disabled"
    #endif
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
      //TODO: update state
//      printf("sleep %x @%lu\r\n", error, atFrame);
    }
  }

  command error_t CXRequestQueue.requestWakeup(uint8_t layerCount, uint32_t baseFrame, 
      int32_t frameOffset){
    //TODO: request frame-shift prior to wake up to restore synch to root
    //schedule. 
    //TODO: internal calls should also be routed through this step.
    return call SubCXRQ.requestWakeup(layerCount + 1, baseFrame, frameOffset);
  }

  event void SubCXRQ.wakeupHandled(error_t error, 
      uint8_t layerCount,
      uint32_t atFrame, uint32_t reqFrame){
    if (layerCount){
//      printf("wh up\r\n");
      signal CXRequestQueue.wakeupHandled(error, layerCount - 1, atFrame, reqFrame);
    }else {
      if (startDonePending == TRUE){
        startDonePending = FALSE;
        signal SplitControl.startDone(error);
      }else{
        if (wakeupPending){
          wakeupPending --;
        }else{
          printf("Unexpected wakeup\r\n");
        }
      }

//      printf("wakeup %x @%lu\r\n", error, atFrame);
      lastSlotStart = atFrame;
      slotState = S_UNKNOWN;
      if (state == S_SYNCHED || state == S_SOFT_SYNCH){
        //If we're synched or soft-synched...
        uint32_t sn = slotNumber(atFrame);
        if (sn == sched->activeSlots){
          //this is last active slot: sleep at end of this slot,
          //wakeup at start of next cycle
          post sleepToNextCycle();
        } else if (sn < (sched->activeSlots - 1) ){
          //prior to last active slot: next slot
          post wakeupNextSlot();
        } else {
          //woke up some time during the inactive period, shouldn't
          //  happen.
          printf("Unexpected wakeup %lu slot %lu\r\n", 
            atFrame, sn);
        }
      }
    }
  }

  command error_t CXRequestQueue.requestFrameShift(uint8_t layerCount, 
      uint32_t baseFrame, int32_t frameOffset, int32_t frameShift){
    return call SubCXRQ.requestFrameShift(layerCount + 1, 
      baseFrame, frameOffset, frameShift);
  }

  event void SubCXRQ.frameShiftHandled(error_t error, 
      uint8_t layerCount, 
      uint32_t atFrame, uint32_t reqFrame){
    if (layerCount){
      signal CXRequestQueue.frameShiftHandled(error, 
        layerCount - 1, 
        atFrame, reqFrame);
    }else{
      //TODO: update state
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
      error = call SubCXRQ.requestWakeup(0, 
        call SubCXRQ.nextFrame(FALSE), 2);

    }
    if (error == SUCCESS){
      startDonePending = TRUE;
      state = S_SEARCH;
    }
  }
}
