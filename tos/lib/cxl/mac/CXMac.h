#ifndef CX_MAC_H
#define CX_MAC_H

#include "CXLink.h"

#define CXM_DATA 0
#define CXM_PROBE 1
#define CXM_KEEPALIVE 2
#define CXM_CTS 3
#define CXM_RTS 4
//TODO: maybe add acks

typedef nx_struct cx_mac_header{
  nx_uint8_t macType;
} cx_mac_header_t;

#define LPP_DEFAULT_PROBE_INTERVAL 5120UL
#define LPP_SLEEP_TIMEOUT 30720UL

#define CHECK_TIMEOUT (FRAMELEN_FAST + (FRAMELEN_FAST/4))

#endif
