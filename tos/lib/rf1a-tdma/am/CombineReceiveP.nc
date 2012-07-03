module CombineReceiveP{
  provides interface Receive[am_id_t id];
  provides interface Receive as Snoop[am_id_t id];
  uses interface Receive as SimpleFloodReceive[am_id_t id];
  uses interface Receive as UnreliableBurstReceive[am_id_t id];
  uses interface Receive as ReliableBurstReceive[am_id_t id];

  uses interface CXPacket;
  uses interface CXPacketMetadata;
  uses interface Rf1aPacket;
  uses interface AMPacket;
  uses interface Packet as AMPacketBody;
  provides interface ReceiveNotify;
} implementation {
  void printRX(message_t* msg){
    printf_APP("RX s: %u d: %u sn: %u c: %u r: %d l: %u\r\n", 
      call CXPacket.source(msg),
      call CXPacket.destination(msg),
      call CXPacket.sn(msg),
      call CXPacketMetadata.getReceivedCount(msg),
      call Rf1aPacket.rssi(msg),
      call Rf1aPacket.lqi(msg)
      );
  }

  message_t* handleReceive(am_id_t id, message_t* msg, void* payload, uint8_t len){
    //this is prettttty ugly. The pointer/len we get here include the
    //  AM header. Since the packet access logic is not here, we're
    //  going to call out to it.
    // ideally this would be 
    // signal (msg, payload + sizeof(am_header), len - sizeof(am_header))
    uint8_t pll = call AMPacketBody.payloadLength(msg);
    void* pl = call AMPacketBody.getPayload(msg, pll);
    signal ReceiveNotify.received(call AMPacket.source(msg));
    printRX(msg);
    if (call AMPacket.isForMe(msg)){
      return signal Receive.receive[id](msg, pl, pll);
    }else{
      return signal Snoop.receive[id](msg, pl, pll);
    }
  }

  event message_t* SimpleFloodReceive.receive[am_id_t id](message_t* msg, void* payload,
      uint8_t len){
    return handleReceive(id, msg, payload, len);
  }
  event message_t* UnreliableBurstReceive.receive[am_id_t id](message_t* msg, void* payload,
      uint8_t len){
    return handleReceive(id, msg, payload, len);
  }
  event message_t* ReliableBurstReceive.receive[am_id_t id](message_t* msg, void* payload,
      uint8_t len){
    return handleReceive(id, msg, payload, len);
  }


  default event message_t* Receive.receive[am_id_t id](message_t* msg,
      void* payload, uint8_t len){
    return msg;
  }
  default event message_t* Snoop.receive[am_id_t id](message_t* msg,
      void* payload, uint8_t len){
    return msg;
  }

  default event void ReceiveNotify.received(am_addr_t from){}
}
