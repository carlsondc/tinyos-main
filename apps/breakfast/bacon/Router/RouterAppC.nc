 #include "StorageVolumes.h"
 #include "message.h"
 #include "CXDebug.h"
 #include "router.h"
configuration RouterAppC{
} implementation {
  #if ENABLE_PRINTF == 1
  components SerialPrintfC;
  components SerialStartC;
  #endif

  components WatchDogC;
  #ifndef NO_STACKGUARD
  components StackGuardMilliC;
  #endif

  components MainC;
  components RouterP;


  components new PoolC(message_t, 4);

  components new RecordPushRequestC(VOLUME_RECORD, TRUE);
  components new RouterAMSenderC(AM_TUNNELED_MSG);
  components CXLinkPacketC;

  RecordPushRequestC.Pool -> PoolC;
  RecordPushRequestC.AMSend -> RouterAMSenderC;
  RecordPushRequestC.Packet -> RouterAMSenderC;
  RecordPushRequestC.CXLinkPacket -> CXLinkPacketC;


  components SettingsStorageConfiguratorC;
  SettingsStorageConfiguratorC.Pool -> PoolC;
  components SettingsStorageC;
  components new LogStorageC(VOLUME_RECORD, TRUE) as SettingsLS;
  SettingsStorageC.LogWrite -> SettingsLS;

  RecordPushRequestC.Get -> CXRouterC.Get[NS_ROUTER];

  components ActiveMessageC;
  RouterP.SplitControl -> ActiveMessageC;
  RouterP.Boot -> MainC;

  components new AMReceiverC(AM_LOG_RECORD_DATA_MSG);
  RouterP.ReceiveData -> AMReceiverC;
  RouterP.AMPacket -> AMReceiverC;

  components new LogStorageC(VOLUME_RECORD, TRUE);
  RouterP.LogWrite -> LogStorageC;
  RouterP.Pool -> PoolC;

  components CXRouterC;
  components new TimerMilliC();
  RouterP.CXDownload -> CXRouterC.CXDownload[NS_SUBNETWORK];
  RouterP.SettingsStorage -> SettingsStorageC;
  RouterP.Timer -> TimerMilliC;
}
