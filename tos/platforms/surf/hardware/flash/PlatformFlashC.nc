/* 
 * Copyright (c) 2009-2010 People Power Company
 * All rights reserved.
 *
 * This open source code was developed with funding from People Power Company
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * - Redistributions of source code must retain the above copyright
 *   notice, this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright
 *   notice, this list of conditions and the following disclaimer in the
 *   documentation and/or other materials provided with the
 *   distribution.
 * - Neither the name of the People Power Corporation nor the names of
 *   its contributors may be used to endorse or promote products derived
 *   from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE
 * PEOPLE POWER CO. OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
 * STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
 * OF THE POSSIBILITY OF SUCH DAMAGE
 */



/**
 * @author David Moss
 */
configuration PlatformFlashC {
  provides {
    interface Init as DriverInit;
    
    interface Resource;
    interface SpiByte;
    interface SpiPacket;
    interface Msp430UsciError;
    
    interface GeneralIO as Csn;
  }
}

implementation {

  components new Msp430UsciSpiB0C() as SpiC;
  Resource = SpiC;
  SpiByte = SpiC;
  SpiPacket = SpiC;
  Msp430UsciError = SpiC;

  components PlatformFlashInitC;

  components new Msp430GpioC() as CsnC;
  CsnC -> PlatformFlashInitC.CsnIO;
  Csn = CsnC;
  
  components PlatformFlashP;
  DriverInit = PlatformFlashP;
    
  components BusyWaitMicroC;
  PlatformFlashP.BusyWait -> BusyWaitMicroC;
  
  components NorFlashMasterC;
  PlatformFlashP.NorFlashCommands -> NorFlashMasterC;
  PlatformFlashP.Resource -> NorFlashMasterC;
  
}
