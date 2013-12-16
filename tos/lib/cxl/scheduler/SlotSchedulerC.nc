configuration SlotSchedulerC{

  provides interface SplitControl;
  provides interface Send;
  provides interface Packet;
  provides interface Receive;

  uses interface Pool<message_t>;

  uses interface SlotController[uint8_t ns];

  provides interface Neighborhood;
  provides interface DownloadNotify[uint8_t ns];

  uses interface Get<uint32_t> as PushCookie;
  uses interface Get<uint32_t> as WriteCookie;
  uses interface Get<uint32_t> as MissingLength;
} implementation {
  components CXWakeupC;
  components SlotSchedulerP;

  SlotSchedulerP.PushCookie = PushCookie;
  SlotSchedulerP.WriteCookie = WriteCookie;
  SlotSchedulerP.MissingLength = MissingLength;
  components new Timer32khzC() as SlotTimer;
  components new Timer32khzC() as FrameTimer;
  components LocalTimeMilliC;
  SlotSchedulerP.SlotTimer -> SlotTimer;
  SlotSchedulerP.FrameTimer -> FrameTimer;
  SlotSchedulerP.LocalTime -> LocalTimeMilliC;

  Send = SlotSchedulerP.Send;
  Receive = SlotSchedulerP.Receive;
  SplitControl = CXWakeupC.SplitControl;
  SlotSchedulerP.Pool = Pool;
  CXWakeupC.Pool = Pool;
  SlotSchedulerP.SlotController = SlotController;
  
  SlotSchedulerP.CXLink -> CXWakeupC.CXLink;
  SlotSchedulerP.LppControl -> CXWakeupC.LppControl;
  SlotSchedulerP.CXMacPacket -> CXWakeupC.CXMacPacket;
  SlotSchedulerP.CXLinkPacket -> CXWakeupC.CXLinkPacket;
  SlotSchedulerP.Packet -> CXWakeupC.Packet;
  SlotSchedulerP.SubSend -> CXWakeupC.Send;
  SlotSchedulerP.SubReceive -> CXWakeupC.Receive;

  components NeighborhoodC;
  SlotSchedulerP.Neighborhood -> NeighborhoodC;
  Neighborhood = NeighborhoodC;
  NeighborhoodC.LppProbeSniffer -> CXWakeupC;
  //points to body of mac
  NeighborhoodC.Packet -> CXWakeupC.Packet;
  NeighborhoodC.CXLinkPacket -> CXWakeupC.CXLinkPacket;

  Packet = CXWakeupC.Packet;

  components CXAMAddressC;
  SlotSchedulerP.ActiveMessageAddress -> CXAMAddressC;

  components CXRoutingTableC;
  SlotSchedulerP.RoutingTable -> CXRoutingTableC;

  components RebootCounterC;
  SlotSchedulerP.RebootCounter -> RebootCounterC;

  components CXProbeScheduleC;
  SlotSchedulerP.ProbeSchedule -> CXProbeScheduleC.Get;

  components StateDumpC;
  SlotSchedulerP.StateDump -> StateDumpC;

  #ifndef AM_STATS_LOG
  #define AM_STATS_LOG 0
  #endif
  #ifndef PRINTF_STATS_LOG
  #define PRINTF_STATS_LOG 0
  #endif

  #if AM_STATS_LOG == 1
  components SerialStartC;
  components AMStatsLogC as StatsLog;

  StatsLog.CXLinkPacket -> CXWakeupC.CXLinkPacket;
  StatsLog.CXMacPacket -> CXWakeupC.CXMacPacket;
  StatsLog.Packet -> CXWakeupC.Packet;
  SlotSchedulerP.StatsLog -> StatsLog;

  #elif PRINTF_STATS_LOG == 1

  components PrintfStatsLogC as StatsLog;
  StatsLog.CXLinkPacket -> CXWakeupC.CXLinkPacket;
  StatsLog.CXMacPacket -> CXWakeupC.CXMacPacket;
  StatsLog.Packet -> CXWakeupC.Packet;
  SlotSchedulerP.StatsLog -> StatsLog;
  #endif

  DownloadNotify = SlotSchedulerP;
}
