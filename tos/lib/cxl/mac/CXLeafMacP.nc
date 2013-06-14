module CXLeafMacP {
  provides interface CXMacController;
  provides interface Receive;
  uses interface Receive as SubReceive;
  uses interface CXMacPacket;
  uses interface CXLinkPacket;

  provides interface Send;
  uses interface Send as SubSend;
} implementation {
  message_t* pendingMsg = NULL;

  task void signalGranted(){
    pendingMsg = NULL;
    signal CXMacController.requestGranted();
  }

  event message_t* SubReceive.receive(message_t* msg, 
      void* pl, uint8_t len){
    printf("CXLM sr.r %x %x %p\r\n", 
      call CXMacPacket.getMacType(msg),
      (call CXLinkPacket.getLinkHeader(msg))->destination,
      pendingMsg);
    if (call CXMacPacket.getMacType(msg) == CXM_CTS 
        && (call CXLinkPacket.getLinkHeader(msg))->destination == TOS_NODE_ID 
        && pendingMsg){
      post signalGranted();
    }
    return msg;
  }

  command error_t CXMacController.requestSend(message_t* msg){
    if (pendingMsg){
      return EBUSY;
    }else{
      pendingMsg = msg;
      return SUCCESS;
    }
  }

  command error_t Send.send(message_t* msg, uint8_t len){
    call CXMacPacket.setMacType(msg, CXM_DATA);
    return call SubSend.send(msg, len);
  }

  event void SubSend.sendDone(message_t* msg, error_t error){
    signal Send.sendDone(msg, error);
  }
  
  command void* Send.getPayload(message_t* msg, uint8_t len){
    return call SubSend.getPayload(msg, len);
  }
  command uint8_t Send.maxPayloadLength(){
    return call SubSend.maxPayloadLength();
  }
  command error_t Send.cancel(message_t* msg){
    return call SubSend.cancel(msg);
  }

  
}
