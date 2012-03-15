/**
 * Test CXTDMA flood component
 * 
 * @author Doug Carlson <carlson@cs.jhu.edu>
 */

#include <stdio.h>
#include "decodeError.h"
#include "message.h"
#include "CXTDMA.h"

module TestP {
  uses interface Boot;
  uses interface StdControl as UartControl;
  uses interface UartStream;

  uses interface TDMARootControl;

  uses interface SplitControl;
  uses interface AMPacket;
  uses interface Packet;

  uses interface Send;
  uses interface Receive;

  uses interface Leds;

} implementation {
  
  message_t tx_msg_internal;
  message_t* tx_msg = &tx_msg_internal;
  norace uint8_t tx_len;

  message_t rx_msg_internal;
  message_t* rx_msg = &rx_msg_internal;
  uint8_t rx_len;

  typedef nx_struct test_packet_t{
    nx_uint32_t sn;
  } test_packet_t;
  
  //schedule info
  uint16_t _framesPerSlot;
  
  norace bool isRoot = FALSE;
  norace bool isTransmitting = FALSE;

  task void printStatus(){
    printf("----\r\n");
    printf("is root: %x\r\n", isRoot);
    printf("is transmitting: %x\r\n", isTransmitting);
  }

  event void Boot.booted(){
    atomic{
      //timing pins
      P1SEL &= ~(BIT1|BIT3|BIT4);
      P1SEL |= BIT2;
      P1DIR |= (BIT1|BIT2|BIT3|BIT4);
      P2SEL &= ~(BIT4);
      P2DIR |= (BIT4);
      //set up SFD GDO on 1.2
      PMAPPWD = PMAPKEY;
      PMAPCTL = PMAPRECFG;
      P1MAP2 = PM_RFGDO0;
      PMAPPWD = 0x00;

      P1OUT &= ~(BIT1|BIT3|BIT4);
      P2OUT &= ~(BIT4);
    }
    call UartControl.start();
    printf("\r\nCXTDMA Flood test\r\n");
    printf("s: start \r\n");
    printf("S: stop \r\n");
    printf("r: root \r\n");
    printf("f: forwarder \r\n");
    printf("t: toggle is-transmitting \r\n");
    printf("?: print status\r\n");
    printf("========================\r\n");
    post printStatus();
  }

  task void setRootSchedule(){
    call TDMARootControl.setSchedule(DEFAULT_TDMA_FRAME_LEN,
        DEFAULT_TDMA_FW_CHECK_LEN, 8, 8, 2, 2);
  }

  event void SplitControl.startDone(error_t error){
//    printf("%s: %s\r\n", __FUNCTION__, decodeError(error));
    if (isRoot){
      post setRootSchedule();
    }
  }

  event void SplitControl.stopDone(error_t error){
    printf("%s: %s\r\n", __FUNCTION__, decodeError(error));
  }

  task void txTask(){
    error_t error;
    test_packet_t* pl = call Packet.getPayload(tx_msg,
      sizeof(test_packet_t));
    pl -> sn += TOS_NODE_ID;
    error = call Send.send(tx_msg, sizeof(test_packet_t));
    printf("Send.Send: %s\r\n", decodeError(error));
  }

  event void Send.sendDone(message_t* msg, error_t error){
    if (SUCCESS != error){
      printf("!sd %x\r\n", error);
    }else{
//      printf("sd\r\n");
    }
    if (isTransmitting){
      post txTask();
    }
  }

  task void startTask(){
    error_t error = call SplitControl.start();
    if (error != SUCCESS){
      printf("%s: %s\n\r", __FUNCTION__, decodeError(error)); 
    }
    post printStatus();
  }

  task void stopTask(){
    error_t error = call SplitControl.stop();
    if (error != SUCCESS){
      printf("%s: %s\n\r", __FUNCTION__, decodeError(error)); 
    }
    post printStatus();
  }

  task void becomeRoot(){
    isRoot = TRUE;
    post printStatus();
  }

  task void becomeForwarder(){
    isRoot = FALSE;
    post printStatus();
  }

  task void toggleTX(){
    isTransmitting = !isTransmitting;
    if (isTransmitting){
      post txTask();
    }
  }

  async event void UartStream.receivedByte(uint8_t byte){
    switch(byte){
      case 'q':
        WDTCTL=0;
        break;
      case 's':
        printf("Starting\r\n");
        post startTask();
        break;
      case 'S':
        printf("Stopping\r\n");
        post stopTask();
        break;
      case '?':
        post printStatus();
        break;
      case 'r':
        printf("Become Root\r\n");
        post becomeRoot();
        break;
      case 'f':
        printf("Become Forwarder\r\n");
        post becomeForwarder();
        break;
      case 't':
        printf("Toggle TX\r\n");
        post toggleTX();
        break;
      case '\r':
        printf("\r\n");
        break;
     default:
        printf("%c", byte);
        break;
    }
  }

  event bool TDMARootControl.isRoot(){
    return isRoot;
  }

  event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
    printf("RX\r\n");
    return msg;
  }

  //unused events
  async event void UartStream.receiveDone( uint8_t* buf_, uint16_t len,
    error_t error ){}
  async event void UartStream.sendDone( uint8_t* buf_, uint16_t len,
    error_t error ){}

}

/* 
 * Local Variables:
 * mode: c
 * End:
 */
