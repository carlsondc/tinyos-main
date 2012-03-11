
#include "CXTDMA.h"

module CXTDMAPhysicalP {
  provides interface SplitControl;
  provides interface Receive;
  provides interface CXTDMA;

  uses interface HplMsp430Rf1aIf;
  uses interface Resource;
  uses interface Rf1aPhysical;
  uses interface Rf1aPhysicalMetadata;
  uses interface Rf1aStatus;

  uses interface Rf1aPacket;

  uses interface Alarm<TMicro, uint32_t> as PrepareFrameStartAlarm;
  uses interface Alarm<TMicro, uint32_t> as FrameStartAlarm;
  //TODO: frame start capture
} implementation {
  enum{
    ERROR_MASK = 0x80,
    S_ERROR = 0x81,
    S_ERROR_2 = 0x82,
    S_ERROR_3 = 0x83,
    S_ERROR_4 = 0x84,
    S_ERROR_5 = 0x85,
    S_ERROR_6 = 0x86,
    S_ERROR_7 = 0x87,
    S_ERROR_8 = 0x88,
    S_ERROR_9 = 0x89,
    S_ERROR_a = 0x8a,
    S_ERROR_b = 0x8b,
    S_ERROR_c = 0x8c,
    S_ERROR_d = 0x8d,
    S_ERROR_e = 0x8e,
    S_ERROR_f = 0x8f,

    S_OFF = 0x00,
    S_STARTING = 0x01,
    S_INACTIVE = 0x02,
    S_IDLE = 0x03,

    S_RX_STARTING = 0x10,
    S_RX_READY = 0x11,
    S_RECEIVING = 0x12,
    S_RX_CLEANUP = 0x13,

    S_TX_STARTING = 0x20,
    S_TX_READY = 0x21,
    S_TRANSMITTING = 0x22,
    S_TX_CLEANUP = 0x23,
  };

  uint8_t state = S_OFF;

  uint16_t frameNum;
  uint32_t s_frameStart;
  uint32_t s_frameLen;
  uint16_t s_numFrames;
  uint32_t s_fwCheckLen;

  message_t rx_msg_internal;
  message_t* rx_msg = &rx_msg_internal;

  const char* decodeStatus(){
    switch(call Rf1aStatus.get()){
      case RF1A_S_IDLE:
        return "S_IDLE";
      case RF1A_S_RX:
        return "S_RX";
      case RF1A_S_TX:
        return "S_TX";
      case RF1A_S_FSTXON:
        return "S_FSTXON";
      case RF1A_S_CALIBRATE:
        return "S_CALIBRATE";
      case RF1A_S_FIFOMASK:
        return "S_FIFOMASK";
      case RF1A_S_SETTLING:
        return "S_SETTLING";
      case RF1A_S_RXFIFO_OVERFLOW:
        return "S_RXFIFO_OVERFLOW";
      case RF1A_S_TXFIFO_UNDERFLOW:
        return "S_TXFIFO_UNDERFLOW";
      case RF1A_S_OFFLINE:
        return "S_OFFLINE";
      default:
        return "???";
    }
  }

  void printStatus(){
    printf("* Core: %s\n\r", decodeStatus());
    printf("--------\n\r");
  }

  task void printStatusTask(){
    printStatus();
  }

  bool checkState(uint8_t s){ atomic return (state == s); }
  void setState(uint8_t s){
    atomic {
      #ifdef DEBUG_CX_TDMA_P_STATE
      printf("[%x->%x]\n\r", state, s);
      #endif
      #ifdef DEBUG_CX_TDMA_P_STATE_ERROR
      if (ERROR_MASK == (s & ERROR_MASK)){
        P2OUT |= BIT4;
        printf("[%x->%x]\n\r", state, s);
      }
      #endif
      state = s;
    }
  }


  /**
   *  S_OFF: off/not duty cycled
   *    SplitControl.start / resource.request -> S_STARTING
   *  Other: EALREADY
  */ 
  command error_t SplitControl.start(){
    if (checkState(S_OFF)){
      setState(S_STARTING);
      printStatus();
      return call Resource.request();
    } else {
      return EALREADY;
    }
  }

  /**
   *  S_STARTING: radio core starting up/calibrating
   *   resource.granted / start timers  -> S_IDLE
   */
  event void Resource.granted(){
    if (checkState(S_STARTING)){
      setState(S_IDLE);
      printStatus();
      atomic {
        frameNum = 0;
      }

      //If no schedule provided, provide some defaults which will
      //  basically keep us waiting until something shows up that we
      //  can synch on.
      if (s_frameStart == 0){
        s_frameStart = (call PrepareFrameStartAlarm.getNow() +
          PFS_SLACK);
        s_frameLen = DEFAULT_TDMA_FRAME_LEN;
        s_fwCheckLen = DEFAULT_TDMA_FW_CHECK_LEN;
        s_numFrames = DEFAULT_TDMA_NUM_FRAMES;
      }
      
      call PrepareFrameStartAlarm.startAt(s_frameStart - PFS_SLACK,
        s_frameLen);
      call FrameStartAlarm.startAt(s_frameStart, s_frameLen - SFD_TIME);

      signal SplitControl.startDone(SUCCESS);
    }
  }

  /**
   *  S_IDLE: in the part of a frame where no data is expected.
   *    PFS.fired + !isTX / setReceiveBuffer + startReception 
   *      -> S_RX_READY
   *    PFS.fired + isTX  / startTransmit(FSTXON) -> S_TX_READY
   */
  async event void PrepareFrameStartAlarm.fired(){
    error_t error;
    if (checkState(S_IDLE)){
      if (signal CXTDMA.isTXFrame(frameNum + 1)){
        error = call Rf1aPhysical.startSend(FALSE, signal
          CXTDMA.isTXFrame(frameNum + 2));
        if (SUCCESS == error){
          setState(S_TX_READY);
        } else {
          setState(S_ERROR);
        }
      } else {
        error = call Rf1aPhysical.setReceiveBuffer(
          (uint8_t*)(rx_msg->header),
          TOSH_DATA_LENGTH + sizeof(message_header_t),
          signal CXTDMA.isTXFrame(frameNum+2));
        if (SUCCESS == error){
          setState(S_RX_READY);
        } else {
          setState(S_ERROR);
        }
      }
    } else {
      setState(S_ERROR);
    }
  }

  //BEGIN unimplemented
  async event void FrameStartAlarm.fired(){
  }
  command error_t SplitControl.stop(){
    //TODO: set scOffPending flag
    return FAIL;
  }

  command error_t CXTDMA.setSchedule(uint32_t startAt, uint32_t frameLen,
      uint16_t numFrames, uint32_t fwCheckLen){
    return FAIL;
  }

  async event void Rf1aPhysical.frameStarted () { 
    printf("!fs\n\r");
  }

  async event void Rf1aPhysical.carrierSense () { 
//    printf("!cs\n\r");
  }
  async event void Rf1aPhysical.receiveDone (uint8_t* buffer,
                                             unsigned int count,
                                             int result) {
    printf("!rd\n\r");
  }

  async event void Rf1aPhysical.sendDone (int result) { 
    printf("!sd\n\r");
  }
  async event void Rf1aPhysical.receiveStarted (unsigned int length) { }
  async event void Rf1aPhysical.receiveBufferFilled (uint8_t* buffer,
                                                     unsigned int count) { }
  async event void Rf1aPhysical.clearChannel () { }
  async event void Rf1aPhysical.released () { }

  async event bool Rf1aPhysical.idleModeRx () { 
    return FALSE;
  }
  //END unimplemented

}
