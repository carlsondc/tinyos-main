#ifndef TESTBED_H
#define TESTBED_H

#include "multiNetwork.h"

#ifndef STARTUP_DELAY
#define STARTUP_DELAY (90UL*1024UL)
#endif

#ifndef TEST_SEGMENT
#define TEST_SEGMENT NS_SUBNETWORK
#endif

#ifndef TEST_DELAY
#define TEST_DELAY (LPP_SLEEP_TIMEOUT * 4UL)
#endif

#ifndef PACKETS_PER_DOWNLOAD
#define PACKETS_PER_DOWNLOAD 0
#endif 


#endif
