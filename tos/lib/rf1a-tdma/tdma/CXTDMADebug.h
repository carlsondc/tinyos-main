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

#ifndef CX_TDMA_DEBUG_H
#define CX_TDMA_DEBUG_H

#ifdef TDMA_PIN_DEBUG_ON
#define TDMA_TOGGLE_PIN(PORT,PIN) PORT ^= PIN
#define TDMA_CLEAR_PIN(PORT,PIN)  PORT &= ~PIN
#define TDMA_SET_PIN(PORT,PIN)    PORT |= PIN

#else
#define TDMA_TOGGLE_PIN(PORT,PIN) 
#define TDMA_CLEAR_PIN(PORT,PIN)  
#define TDMA_SET_PIN(PORT,PIN)    
#endif

#if defined PORT_FS_TIMING && defined PIN_FS_TIMING 
#define FS_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_FS_TIMING, PIN_FS_TIMING)
#define FS_CLEAR_PIN TDMA_CLEAR_PIN(PORT_FS_TIMING, PIN_FS_TIMING)
#define FS_SET_PIN TDMA_SET_PIN(PORT_FS_TIMING, PIN_FS_TIMING)
#else 
#define FS_TOGGLE_PIN 
#define FS_CLEAR_PIN 
#define FS_SET_PIN 
#endif

#if defined PORT_PFS_TIMING && defined PIN_PFS_TIMING 
#define PFS_TIMING_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_PFS_TIMING, PIN_PFS_TIMING)
#define PFS_TIMING_CLEAR_PIN TDMA_CLEAR_PIN(PORT_PFS_TIMING, PIN_PFS_TIMING)
#define PFS_TIMING_SET_PIN TDMA_SET_PIN(PORT_PFS_TIMING, PIN_PFS_TIMING)
#else 
#define PFS_TIMING_TOGGLE_PIN 
#define PFS_TIMING_CLEAR_PIN 
#define PFS_TIMING_SET_PIN 
#endif

#if defined PORT_SC_TIMING && defined PIN_SC_TIMING 
#define SC_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_SC_TIMING, PIN_SC_TIMING)
#define SC_CLEAR_PIN TDMA_CLEAR_PIN(PORT_SC_TIMING, PIN_SC_TIMING)
#define SC_SET_PIN TDMA_SET_PIN(PORT_SC_TIMING, PIN_SC_TIMING)
#else 
#define SC_TOGGLE_PIN 
#define SC_CLEAR_PIN 
#define SC_SET_PIN 
#endif


#if defined PORT_FW_TIMING && defined PIN_FW_TIMING 
#define FW_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_FW_TIMING, PIN_FW_TIMING)
#define FW_CLEAR_PIN TDMA_CLEAR_PIN(PORT_FW_TIMING, PIN_FW_TIMING)
#define FW_SET_PIN TDMA_SET_PIN(PORT_FW_TIMING, PIN_FW_TIMING)
#else 
#define FW_TOGGLE_PIN 
#define FW_CLEAR_PIN 
#define FW_SET_PIN 
#endif

#if defined PORT_SS_TIMING && defined PIN_SS_TIMING 
#define SS_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_SS_TIMING, PIN_SS_TIMING)
#define SS_CLEAR_PIN TDMA_CLEAR_PIN(PORT_SS_TIMING, PIN_SS_TIMING)
#define SS_SET_PIN TDMA_SET_PIN(PORT_SS_TIMING, PIN_SS_TIMING)
#else 
#define SS_TOGGLE_PIN 
#define SS_CLEAR_PIN 
#define SS_SET_PIN 
#endif

#if defined PORT_TX_TIMING && defined PIN_TX_TIMING 
#define TX_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_TX_TIMING, PIN_TX_TIMING)
#define TX_CLEAR_PIN TDMA_CLEAR_PIN(PORT_TX_TIMING, PIN_TX_TIMING)
#define TX_SET_PIN TDMA_SET_PIN(PORT_TX_TIMING, PIN_TX_TIMING)
#else 
#define TX_TOGGLE_PIN 
#define TX_CLEAR_PIN 
#define TX_SET_PIN 
#endif

#if defined PORT_TXCP_TIMING && defined PIN_TXCP_TIMING 
#define TXCP_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_TXCP_TIMING, PIN_TXCP_TIMING)
#define TXCP_CLEAR_PIN TDMA_CLEAR_PIN(PORT_TXCP_TIMING, PIN_TXCP_TIMING)
#define TXCP_SET_PIN TDMA_SET_PIN(PORT_TXCP_TIMING, PIN_TXCP_TIMING)
#else 
#define TXCP_TOGGLE_PIN 
#define TXCP_CLEAR_PIN 
#define TXCP_SET_PIN 
#endif

#if defined PORT_PFS_CYCLE && defined PIN_PFS_CYCLE 
#define PFS_CYCLE_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_PFS_CYCLE, PIN_PFS_CYCLE)
#define PFS_CYCLE_CLEAR_PIN TDMA_CLEAR_PIN(PORT_PFS_CYCLE, PIN_PFS_CYCLE)
#define PFS_CYCLE_SET_PIN TDMA_SET_PIN(PORT_PFS_CYCLE, PIN_PFS_CYCLE)
#else 
#define PFS_CYCLE_TOGGLE_PIN 
#define PFS_CYCLE_CLEAR_PIN 
#define PFS_CYCLE_SET_PIN 
#endif

#if defined PORT_FS_CYCLE && defined PIN_FS_CYCLE 
#define FS_CYCLE_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_FS_CYCLE, PIN_FS_CYCLE)
#define FS_CYCLE_CLEAR_PIN TDMA_CLEAR_PIN(PORT_FS_CYCLE, PIN_FS_CYCLE)
#define FS_CYCLE_SET_PIN TDMA_SET_PIN(PORT_FS_CYCLE, PIN_FS_CYCLE)
#else 
#define FS_CYCLE_TOGGLE_PIN 
#define FS_CYCLE_CLEAR_PIN 
#define FS_CYCLE_SET_PIN 
#endif

#if defined PORT_GP && defined PIN_GP 
#define GP_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_GP, PIN_GP)
#define GP_CLEAR_PIN TDMA_CLEAR_PIN(PORT_GP, PIN_GP)
#define GP_SET_PIN TDMA_SET_PIN(PORT_GP, PIN_GP)
#else 
#define GP_TOGGLE_PIN 
#define GP_CLEAR_PIN 
#define GP_SET_PIN 
#endif

#if DEBUG_TDMA_SS == 1
#define printf_TDMA_SS(...) printf(__VA_ARGS__)
#else
#define printf_TDMA_SS(...) 
#endif

#if DEBUG_PFS == 1
#define printf_PFS(...) printf(__VA_ARGS__)
#else
#define printf_PFS(...) 
#endif

#if DEBUG_PFS_FREAKOUT == 1
#define printf_PFS_FREAKOUT(...) printf(__VA_ARGS__)
#else
#define printf_PFS_FREAKOUT(...) 
#endif

#if DEBUG_PHY_TIME == 1
#define printf_PHY_TIME(...) printf(__VA_ARGS__)
#else
#define printf_PHY_TIME(...) 
#endif

#if DEBUG_RADIO_STATS == 1
#define printf_RADIO_STATS(...) printf(__VA_ARGS__)
#else
#define printf_RADIO_STATS(...) 
#endif

#if DEBUG_SYNCH_ADJUST == 1
#define printf_SYNCH_ADJUST(...) printf(__VA_ARGS__)
#else
#define printf_SYNCH_ADJUST(...) 
#endif

#if DEBUG_CONFIG == 1
#define printf_DEBUG_CONFIG(...) printf(__VA_ARGS__)
#else
#define printf_DEBUG_CONFIG(...) 
#endif

#if DEBUG_RXREADY_ERROR == 1
#define printf_RXREADY_ERROR(...) printf(__VA_ARGS__)
#else
#define printf_RXREADY_ERROR(...) 
#endif

#if DEBUG_LINK_RXTX == 1
#define printf_LINK_RXTX(...) printf(__VA_ARGS__)
#else
#define printf_LINK_RXTX(...) 
#endif

#if defined PORT_FS_STROBE && defined PIN_FS_STROBE 
#define FS_STROBE_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_FS_STROBE, PIN_FS_STROBE)
#define FS_STROBE_CLEAR_PIN TDMA_CLEAR_PIN(PORT_FS_STROBE, PIN_FS_STROBE)
#define FS_STROBE_SET_PIN TDMA_SET_PIN(PORT_FS_STROBE, PIN_FS_STROBE)
#else 
#define FS_STROBE_TOGGLE_PIN 
#define FS_STROBE_CLEAR_PIN 
#define FS_STROBE_SET_PIN 
#endif

#if defined PORT_STROBE && defined PIN_STROBE 
#define STROBE_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_STROBE, PIN_STROBE)
#define STROBE_CLEAR_PIN TDMA_CLEAR_PIN(PORT_STROBE, PIN_STROBE)
#define STROBE_SET_PIN TDMA_SET_PIN(PORT_STROBE, PIN_STROBE)
#else 
#define STROBE_TOGGLE_PIN 
#define STROBE_CLEAR_PIN 
#define STROBE_SET_PIN 
#endif

#if defined PORT_GETPACKET && defined PIN_GETPACKET 
#define GETPACKET_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_GETPACKET, PIN_GETPACKET)
#define GETPACKET_CLEAR_PIN TDMA_CLEAR_PIN(PORT_GETPACKET, PIN_GETPACKET)
#define GETPACKET_SET_PIN TDMA_SET_PIN(PORT_GETPACKET, PIN_GETPACKET)
#else 
#define GETPACKET_TOGGLE_PIN 
#define GETPACKET_CLEAR_PIN 
#define GETPACKET_SET_PIN 
#endif

#if defined PORT_LOADFIFO && defined PIN_LOADFIFO 
#define LOADFIFO_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_LOADFIFO, PIN_LOADFIFO)
#define LOADFIFO_CLEAR_PIN TDMA_CLEAR_PIN(PORT_LOADFIFO, PIN_LOADFIFO)
#define LOADFIFO_SET_PIN TDMA_SET_PIN(PORT_LOADFIFO, PIN_LOADFIFO)
#else 
#define LOADFIFO_TOGGLE_PIN 
#define LOADFIFO_CLEAR_PIN 
#define LOADFIFO_SET_PIN 
#endif

#if defined PORT_IS_TX && defined PIN_IS_TX 
#define IS_TX_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_IS_TX, PIN_IS_TX)
#define IS_TX_CLEAR_PIN TDMA_CLEAR_PIN(PORT_IS_TX, PIN_IS_TX)
#define IS_TX_SET_PIN TDMA_SET_PIN(PORT_IS_TX, PIN_IS_TX)
#else 
#define IS_TX_TOGGLE_PIN 
#define IS_TX_CLEAR_PIN 
#define IS_TX_SET_PIN 
#endif

#if defined PORT_RX_READY && defined PIN_RX_READY 
#define RX_READY_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_RX_READY, PIN_RX_READY)
#define RX_READY_CLEAR_PIN TDMA_CLEAR_PIN(PORT_RX_READY, PIN_RX_READY)
#define RX_READY_SET_PIN TDMA_SET_PIN(PORT_RX_READY, PIN_RX_READY)
#else 
#define RX_READY_TOGGLE_PIN 
#define RX_READY_CLEAR_PIN 
#define RX_READY_SET_PIN 
#endif

#if defined PORT_REPORT_STATS && defined PIN_REPORT_STATS 
#define REPORT_STATS_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_REPORT_STATS, PIN_REPORT_STATS)
#define REPORT_STATS_CLEAR_PIN TDMA_CLEAR_PIN(PORT_REPORT_STATS, PIN_REPORT_STATS)
#define REPORT_STATS_SET_PIN TDMA_SET_PIN(PORT_REPORT_STATS, PIN_REPORT_STATS)
#else 
#define REPORT_STATS_TOGGLE_PIN 
#define REPORT_STATS_CLEAR_PIN 
#define REPORT_STATS_SET_PIN 
#endif

#if defined PORT_SYNCH && defined PIN_SYNCH 
#define SYNCH_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_SYNCH, PIN_SYNCH)
#define SYNCH_CLEAR_PIN TDMA_CLEAR_PIN(PORT_SYNCH, PIN_SYNCH)
#define SYNCH_SET_PIN TDMA_SET_PIN(PORT_SYNCH, PIN_SYNCH)
#else 
#define SYNCH_TOGGLE_PIN 
#define SYNCH_CLEAR_PIN 
#define SYNCH_SET_PIN 
#endif

#if defined PORT_HPL_ATOMIC && defined PIN_HPL_ATOMIC 
#define HPL_ATOMIC_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_HPL_ATOMIC, PIN_HPL_ATOMIC)
#define HPL_ATOMIC_CLEAR_PIN TDMA_CLEAR_PIN(PORT_HPL_ATOMIC, PIN_HPL_ATOMIC)
#define HPL_ATOMIC_SET_PIN TDMA_SET_PIN(PORT_HPL_ATOMIC, PIN_HPL_ATOMIC)
#else 
#define HPL_ATOMIC_TOGGLE_PIN 
#define HPL_ATOMIC_CLEAR_PIN 
#define HPL_ATOMIC_SET_PIN 
#endif

#if defined PORT_RESYNCH && defined PIN_RESYNCH 
#define RESYNCH_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_RESYNCH, PIN_RESYNCH)
#define RESYNCH_CLEAR_PIN TDMA_CLEAR_PIN(PORT_RESYNCH, PIN_RESYNCH)
#define RESYNCH_SET_PIN TDMA_SET_PIN(PORT_RESYNCH, PIN_RESYNCH)
#else 
#define RESYNCH_TOGGLE_PIN 
#define RESYNCH_CLEAR_PIN 
#define RESYNCH_SET_PIN 
#endif

#if defined PORT_FWA_TIMING && defined PIN_FWA_TIMING 
#define FWA_TIMING_TOGGLE_PIN TDMA_TOGGLE_PIN(PORT_FWA_TIMING, PIN_FWA_TIMING)
#define FWA_TIMING_CLEAR_PIN TDMA_CLEAR_PIN(PORT_FWA_TIMING, PIN_FWA_TIMING)
#define FWA_TIMING_SET_PIN TDMA_SET_PIN(PORT_FWA_TIMING, PIN_FWA_TIMING)
#else 
#define FWA_TIMING_TOGGLE_PIN 
#define FWA_TIMING_CLEAR_PIN 
#define FWA_TIMING_SET_PIN 
#endif

#ifndef DEBUG_CONFIG
#define DEBUG_CONFIG 0
#endif

#endif
