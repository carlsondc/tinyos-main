 #include "CX.h"
//TODO: switch to cx_addr, cx_id 
interface CXPacket{
//  command am_addr_t address();
  command void init(message_t* amsg);
  command am_addr_t destination(message_t* amsg);
  command am_addr_t source(message_t* amsg);
  command void setDestination(message_t* amsg, am_addr_t addr);
  command void setSource(message_t* amsg, am_addr_t addr);
  command uint16_t sn(message_t* amsg);
  command void newSn(message_t* amsg);
  command uint8_t count(message_t* amsg);
  command void setCount(message_t* amsg, uint8_t cxcount);
  command void incCount(message_t* amsg);
  command bool isForMe(message_t* amsg);
  //Type = ACK or DATA (used at network layer)
  command uint8_t getNetworkType(message_t* amsg);
  command void setNetworkType(message_t* amsg, am_id_t t);
  //Type = SETUP or DATA (used at transport layer)
  command uint8_t getTransportType(message_t* amsg);
  command void setTransportType(message_t* amsg, am_id_t t);
  command void setNetworkProtocol(message_t* amsg, uint8_t t);
  command uint8_t getNetworkProtocol(message_t* amsg);
  command void setTransportProtocol(message_t* amsg, uint8_t t);
  command uint8_t getTransportProtocol(message_t* amsg);
  command void setTimestamp(message_t* amsg, uint32_t ts);
  command uint32_t getTimestamp(message_t* amsg);
  command void setScheduleNum(message_t* amsg, uint8_t scheduleNum);
  command uint8_t getScheduleNum(message_t* amsg);
  command void setOriginalFrameNum(message_t* amsg, uint16_t frameNum);
  command uint16_t getOriginalFrameNum(message_t* amsg);
  command bool ackRequested(message_t* msg);
  command uint8_t getTTL(message_t* amsg);
  command void setTTL(message_t* amsg, uint8_t ttl);
  command void decTTL(message_t* amsg);
  //used for doing precision timestamping: this lets the user know
  //where to pause in the transmission.
  command const uint8_t* getTimestampAddr(message_t* amsg);
}
