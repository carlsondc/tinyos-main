configuration TestAppC{
} implementation {
  components MainC;
  components TestP;
  components SerialPrintfC;
  components PlatformSerialC;
  components LedsC;

  TestP.Boot -> MainC;
  TestP.UartStream -> PlatformSerialC;
  TestP.UartControl -> PlatformSerialC;
  TestP.Leds -> LedsC;

  components GlossyRf1aSettings125KC as Rf1aSettings;

  components new Rf1aPhysicalC();
  Rf1aPhysicalC.Rf1aConfigure -> Rf1aSettings;

  components new Rf1aIeee154PacketC() as Ieee154Packet; 
  Ieee154Packet.Rf1aPhysicalMetadata -> Rf1aPhysicalC;
  components Ieee154AMAddressC;

  components Rf1aCXPacketC;
  Rf1aCXPacketC.SubPacket -> Ieee154Packet;
  Rf1aCXPacketC.Ieee154Packet -> Ieee154Packet;
  Rf1aCXPacketC.Rf1aPacket -> Ieee154Packet;

  components Rf1aAMPacketC as AMPacket;
  AMPacket.SubPacket -> Rf1aCXPacketC;
  AMPacket.Ieee154Packet -> Ieee154Packet;
  AMPacket.Rf1aPacket -> Ieee154Packet;
  AMPacket.ActiveMessageAddress -> Ieee154AMAddressC;
  Rf1aCXPacketC.AMPacket -> AMPacket;

  components CXTDMAPhysicalC;
  CXTDMAPhysicalC.HplMsp430Rf1aIf -> Rf1aPhysicalC;
  CXTDMAPhysicalC.Resource -> Rf1aPhysicalC;
  CXTDMAPhysicalC.Rf1aPhysical -> Rf1aPhysicalC;
  CXTDMAPhysicalC.Rf1aStatus -> Rf1aPhysicalC;
  CXTDMAPhysicalC.Rf1aPacket -> Ieee154Packet;
  CXTDMAPhysicalC.CXPacket -> Rf1aCXPacketC;

  components TDMASchedulerC;
  TDMASchedulerC.SubSplitControl -> CXTDMAPhysicalC;
  TDMASchedulerC.SubCXTDMA -> CXTDMAPhysicalC;
  TDMASchedulerC.AMPacket -> AMPacket;
  TDMASchedulerC.CXPacket -> Rf1aCXPacketC;
  TDMASchedulerC.Packet -> Rf1aCXPacketC;
  TDMASchedulerC.Rf1aPacket -> Ieee154Packet;
  TDMASchedulerC.Ieee154Packet -> Ieee154Packet;

  components CXFloodC;
  CXFloodC.CXTDMA -> TDMASchedulerC.CXTDMA;
  CXFloodC.TDMAScheduler -> TDMASchedulerC.TDMAScheduler;
  CXFloodC.CXPacket -> Rf1aCXPacketC;
  CXFloodC.LayerPacket -> Rf1aCXPacketC;


  TestP.SplitControl -> TDMASchedulerC.SplitControl;
  TestP.TDMARootControl -> TDMASchedulerC.TDMARootControl;
  TestP.AMPacket -> AMPacket;
  TestP.Packet -> Rf1aCXPacketC;

  TestP.Send -> CXFloodC.Send;
  TestP.Receive -> CXFloodC.Receive;
  
}