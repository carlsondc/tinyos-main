interface TDMARoutingSchedule{
  async command uint16_t framesPerSlot();
//  async command bool isOrigin(uint16_t frameNum);
  async command bool isSynched();
  async command uint8_t maxRetransmit();
  async command bool ownsFrame(uint16_t frameNum);
  async command uint16_t framesLeftInSlot(uint16_t frameNum);
  async command uint16_t maxDepth();
  command uint16_t currentFrame();
  command uint16_t getNumSlots();
}
