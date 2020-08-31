/*
-------------------------------------------------------------------------------
-- dma.h
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
-- 0x20 Source Address Kanal_3 Register         (SAR2)      (Write Only)
-- 0x24 Destination Address Kanal_3 Register    (DESTR2)    (Write Only)
-- 0x28 Transfer Antahl Kana_3 Register         (TRAAR2)    (RW)
-- 0x2C Control Register Kanal_3                (CR2)       (RW)
-- 0x30 Source Address Kanal_4 Register         (SAR3)      (Write Only)
-- 0x34 Destination Address Kanal_4 Register    (DESTR3)    (Write Only)
-- 0x38 Transfer Antahl Kana_4 Register         (TRAAR3)    (RW)
-- 0x3C Control Register Kanal_4                (CR3)       (RW)
-- 0x40 Status Register                         (SR)        (Read Only)
---------------------------------------------------------------------------------------------------
-- Control Register (CR0 - CR3):
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
--  2      : Kanal_3 aktiv
--  3      : Kanal_4 aktiv
--  16     : Interrupt Kanal_1  
--  17     : Interrupt Kanal_2
--  18     : Interrupt Kanal_3
--  19     : Interrupt Kanal_4
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
#define DMA_SAR2    0x20
#define DMA_DESTR2  0x24
#define DMA_TRAAR2  0x28
#define DMA_CR2     0x2C
#define DMA_SAR3    0x30
#define DMA_DESTR3  0x34
#define DMA_TRAAR3  0x38
#define DMA_CR3     0x3C
#define DMA_SR      0x40

#define CHANNEL_0      1
#define CHANNEL_1      2
#define CHANNEL_2      4
#define CHANNEL_3      8
#define CHANNEL_EN      (1<<8)
#define CHANNEL_IR_ACK  (1<<9)

#define DMA_CHA0_IRQ  (1<<16)   
#define DMA_CHA1_IRQ  (1<<17)
#define DMA_CHA2_IRQ  (1<<18)
#define DMA_CHA3_IRQ  (1<<19)

typedef enum{
    SPEI_SPEI   = 0b00,
    PERI_SPEI   = 0b01,
    SPEI_PERI   = 0b10
}betriebsmodus_t;

typedef enum{
	FALSE		=  0b0,
	TRUE		=  0b1
}bool_t;

typedef struct config{

	uint32_t ChannelNumber;
	uint32_t SourceAddress;
	uint32_t DestinationAddress;
	uint32_t TransferNumber;
	betriebsmodus_t Betriebsmodus;
	bool_t ByteTransfer;
	bool_t IRFreigabe;
	bool_t ExEreignisEn;
	uint32_t ControlRegVal;
}Config_Channel_Info;

void DMA_init(Config_Channel_Info* Channel);

void ChannelEnable(Config_Channel_Info* Channel);
void InterruptAck(Config_Channel_Info* Channel);
                
