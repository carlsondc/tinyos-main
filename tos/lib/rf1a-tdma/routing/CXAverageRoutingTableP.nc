/*
 * Copyright (c) 2014 Johns Hopkins University.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the copyright holders nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL
 * THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE.
*/

 #include "CXRouting.h"
 #include "CXAverageRouting.h"
 #include "CXRoutingDebug.h"

generic module CXAverageRoutingTableP(uint8_t numEntries){
  provides interface CXRoutingTable;
  provides interface Init;
} implementation {
  cx_avg_route_entry_t rt[numEntries];
  uint8_t lastEvicted = numEntries-1;

  uint8_t curDump;
  bool dumping = FALSE;
  

  #ifndef ROUND_THRESH_LOG2
  #define ROUND_THRESH_LOG2 1
  #endif

  //rounding threshold is 2**(-1*(ROUND_THRESH_LOG2))
  //
  //e.g. ROUND_THRESH_LOG2 = 1
  //    
  // we make 1 remainder bit, divide, and round up if there is a
  // remainder (0.5 or higher)
  //e.g. ROUND_THRESH_LOG2 = 2
  // make 2 remainder bits (0.5, 0.25), divide, and if there is a
  // remainder then it has to be greater than or equal to 0.25.
  uint8_t dist(uint32_t distanceTotal, uint32_t measureCount, 
      bool roundUp){
    //shift total left so it is in
    //fixed-point fraction form with a FRAC_LEN bit fractional part,
    //then divide it
    uint32_t fpAvg = (distanceTotal << ROUND_THRESH_LOG2) / measureCount;
    //mask off the fractional part
    uint32_t fracMask = ~((~0) << ROUND_THRESH_LOG2);
    //quotient
    uint32_t q = fpAvg >> ROUND_THRESH_LOG2;
    //remainder
    uint32_t r = fpAvg & fracMask;

    if (roundUp){
      if (r){
        return q + 1;
      }else{
        return q;
      }
    } else{
      //round down: ignore remainder
      return q;
    }
  }


  task void nextDumpTask(){
    cx_avg_route_entry_t* re;
    printf("# AVG RT[%d] %d->%d = u %d d %d (%ld/%ld)(%d %d) ", 
      curDump, rt[curDump].n0, rt[curDump].n1, 
      dist(rt[curDump].distanceTotal, rt[curDump].measureCount, TRUE), 
      dist(rt[curDump].distanceTotal, rt[curDump].measureCount, FALSE), 
      rt[curDump].distanceTotal,
      rt[curDump].measureCount,
      rt[curDump].used, 
      rt[curDump].pinned);
    printf(" lu: %d", 
      call CXRoutingTable.selectionDistance(rt[curDump].n0, rt[curDump].n1, FALSE));
    printf(" rev: %d \r\n", 
      call CXRoutingTable.selectionDistance(rt[curDump].n1, rt[curDump].n0, TRUE));
    curDump ++;
    if (curDump < numEntries){
      post nextDumpTask();
    }else{
      dumping = FALSE;
    }
  }

  command void CXRoutingTable.dumpTable(){
    if (! dumping){
      curDump = 0;
      dumping = TRUE;
      post nextDumpTask();
    }
  }

  command error_t Init.init(){
    uint8_t i;
    for(i = 0; i < numEntries; i++){
      rt[i].used = FALSE;
      rt[i].pinned = FALSE;
    }
    return SUCCESS;
  }

  bool getEntry(cx_avg_route_entry_t** re, am_addr_t n0, am_addr_t n1,
      bool bdOK){
    uint8_t i = 0;
    for (i = 0; i < numEntries; i++){
      if ((rt[i].n0 == n0) && (rt[i].n1 == n1)){
        *re = &rt[i];
        return TRUE;
      }
    }
    if (bdOK){
      for (i = 0; i < numEntries; i++){
        if ((rt[i].n0 == n1) && (rt[i].n1 == n0)){
          *re = &rt[i];
          return TRUE;
        }
      }
    }
    return FALSE;
  }

  command uint8_t CXRoutingTable.selectionDistance(am_addr_t from, am_addr_t to, 
      bool bdOK){
    cx_avg_route_entry_t* re;
    if (from == TOS_NODE_ID && to == TOS_NODE_ID){
      return 0;
    }
    if (getEntry(&re, from, to, bdOK)){
      //Round down when we are selecting
      return dist(re->distanceTotal, re->measureCount, FALSE);
    }else{
      return 0xff;
    }
  }

  command uint8_t CXRoutingTable.advertiseDistance(am_addr_t from, am_addr_t to, 
      bool bdOK){
    cx_avg_route_entry_t* re;
    if (from == TOS_NODE_ID && to == TOS_NODE_ID){
      return 0;
    }
    if (getEntry(&re, from, to, bdOK)){
      //Round up when we are advertising
      return dist(re->distanceTotal, re->measureCount, TRUE);
    }else{
      return 0xff;
    }
  }

  command error_t CXRoutingTable.update(am_addr_t n0, am_addr_t n1,
      uint8_t distance, bool incremental){
    uint8_t i;
    uint8_t checked = 0;
    cx_avg_route_entry_t* re;
    //update and mark used-recently if it's already in the table.
    if (getEntry(&re, n0, n1, FALSE)){
      if (incremental){
        re->distanceTotal += distance;
        re->measureCount ++;
      }else{
        re->distanceTotal = distance;
        re->measureCount = 1;
      }
      re->used = TRUE;

      return SUCCESS;
    }
    //start at lastEvicted+1
    i = (lastEvicted + 1)%numEntries;
    //look for one that hasn't been used recently, clearing LRU flag
    //as you go. Eventually we'll either find an unused slot or we'll
    //wrap around.

    while (rt[i].used && checked < CX_ROUTING_TABLE_ENTRIES ){
      if (!rt[i].pinned){
        rt[i].used = FALSE;
      }else{
        checked++;
      }
      i = (i+1)%numEntries;
    }
    //Fail if there are no un-pinned entries
    if (rt[i].pinned){
      printf("~No unpinned RT entries!\r\n");
      call CXRoutingTable.dumpTable();
      return FAIL;
    }
    //save it
    printf_ROUTING_TABLE("NR %u->%u %u\r\n", n0, n1, distance);
    rt[i].n0 = n0;
    rt[i].n1 = n1;
    //New record: so, overwrite distance and measureCount
    rt[i].distanceTotal = distance;
    rt[i].measureCount = 1;
    rt[i].used = TRUE;
    //update for next time.
    lastEvicted = i;
    return SUCCESS;
  }

  command error_t CXRoutingTable.setPinned(am_addr_t n0, am_addr_t n1,
      bool pinned, bool bdOK){
    cx_avg_route_entry_t* re;
    error_t err = FAIL;
    //make sure that we pin both directions...
//    printf_TMP("Pin %d -> %d: %d %d e=", n0, n1, pinned, bdOK);
    if (getEntry(&re, n0, n1, FALSE)){
      err = SUCCESS;
      re->pinned = pinned;
    }    
    if (bdOK){
      if (getEntry(&re, n1, n0, FALSE)){
        err = SUCCESS;
        re->pinned = pinned;
      }
    }
//    printf_TMP("%x\r\n", err);
//    call CXRoutingTable.dumpTable();

    return err;
  }

  command uint8_t CXRoutingTable.getBufferWidth(){
    return CX_BUFFER_WIDTH;
  }

  command error_t CXRoutingTable.isBetween(am_addr_t n0, am_addr_t n1,
      bool bdOK, bool* result){
    if (n0 == AM_BROADCAST_ADDR || n1 == AM_BROADCAST_ADDR 
        || n0 == TOS_NODE_ID || n1== TOS_NODE_ID){
      *result = TRUE;
      return SUCCESS;
    }
    {
      uint8_t sm = call CXRoutingTable.selectionDistance(n0, 
        TOS_NODE_ID, bdOK);
      if (sm < 0xff){
        uint8_t md = call CXRoutingTable.selectionDistance(TOS_NODE_ID,
          n1, bdOK);
        if (md < 0xff){
          uint8_t sd = call CXRoutingTable.advertiseDistance(n0, n1,
            bdOK);
          if (sd < 0xff){
            *result = sm + md <= sd + call CXRoutingTable.getBufferWidth();
            if (! *result){
              printf_ROUTING_TABLE("~");
            }
            printf_ROUTING_TABLE("IB %u->%u %u %u %u\r\n", 
              n0,
              n1,
              sm,
              md,
              sd);
            return SUCCESS;
          }else{
            printf_ROUTING_TABLE("~IB %u -> %u sd UNK\r\n", n0, n1);
          }
        }else{
          printf_ROUTING_TABLE("~IB %u -> %u md UNK\r\n", n0, n1);
        }
      }else{
        printf_ROUTING_TABLE("~IB %u -> %u sm UNK\r\n", n0, n1);
      }
      return FAIL;
    }
  }
}

