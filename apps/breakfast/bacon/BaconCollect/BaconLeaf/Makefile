COMPONENT=LeafAppC
CFLAGS+=-I$(TOSDIR)/lib/serialprintf

CFLAGS+=-I..
CFLAGS+=-I$(TOSROOT)/apps/breakfast/util
CFLAGS+=-I$(TOSROOT)/apps/breakfast/util/globalID
CFLAGS+=-I$(TOSROOT)/apps/breakfast/util/i2cDiscover
CFLAGS+=-I$(TOSROOT)/apps/breakfast/util/i2cCom
CFLAGS+=-I$(TOSROOT)/apps/breakfast/util/i2cADCReader
CFLAGS+=-I$(TOSDIR)/chips/msp430/x2xxx/internalFlash

#CFLAGS+=-I$(TOSROOT)/apps/breakfast/util/i2cTLVStorage


CFLAGS += -DLOW_POWER_LISTENING
CFLAGS += -DLPL_DEF_LOCAL_WAKEUP=512
CFLAGS += -DLPL_DEF_REMOTE_WAKEUP=512
CFLAGS += -DDELAY_AFTER_RECEIVE=60

#CFLAGS += -DREF_VOLT_AUTO_CONFIGURE

#CFLAGS+=-DTOSSIM_DEBUG=1

CFLAGS += -DCC1101_DEF_CHANNEL=196
CFLAGS += -DCC1101_DEF_RFPOWER=0xC0

#CFLAGS += -DCC1101_AGCCTRL1=0x47
#CFLAGS += -DCC1101_MDMCFG2=0x07


include $(MAKERULES)
