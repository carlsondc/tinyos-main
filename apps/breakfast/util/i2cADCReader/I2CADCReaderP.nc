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

#include "I2CADCReader.h"
module I2CADCReaderP{
  uses interface I2CComSlave;
  uses interface Msp430Adc12SingleChannel;
  uses interface Resource;
  uses interface GeneralIO as SensorPower[uint8_t channelNum];
  uses interface Timer<TMilli>;
  uses interface LocalTime<T32khz>;
  provides interface AdcConfigure<const msp430adc12_channel_config_t*>;
} implementation {
  uint16_t medianBuf[ADC_NUM_SAMPLES];
  i2c_message_t msg_internal;
  i2c_message_t* msg = &msg_internal;
  norace adc_response_t* response;
  norace adc_reader_pkt_t* settings;

  bool processingCommand;
  norace uint8_t channelNum;
  uint8_t channelStart;
  
  //this is pretty bad: this config is in no way going to be constant.
  //
  //Additionally, since the reference voltage usage might differ from
  //channel to channel, we need to issue a separate resource.request
  //for each of them. 
  //
  //The cleanest way to do this (and it's not clean at all) might be
  // to instantiate one Msp430Adc12ClientAutoRVGC per channel
  // (macro?), then wire to array-type interfaces for this module. So,
  // when we get AdcConfigure.getConfiguration[uint8_t clientId](), we
  // return &(settings->cfg[clientId].config). We still need to
  // release/request resources willity-nillity, but maybe it's not
  // horrible...
  async command const msp430adc12_channel_config_t* AdcConfigure.getConfiguration(){
    return &(settings->cfg[channelNum].config);
  }

  task void readyNextSample();

  task void startSamples(){
    response = (adc_response_t*) call I2CComSlave.getPayload(msg);
    channelNum = 0;
    call Resource.request();
  }

  void nextSample(){
    call Msp430Adc12SingleChannel.configureMultiple(
      &(settings->cfg[channelNum].config),
      medianBuf, ADC_NUM_SAMPLES, settings->cfg[channelNum].samplePeriod);
    
    response->samples[channelNum].sampleTime = call LocalTime.get();
    call Msp430Adc12SingleChannel.getData();
  }

  uint16_t median(uint16_t* mb, uint8_t len){
    uint8_t i, j;
    for(i = 0; i < len; i++){
      uint8_t l, g;
      for (j = 0; j < len; j++){
        if ( mb[j] < mb[i]) {
          l++;
        } else if (mb[j] > mb[i]){
          g++;
        }
      }
      if ( l <= (len/2) && g <= (len/2)){
        return mb[i];
      }
    }
    return mb[0];
  }

  async event uint16_t* Msp430Adc12SingleChannel.multipleDataReady(uint16_t * buffer, uint16_t numSamples){
    uint32_t sampleEnd = call LocalTime.get();
    //turn it off
    if (settings -> cfg[channelNum].config.inch <= 7){
      call SensorPower.clr[settings->cfg[channelNum].config.inch]();
    }

    //save relevant info
    response->samples[channelNum].inputChannel = settings->cfg[channelNum].config.inch;
    response->samples[channelNum].sampleTime = (response->samples[channelNum].sampleTime + sampleEnd) >> 1;
    response -> samples[channelNum].sample = median(medianBuf,
      numSamples);

    //switch to the next setting
    channelNum++;
    post readyNextSample();

    //according to interface, return value is ignored for this
    //invocation (since we used configureMultiple)
    return NULL; 
  }

  event void Timer.fired(){
    nextSample();
  }

  task void readyNextSample(){
    if ( channelNum == ADC_NUM_CHANNELS || 
        settings->cfg[channelNum].config.inch == INPUT_CHANNEL_NONE){
      uint8_t i;
      //done: out of channels, or end marker
      call Resource.release();
      for(i=channelNum; i < ADC_NUM_CHANNELS; i++){
        response->samples[i].inputChannel = INPUT_CHANNEL_NONE;
        response->samples[i].sampleTime = 0;
        response->samples[i].sample = 0xff;
      }
      call I2CComSlave.unpause();
      //at some point, we'll get the transactionStart and read it back
      //Note that from the master's perspective, it will be able to
      //start the next transaction, but it won't be able to read/write
      //anything until we unpause here. If that disturbs the power
      //supply sufficiently to affect the ADC reading, then trouble
      //could ensue.
    } else {
      if (settings->cfg[channelNum].config.inch <= 7){
        call SensorPower.set[settings->cfg[channelNum].config.inch]();
      }
      if (settings->cfg[channelNum].delayMS != 0){
        call Timer.startOneShot(settings->cfg[channelNum].delayMS);
      } else{
        nextSample();
      }
    }
  }

  event void Resource.granted(){
    post readyNextSample();
  }

  async event i2c_message_t* I2CComSlave.slaveTXStart(i2c_message_t* msg_){
    return swapBuffer(msg_, &msg);
  }

  async event i2c_message_t* I2CComSlave.received(i2c_message_t* msg_){
    adc_reader_pkt_t* pl = (adc_reader_pkt_t*) call I2CComSlave.getPayload(msg_);
    switch (pl->cmd){
      case ADC_READER_CMD_SAMPLE:
        call I2CComSlave.pause();
        post startSamples();
        //swap it so we can read out the settings
        settings = pl;
        return swapBuffer(msg_, &msg);
      default:
        break;
    }
    return msg_;
  }

  //unused
  async event error_t Msp430Adc12SingleChannel.singleDataReady(uint16_t data){ return FAIL;}
  
  //defaults
  default async command void SensorPower.set[uint8_t channelNum_](){}
  default async command void SensorPower.clr[uint8_t channelNum_](){}
  default async command void SensorPower.toggle[uint8_t channelNum_](){}
  default async command bool SensorPower.get[uint8_t channelNum_](){}
  default async command void SensorPower.makeInput[uint8_t channelNum_](){}
  default async command bool SensorPower.isInput[uint8_t channelNum_](){}
  default async command void SensorPower.makeOutput[uint8_t channelNum_](){}
  default async command bool SensorPower.isOutput[uint8_t channelNum_](){}
}
