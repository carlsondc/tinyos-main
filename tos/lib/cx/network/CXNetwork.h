#ifndef CX_NETWORK_H
#define CX_NETWORK_H

typedef nx_struct cx_network_header {
  nx_uint8_t ttl;
  nx_uint8_t hops;
} cx_network_header_t;

typedef struct cx_network_metadata {
  uint8_t layerCount;
  uint32_t atFrame;
  uint32_t reqFrame;
  uint32_t microRef;
  uint32_t t32kRef;
  void* next;
} cx_network_metadata_t;

#ifndef CX_NETWORK_POOL_SIZE
//1 for forwarding, 1 for self. Expand if we ever support multiple
//  ongoing floods.
#define CX_NETWORK_POOL_SIZE 2
#endif

#ifndef CX_NETWORK_FORWARD_DELAY 
//forward received packet immediately.
#define CX_NETWORK_FORWARD_DELAY 1
#endif

#ifndef CX_SELF_RETX
#define CX_SELF_RETX 0
#endif

#endif