#ifndef CX_ROUTING_H
#define CX_ROUTING_H
typedef struct cx_route_entry_t{
  am_addr_t n0,
  am_addr_t n1,
  uint8_t distance,
  bool used,
};

#ifndef CX_ROUTING_TABLE_ENTRIES
#define CX_ROUTING_TABLE_ENTRIES 16
#endif

#endif
