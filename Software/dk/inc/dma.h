/*
-------------------------------------------------------------------------------
-- DMA-Kontroller
-------------------------------------------------------------------------------
-- Modul Digitale Komponenten
-- Hochschule Osnabrueck
-- Joaquin Ortiz, Filip Mijac
---------------------------------------------------------------------------------------------------
-- Offsets:
-- 0x00 Source Address Kanal_1 Register         (SAR0)      (Write Only)
-- 0x04 Destination Address Kanal_1 Register    (DESTR0)    (Write Only)
-- 0x08 Transfer Antahl Kana_1 Register         (TRAAR0)    (RW)
-- 0x0C Control Register Kanal_1                (CR0)       (RW)
-- 0x10 Source Address Kanal_2 Register         (SAR1)      (Write Only)
-- 0x14 Destination Address Kanal_2 Register    (DESTR1)    (Write Only)
-- 0x18 Transfer Antahl Kana_2 Register         (TRAAR1)    (RW)
-- 0x1C Control Register Kanal_2                (CR1)       (RW)
-- 0x20 Status Register                         (SR)        (Read Only)
---------------------------------------------------------------------------------------------------
-- Control Register (CR0 - CR1):
--  1 .. 0 : Betriebsmodus
--  2      : Byte_Transfer
--  3      : Freigabe Interrupt
--  4      : Externes-Ereignis-Enable
--  8      : Kanal-Enable               (Write-Only)
--  9      : Interrupt-Quittierung      (Write-Only)

---------------------------------------------------------------------------------------------------
-- Status Register (SR):
--  0      : Kanal_1 aktiv
--  1      : Kanal_2 aktiv
--  16     : Interrupt Kanal_1  
--  17     : Interrupt Kanal_2
---------------------------------------------------------------------------------------------------
*/

#pragma once

#include <stdint.h>

#define DMA_SAR0    0x00
#define DMA_DESTR0  0x04
#define DMA_TRAAR0  0x08
#define DMA_CR0     0x0C
#define DMA_SAR1    0x10
#define DMA_DESTR1  0x14
#define DMA_TRAAR1  0x18
#define DMA_CR1     0x1C
#define DMA_SR      0x20

#define CHANNEL_1      1
#define CHANNEL_2      2
#define CHANNEL_EN      (1<<8)
#define CHANNEL_IR_ACK  (1<<9)


#define DMA_CHA0_IRQ  (1<<16)   
#define DMA_CHA1_IRQ  (1<<17)

typedef enum{
    SPEI_SPEI   = 0b00,
    PERI_SPEI   = 0b01,
    SPEI_PERI   = 0b10
}betriebsmodus_t;

typedef enum{
	FALSE		=  0b0,
	TRUE		=  0b1
}bool_t;

void DMA_init(uint32_t channelNumber, uint32_t sourceAddress, uint32_t destinationAddress, uint32_t transferNumber, 
                betriebsmodus_t betrieb, bool_t byteTransfer, bool_t IRFreigabe, bool_t exEreignisEn);

void ChannelEnable(uint32_t channelNumber);
                
