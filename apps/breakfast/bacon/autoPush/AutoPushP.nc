 
 #include "RecordStorage.h"
 #include "AutoPush.h"
generic module AutoPushP(){
  uses interface Boot;
  uses interface LogWrite;
  uses interface SettingsStorage;
  uses interface LogNotify;
  uses interface AMSend;
  uses interface LogRead;

  uses interface Pool<message_t>;
  uses interface Get<am_addr_t>;
} implementation {
  enum {
    S_INIT = 0,
    S_SEEK_BEGINNING = 1,
    S_SEEK_END = 2,
    S_IDLE = 3,
    S_READING = 4,
    S_READ = 5,
    S_SENDING = 6,
    S_ERROR = 0xff,
  };
  uint8_t state = S_INIT;
  
  log_record_t* recordPtr = NULL;
  message_t* msg = NULL;

  uint8_t* bufferEnd;
  uint8_t* bufferStart;
  uint16_t recordsRead = 0;

  event void Boot.booted(){
    uint16_t highThreshold = DEFAULT_HIGH_PUSH_THRESHOLD;
    uint16_t lowThreshold = DEFAULT_LOW_PUSH_THRESHOLD;
    call SettingsStorage.get(SS_KEY_HIGH_PUSH_THRESHOLD,
      (uint8_t*)(&highThreshold), sizeof(highThreshold));
    call SettingsStorage.get(SS_KEY_LOW_PUSH_THRESHOLD,
      (uint8_t*)(&lowThreshold), sizeof(lowThreshold));

    call LogNotify.setHighThreshold(highThreshold);
    call LogNotify.setLowThreshold(lowThreshold);

    if (SUCCESS == call LogRead.seek(SEEK_BEGINNING)){
      state = S_SEEK_BEGINNING;
    }else{
      state = S_ERROR;
    }
  }
  
  task void seekEnd();
  event void LogRead.seekDone(error_t error){
    if (SUCCESS == error){
      if (state == S_SEEK_BEGINNING){
        printf("Seek begin OK: begin %lu end %lu\n", 
          call LogRead.currentOffset(),
          call LogWrite.currentOffset());
        post seekEnd();
      }else if (state == S_SEEK_END){
        printf("Seek end OK: %lu\n", call LogRead.currentOffset());
        state = S_IDLE;
      } else {
        //from this point on, we are just reading from current
        //position. on-demand repairs are handled by a different
        //component.
        state = S_ERROR;
      }
    } else {
      state = S_ERROR;
    }
  }

  task void seekEnd(){
    printf("Seek end -> %lu\n", call LogWrite.currentOffset());
    if (SUCCESS == call LogRead.seek(call LogWrite.currentOffset())){
      state = S_SEEK_END;
    }else{
      state = S_ERROR;
    }
  }

  task void readNext(){
    storage_len_t left = bufferEnd - (uint8_t*)recordPtr->data;
    //write cookie of current record to buffer.
    recordPtr->cookie = call LogRead.currentOffset();
    printf("rn [%lu, %lu] to %p (max %lu)\n", 
      recordPtr->cookie, call LogWrite.currentOffset(),
      recordPtr->data, left);

    //read current record: account for log_record_t's 5-byte header

    if (SUCCESS == call LogRead.read(recordPtr->data, left)){
//      printf("reading.\n");
      state = S_READING;
    }else{
      printf("ERR\n");
      state = S_ERROR;
    }
  }

  void send(){
    state = S_SENDING;
//    printf("sending\n"); 
//    printfflush();
    call AMSend.send(call Get.get(), msg, (uint8_t*)recordPtr - bufferStart);
  }

  event void LogRead.readDone(void* buf, storage_len_t len, 
      error_t error){
    state = S_READ;
//    printf("rd: %lu ", call LogRead.currentOffset());
    if(error == SUCCESS){
      recordPtr -> length = len;
      if (len == 0){
//        printf("no more data.\n");
        //no more data, send it.
        send();
        return;
      } else {
        recordsRead++;
//        printf("rp %p + (%u + %lu) ->", 
//          recordPtr, 
//          sizeof(log_record_t), 
//          len);
        //data has been read into recordPtr->data. 
        recordPtr = (log_record_t*)((uint8_t*)recordPtr 
          + (sizeof(log_record_t) + len));
//        printf("%p \n", recordPtr);
        if ((uint8_t*)recordPtr + sizeof(log_record_t) >= bufferEnd){
//          printf("no space left.\n");
          //no space for another record, send it.
          send();
          return;
        }else{
          //try the next.
          post readNext();
        }
      }
    } else if (error == ESIZE){
//      printf("couldn't fit.\n");
      //no space for another record, send it.
      send();
      return;
    } else{
      printf(" err: %x\n", error);
      state = S_ERROR;
    }
  }

  event void AMSend.sendDone(message_t* msg_, error_t error){
    //if there's more data outstanding, we'll get another
    //  sendRequested event and start the process over.
    printf("sent %p %u %x\n", msg_, recordsRead, error);
    printfflush();
    state = S_IDLE;
    call LogNotify.reportSent(recordsRead);
    call Pool.put(msg);
  }

  //TODO: handle error conditions better
  event void LogNotify.sendRequested(uint16_t left){
//    printf("%u requested\n", left);
    if (state == S_IDLE){
      msg = call Pool.get();
      if (msg != NULL){
        recordsRead = 0;
        recordPtr = (log_record_t*)(call AMSend.getPayload(msg, 
          call AMSend.maxPayloadLength()));
        bufferStart = (uint8_t*)recordPtr; 
        bufferEnd = bufferStart + call AMSend.maxPayloadLength();
//        printf("RP %p BS %p BE %p\n", recordPtr, bufferStart,
//          bufferEnd);
        post readNext();
      }else{
        state = S_ERROR;
      }
    } else {
      printf("!sr\n");
      state = S_ERROR;
    }
  }

  //unused
  event void LogWrite.syncDone(error_t error){}
  event void LogWrite.appendDone(void* buf, storage_len_t len, 
    bool recordsLost, error_t error){}
  event void LogWrite.eraseDone(error_t error){}
}