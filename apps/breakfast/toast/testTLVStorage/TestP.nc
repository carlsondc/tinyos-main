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

#include <stdio.h>
#include "InternalFlash.h"
#include "TLVStorage.h"
#include "decodeError.h"
#include "GlobalID.h"

module TestP{
  uses interface Boot;
  uses interface UartStream;
  uses interface StdControl;
  uses interface TLVStorage;
  uses interface TLVUtils;
} implementation {
  uint8_t tlvs_ba[IFLASH_SEGMENT_SIZE];

  event void Boot.booted(){
   call StdControl.start();
   printf("TLVStorage test\n\r");
  }

  async event void UartStream.sendDone(uint8_t* buf, uint16_t len, error_t err){
  }

  task void readTLVStorage(){
    error_t error = call TLVStorage.loadTLVStorage(tlvs_ba);
    tlv_entry_t* e;
    uint8_t offset = 0;
    uint8_t i;
    printf("%s: %s\n\r", __FUNCTION__, decodeError(error));
    do{
      offset = call TLVUtils.findEntry(TAG_ANY, offset+1, &e, tlvs_ba);
      if (e != NULL){
        printf("------------\n\r");
        printf(" Offset: %d\n\r", offset);
        printf(" Tag:\t[%d]\t%x\n\r", offset, e->tag);
        printf(" Len:\t[%d]\t%x\n\r", offset+1, e->len);
        if (e->tag != TAG_EMPTY){
        printf(" Data:\n\r");
        for (i = 0; i < e->len; i++){
          printf("  [%d]\t(%d)\t%x\n\r", offset+2+i, i, e->data.b[i]);
        }
        }else{
          printf("  [%d]->[%d] (empty)\n\r", offset+2,
          offset+2+e->len-1);
        }
      }
    } while( offset != 0);
  }
  
  task void addUniqueIDTag(){
    error_t error = call TLVStorage.loadTLVStorage(tlvs_ba);
    tlv_entry_t* e;
    global_id_entry_t uid;
    uint8_t offset;
    uint8_t i;
    printf("%s: %s\n\r", __FUNCTION__, decodeError(error));
    if( 0 == call TLVUtils.findEntry(TAG_GLOBAL_ID, 0, &e, tlvs_ba)){
      memset(uid.id, 0, 8);
      uid.id[7] = 1;
      offset = call TLVUtils.addEntry(TAG_GLOBAL_ID, 8, (tlv_entry_t*)&uid,
        tlvs_ba, 0);
      if (offset != 0){
        printf("Added at offset %x\n\r", offset);
        error = call TLVStorage.persistTLVStorage(tlvs_ba);
        printf("persisted: %s\n\r", decodeError(error));
      } else {
        printf("Not added!\n\r");
        return;
      }
    }else {
      printf("Unique ID already present: ");
      for ( i = 0 ; i < 8 ; i++){
        printf("%x ", ((global_id_entry_t*)e)->id[i]);
      }
      printf("\n\r");
    }
  }

  task void updateUniqueIDTag(){
    error_t error = call TLVStorage.loadTLVStorage(tlvs_ba);
    global_id_entry_t* uid;
    uint8_t offset;
    printf("%s: %s\n\r", __FUNCTION__, decodeError(error));
    offset = call TLVUtils.findEntry(TAG_GLOBAL_ID, 0, (tlv_entry_t**)&uid,
      tlvs_ba);
    if (NULL == uid){
      printf("No unique Id tag found.\n\r");
    } else {
      printf("Unique ID at offset %x\n\r", offset);
      uid->id[7] += 1;
      error = call TLVStorage.persistTLVStorage(tlvs_ba);
      printf("%s: %s\n\r", __FUNCTION__, decodeError(error));
    }
  }

  task void deleteUniqueIDTag(){
    error_t error = call TLVStorage.loadTLVStorage(tlvs_ba);
    global_id_entry_t* uid;
    uint8_t offset;
    printf("%s: %s\n\r", __FUNCTION__, decodeError(error));
    offset = call TLVUtils.findEntry(TAG_GLOBAL_ID, 0, (tlv_entry_t**)&uid,
      tlvs_ba);
    if (offset != 0){
      printf("Unique ID found at %x.\n\r", offset);
      error = call TLVUtils.deleteEntry(offset, tlvs_ba);
      printf("delete: %s\n\r", decodeError(error));
      call TLVStorage.persistTLVStorage(tlvs_ba);
      printf("persist: %s\n\r", decodeError(error));
    }else{
      printf("No Unique ID tag to delete.\n\r");
    }
  }

  async event void UartStream.receivedByte(uint8_t byte){
    switch(byte){
      case '\r':
        printf("\n\r");
        break;
      case 'a':
        post addUniqueIDTag();
        break;
      case 'u':
        post updateUniqueIDTag();
        break;
      case 'd':
        post deleteUniqueIDTag();
        break;
      case 'r':
        post readTLVStorage();
        break;
      case 'q':
        WDTCTL = 0;
        break;
      default:
        printf("%c", byte);
    }
  }

  async event void UartStream.receiveDone(uint8_t* buf, uint16_t len, error_t err){
  }

}
