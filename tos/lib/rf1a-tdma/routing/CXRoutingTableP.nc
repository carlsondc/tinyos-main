 #include "CXRouting.h"

generic module CXRoutingTableP(uint8_t numEntries){
  provides interface CXRoutingTable;
} implementation {
  cx_route_entry_t rt[numEntries];
  uint8_t lastEvicted = 0;

  command error_t Init.init(){
    uint8_t i;
    for(i = 0; i < numEntries; i++){
      rt[i]->used = FALSE;
    }
  }

  //TODO: bidirectionality?
  bool getEntry(cx_route_entry_t** re, am_addr_t n0, am_addr_t n1){
    uint8_t i = 0;
    for (i = 0; i < numEntries; i++){
      *re = rt[i];
      if ((*re->n0 == n0) && (*re->n1 == n1)){
        return TRUE;
      }
    }
    return FALSE;
  }

  command error_t CXRoutingTable.update(am_addr_t n0, am_addr_t n1,
      uint8_t distance){
    uint8_t i;
    cx_route_entry_t* re;
    //update and mark used-recently if it's already in the table.
    if (getEntry(&re, n0, n1)){
      re->distance = distance;
      re->used = TRUE;
      return SUCCESS;
    }

    //start at lastEvicted+1
    i = (lastEvicted + 1 + i)%numEntries;
    re = rt[i];
    //look for one that hasn't been used recently, clearing LRU flag
    //as you go. Eventually we'll either find an unused slot or we'll
    //wrap around.
    while (re->used){
      re->used = FALSE;
      i = (i+1)%numEntries;
      re = rt[i];
    }
    //save it
    re->n0 = n0;
    re->n1 = n1;
    re->distance = distance;
    re->used = TRUE;
    //update for next time.
    lastEvicted = i;
    return SUCCESS;
  }

  command error_t CXRoutingTable.isBetween(am_addr_t n0, am_addr_t n1,
      bool* result){
    cx_routing_entry_t* re;
    if (getEntry(&re, n0, TOS_NODE_ID)){
      uint8_t sm = re->distance;
      if (getEntry(&re, n1, TOS_NODE_ID)){
        uint8_t md = re->distance;
        if (getEntry(&re, n0, n1)){
          *result = sm + md <= re->distance;
          return SUCCESS;
        }
      }
    }
    return FAIL;
  }
}
