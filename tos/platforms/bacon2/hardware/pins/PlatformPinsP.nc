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
 * @author Peter A. Bigot <pab@peoplepowerco.com>
 * @author Doug Carlson <carlson@cs.jhu.edu> 
 */

module PlatformPinsP {
  provides {
    interface Init;
  }
}

implementation {

  command error_t Init.init() {
    atomic {
    
#if defined(__msp430_have_port1) || defined(__MSP430_HAS_PORT1__) || defined(__MSP430_HAS_PORT1_R__)
      //p1.0 is NC terminal of VCC1WB SPDT switch: should be gnd to
      //power down
      //p1.2 SPI_SOMI
      //P1.3 SPI_SIMO
      //P1.4 SPI_CLK
      //P1.5 RXD
      //P1.6 TXD
      //p1.7 FLASH CS#
      P1DIR = 0xFF;
      //p1.7 is flash nCS, set high
      P1OUT = 0x80;            
#endif 
    
#if defined(__msp430_have_port2) || defined(__MSP430_HAS_PORT2__) || defined(__MSP430_HAS_PORT2_R__)
      //P2.0: VBAT sense (input? out to gnd?)
      //P2.1: FLASH_EN (gnd)
      //P2.2: light sense (input? out to gnd?)
      //P2.3: NC (out gnd)
      //P2.4: CARD_DET (nc by default, out gnd)
      //P2.5: thermistor sense (input? out to gnd?)
      //P2.6/2.7: I2C (out to GND)
      P2DIR = BIT0|BIT1|BIT2|BIT3|BIT4|BIT5|BIT6|BIT7;
      P2OUT = BIT6|BIT7;
#endif 
    
#if defined(__msp430_have_port3) || defined(__MSP430_HAS_PORT3__) || defined(__MSP430_HAS_PORT3_R__)
      P3DIR = 0xFF;
      //P3.0/1/2: LEDs out to vcc
      //P3.3: photo shutdown (out vcc)
      //P3.7: 1WBEN: bus vcc enable (gnd out=leave COM->NC connected)
      P3OUT = 0x0F;//0x87;
#endif 

#if defined(__msp430_have_port4) || defined(__MSP430_HAS_PORT4__) || defined(__MSP430_HAS_PORT4_R__)
      P4DIR = 0xFF;
      P4OUT = 0x0;
#endif 
    
#if defined(__msp430_have_port5) || defined(__MSP430_HAS_PORT5__) || defined(__MSP430_HAS_PORT5_R__)

  #ifdef XT1_AVAILABLE
  //when P5SEL.0 is set:
  //  If we're not operating in bypass mode (i.e. it's a real crystal
  //  and not a digital clock signal), P5SEL.1 is
  //  also don't-care (will be configured as needed for xtal)
  // according to datasheet, DIR is don't-care for these, but it seems
  // like in practce, that's *not* true (when DIR is set, XT1 fault
  // never clears)
      P5DIR = 0xFC;
      P5SEL = 0x03;
      P5OUT = 0x00;
  #else
      P5DIR = 0xFF;
      P5OUT = 0x00;
  #endif
#endif 

#if defined(__msp430_have_port6) || defined(__MSP430_HAS_PORT6__) || defined(__MSP430_HAS_PORT6_R__)
      P6DIR = 0xFF;
      P6OUT = 0x0;
#endif 
    
#if defined(__msp430_have_port7) || defined(__MSP430_HAS_PORT7__) || defined(__MSP430_HAS_PORT7_R__)
      P7DIR = 0xFF;
      P7OUT = 0x0;
#endif 
    
#if defined(__msp430_have_port8) || defined(__MSP430_HAS_PORT8__) || defined(__MSP430_HAS_PORT8_R__)
      P8DIR = 0xFF;
      P8OUT = 0x0;
#endif 
    
#if defined(__msp430_have_port9) || defined(__MSP430_HAS_PORT9__) || defined(__MSP430_HAS_PORT9_R__)
      P9DIR = 0xFF;
      P9OUT = 0x0;
#endif 
    
#if defined(__msp430_have_port10) || defined(__MSP430_HAS_PORT10__) || defined(__MSP430_HAS_PORT10_R__)
      P10DIR = 0xFF;
      P10OUT = 0x0;
#endif 
    
#if defined(__msp430_have_port11) || defined(__MSP430_HAS_PORT11__) || defined(__MSP430_HAS_PORT11_R__)
      P11DIR = 0xFF;
      P11OUT = 0x0;
#endif 
    
#if defined(__msp430_have_portJ) || defined(__MSP430_HAS_PORTJ__) || defined(__MSP430_HAS_PORTJ_R__)
      //PJ.1/J.2: gnd out
      PJDIR = 0xFF;
      PJOUT = 0x00;
#endif 

#if 0 /* Disabled: these specific setting sare defaults, but others might not be */
      PMAPPWD = PMAPPW;                         // Get write-access to port mapping regs  
      P1MAP5 = PM_UCA0RXD;                      // Map UCA0RXD output to P1.5
      P1MAP6 = PM_UCA0TXD;                      // Map UCA0TXD output to P1.6
      PMAPPWD = 0;                              // Lock port mapping registers 
#endif //

    }
    return SUCCESS;

  }
  
}
