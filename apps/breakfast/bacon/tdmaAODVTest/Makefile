COMPONENT=TestAppC

TEST_CHANNEL?=64
CFLAGS+=-DTEST_CHANNEL=$(TEST_CHANNEL)

IS_SENDER?=0
CFLAGS+=-DIS_SENDER=$(IS_SENDER)

FLOOD_TEST?=1
CFLAGS+=-DFLOOD_TEST=$(FLOOD_TEST)

#dbm patable0
# -30 0x03
# -12 0x25
#  -6 0x2D
#   0 0x8D
#  10 0xC3
# max 0xC0
PATABLE0_SETTING?=0x8D
CFLAGS+=-DPATABLE0_SETTING=$(PATABLE0_SETTING)

PFLAGS += -I$(TOSDIR)/lib/serialprintf
CFLAGS += -I../../util
CFLAGS += -I$(TOSDIR)/lib/rf1a-tdma
CFLAGS += -I$(TOSDIR)/lib/rf1a-tdma/timer
CFLAGS += -I$(TOSDIR)/lib/rf1a-tdma/tdma
CFLAGS += -I$(TOSDIR)/lib/rf1a-tdma/flood
CFLAGS += -I$(TOSDIR)/lib/rf1a-tdma/scopedFlood
CFLAGS += -I$(TOSDIR)/lib/rf1a-tdma/dispatch
CFLAGS += -I$(TOSDIR)/lib/rf1a-tdma/packet
CFLAGS += -I$(TOSDIR)/lib/rf1a-tdma/physical
CFLAGS += -I$(TOSDIR)/lib/rf1a-tdma/physical/configs
CFLAGS += -I$(TOSDIR)/lib/rf1a-tdma/routing
CFLAGS += -I$(TOSDIR)/lib/rf1a-tdma/aodv

CFLAGS+=-DCX_RADIO_LOGGING

SW_TOPO?=0
CFLAGS+=-DSW_TOPO=$(SW_TOPO)
#1: line 2: tube
TOPOLOGY?=1
CFLAGS+=-DTOPOLOGY=$(TOPOLOGY)
#CFLAGS+=-DDEBUG_SW_TOPO

CX_ADAPTIVE_SR?=1
CFLAGS+=-DCX_ADAPTIVE_SR=$(CX_ADAPTIVE_SR)

ENABLE_SKEW_CORRECTION?=1
CFLAGS+=-DENABLE_SKEW_CORRECTION=$(ENABLE_SKEW_CORRECTION)

TDMA_ROOT?=0
CFLAGS+=-DTDMA_ROOT=$(TDMA_ROOT)

DESTINATION_ID?=0
CFLAGS+=-DDESTINATION_ID=$(DESTINATION_ID)

DISCONNECTED_SR?=500
CFLAGS+=-DDISCONNECTED_SR=$(DISCONNECTED_SR)

#width of "ring"
TDMA_MAX_RETRANSMIT?=1UL
#determines length of frame (along with ring width)
TDMA_MAX_DEPTH?=4UL
#determines total number of slots
TDMA_MAX_NODES?=3UL
TDMA_TIMEOUT_CYCLES?=10

TDMA_INIT_SYMBOLRATE?=10

CFLAGS+= -DTDMA_MAX_DEPTH=$(TDMA_MAX_DEPTH)
CFLAGS+= -DTDMA_MAX_NODES=$(TDMA_MAX_NODES)
CFLAGS+= -DTDMA_MAX_RETRANSMIT=$(TDMA_MAX_RETRANSMIT)
CFLAGS+= -DTDMA_INIT_SYMBOLRATE=$(TDMA_INIT_SYMBOLRATE)
CFLAGS+= -DTDMA_TIMEOUT_CYCLES=$(TDMA_TIMEOUT_CYCLES)

#scheduler
#for looking at offsets between alarm.fired, alarm.handled, and sfd
CFLAGS += -DDEBUG_TESTBED
CFLAGS += -DDEBUG_TESTBED_CRC
CFLAGS += -DDEBUG_RADIO_STATS
#CFLAGS += -DDEBUG_TIMING
#CFLAGS += -DDEBUG_BREAKFAST
#CFLAGS += -DDEBUG_F_GP
#CFLAGS += -DDEBUG_SCHED
#CFLAGS += -DDEBUG_SCHED_SR
#CFLAGS += -DDEBUG_PFS_FREAKOUT
#CFLAGS += -DDEBUG_TDMA_SS
#CFLAGS += -DDEBUG_PFS
#elements of flood related to sched
#CFLAGS += -DDEBUG_F_SCHED

#CFLAGS += -DDEBUG_CX_TDMA_P_STATE
CFLAGS += -DDEBUG_CX_TDMA_P_STATE_ERROR
#CFLAGS += -DDEBUG_AODV
#CFLAGS += -DDEBUG_AODV_STATE
#CFLAGS += -DDEBUG_AODV_IO
#CFLAGS += -DDEBUG_AODV_S

# CFLAGS+=-DDEBUG_F_STATE
#CFLAGS+=-DDEBUG_F_RX

#CFLAGS+=-DDEBUG_SF_STATE
#CFLAGS+=-DDEBUG_SF_GP
#CFLAGS+=-DDEBUG_SF_RX

CFLAGS+=-DTDMA_PIN_DEBUG_ON

#CFLAGS+=-DPORT_STATE_TIMING_TX=P1OUT
#CFLAGS+=-DPIN_STATE_TIMING_TX=BIT3
CFLAGS+=-DPORT_STATE_TIMING_CAP=P1OUT
CFLAGS+=-DPIN_STATE_TIMING_CAP=BIT4
#CFLAGS+=-DPORT_SW_CAP=P1OUT
#CFLAGS+=-DPIN_SW_CAP=BIT1
#CFLAGS+=-DPORT_SW_OF=P1OUT
#JCFLAGS+=-DPIN_SW_OF=BIT1
#CFLAGS+=-DPORT_SW_OFP=P1OUT
#CFLAGS+=-DPIN_SW_OFP=BIT4
#CFLAGS+=-DPORT_REPORT_STATS=P2OUT
#CFLAGS+=-DPIN_REPORT_STATS=BIT4
#CFLAGS+=-DPORT_T_OF=P2OUT
#CFLAGS+=-DPIN_T_OF=BIT4

#defining these vars will enable the debug code.
#CFLAGS+=-DPORT_RX_READY=P1OUT
#CFLAGS+=-DPIN_RX_READY=BIT1

#CFLAGS+=-DPORT_IS_TX=P1OUT
#CFLAGS+=-DPIN_IS_TX=BIT3
##low level TX timings
#CFLAGS +=-DPORT_FS_STROBE=P1OUT
#CFLAGS +=-DPIN_FS_STROBE=BIT3
#CFLAGS +=-DPORT_STROBE=P1OUT
#CFLAGS +=-DPIN_STROBE=BIT1
#CFLAGS +=-DPORT_GETPACKET=P1OUT
#CFLAGS +=-DPIN_GETPACKET=BIT4
#CFLAGS +=-DPORT_LOADFIFO=P2OUT
#CFLAGS +=-DPIN_LOADFIFO=BIT4


#CFLAGS +=-DPORT_SF_GPO=P1OUT
#CFLAGS +=-DPIN_SF_GPO=BIT1

#CFLAGS +=-DPORT_SF_GPF=P1OUT
#CFLAGS +=-DPIN_SF_GPF=BIT4

#CFLAGS +=-DPORT_F_GPO=P1OUT
#CFLAGS +=-DPIN_F_GPO=BIT1

#CFLAGS +=-DPORT_F_GPF=P1OUT
#CFLAGS +=-DPIN_F_GPF=BIT4

#CFLAGS +=-DPORT_GP=P1OUT
#CFLAGS +=-DPIN_GP=BIT1

#CFLAGS +=-DPORT_FS_CYCLE=P1OUT
#CFLAGS +=-DPIN_FS_CYCLE=BIT4

#CFLAGS +=-DPORT_PFS_CYCLE=P1OUT
#CFLAGS +=-DPIN_PFS_CYCLE=BIT1

#CFLAGS +=-DPORT_TXCP_TIMING=P1OUT
#CFLAGS +=-DPIN_TXCP_TIMING=BIT4

#CFLAGS +=-DPORT_TX_TIMING=P1OUT
#CFLAGS +=-DPIN_TX_TIMING=BIT4

#CFLAGS +=-DPORT_FS_TIMING=P1OUT
#CFLAGS +=-DPIN_FS_TIMING=BIT4

#CFLAGS +=-DPORT_PFS_TIMING=P1OUT
#CFLAGS +=-DPIN_PFS_TIMING=BIT4

#CFLAGS +=-DPORT_SC_TIMING=P1OUT
#CFLAGS +=-DPIN_SC_TIMING=BIT4

#CFLAGS +=-DPORT_FW_TIMING=P1OUT
#CFLAGS +=-DPIN_FW_TIMING=BIT4

#CFLAGS +=-DPORT_SS_TIMING=P1OUT
#CFLAGS +=-DPIN_SS_TIMING=BIT4

DEBUG_SCALE?=1UL
CFLAGS += -DDEBUG_SCALE=$(DEBUG_SCALE)

#16mhz mclk, 32 mhz dco
PFLAGS+=-DMSP430XV2_DCO_CONFIG=MSP430XV2_DCO_32MHz_RSEL6

CFLAGS+=-DXT2_SMCLK

TA_DIV?=1UL
CFLAGS+=-DTA_DIV=$(TA_DIV)

include $(MAKERULES)
