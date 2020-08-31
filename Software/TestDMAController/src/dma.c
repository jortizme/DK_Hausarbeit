
/*
-------------------------------------------------------------------------------
-- dma.c
-------------------------------------------------------------------------------
-- Modul Digitale Komponenten
-- Hochschule Osnabrueck
-- Joaquin Ortiz, Filip Mijac
-------------------------------------------------------------------------------
*/

#include <dma.h>
#include <config.h>
#include <cpu.h>


void DMA_init(Config_Channel_Info* Channel)
{
    uint32_t controlRegVal = 0;

    controlRegVal = controlRegVal | ((Channel->ExEreignisEn << 4) | (Channel->IRFreigabe << 3)  |  (Channel->ByteTransfer << 2) | Channel->Betriebsmodus);

    if(CHANNEL_0 == Channel->ChannelNumber)
    {
        //Source Address configuration
        out32(DMA_BASE + DMA_SAR0, Channel->SourceAddress);

        //Destination Address configuration
        out32(DMA_BASE + DMA_DESTR0, Channel->DestinationAddress);

        //Number of transfers
        out32(DMA_BASE + DMA_TRAAR0, Channel->TransferNumber);

        //Control Register
        out32(DMA_BASE + DMA_CR0, controlRegVal);
    }
    else if(CHANNEL_1 == Channel->ChannelNumber)
    {
        //Source Address configuration
        out32(DMA_BASE + DMA_SAR1, Channel->SourceAddress);

        //Destination Address configuration
        out32(DMA_BASE + DMA_DESTR1, Channel->DestinationAddress);

        //Number of transfers
        out32(DMA_BASE + DMA_TRAAR1, Channel->TransferNumber);

        //Control Register
        out32(DMA_BASE + DMA_CR1, controlRegVal);
    }
    else if(CHANNEL_2 == Channel->ChannelNumber)
    {
        //Source Address configuration
        out32(DMA_BASE + DMA_SAR2, Channel->SourceAddress);

        //Destination Address configuration
        out32(DMA_BASE + DMA_DESTR2, Channel->DestinationAddress);

        //Number of transfers
        out32(DMA_BASE + DMA_TRAAR2, Channel->TransferNumber);

        //Control Register
        out32(DMA_BASE + DMA_CR2, controlRegVal);
    }
    else if(CHANNEL_3 == Channel->ChannelNumber)
    {
        //Source Address configuration
        out32(DMA_BASE + DMA_SAR3, Channel->SourceAddress);

        //Destination Address configuration
        out32(DMA_BASE + DMA_DESTR3, Channel->DestinationAddress);

        //Number of transfers
        out32(DMA_BASE + DMA_TRAAR3, Channel->TransferNumber);

        //Control Register
        out32(DMA_BASE + DMA_CR3, controlRegVal);
    }

    	// enable interrupt for DMA
	    cpu_enable_interrupt(DMA_INTR);
}


void ChannelEnable(Config_Channel_Info* Channel)
{
    if(CHANNEL_0 == Channel->ChannelNumber)
    {
        out32(DMA_BASE + DMA_CR0, Channel->ControlRegVal | CHANNEL_EN);
    }
    else if (CHANNEL_1 == Channel->ChannelNumber)
    {
        out32(DMA_BASE + DMA_CR1, Channel->ControlRegVal | CHANNEL_EN);
    }
    else if (CHANNEL_2 == Channel->ChannelNumber)
    {
        out32(DMA_BASE + DMA_CR2, Channel->ControlRegVal | CHANNEL_EN);
    }
    else if (CHANNEL_3 == Channel->ChannelNumber)
    {
        out32(DMA_BASE + DMA_CR3, Channel->ControlRegVal | CHANNEL_EN);
    }
}

void InterruptAck(Config_Channel_Info* Channel)
{
    if(CHANNEL_0 == Channel->ChannelNumber)
    {
        out32(DMA_BASE + DMA_CR0, Channel->ControlRegVal | CHANNEL_IR_ACK);
    }
    else if (CHANNEL_1 == Channel->ChannelNumber)
    {
        out32(DMA_BASE + DMA_CR1, Channel->ControlRegVal | CHANNEL_IR_ACK);
    }
    else if (CHANNEL_2 == Channel->ChannelNumber)
    {
        out32(DMA_BASE + DMA_CR2, Channel->ControlRegVal | CHANNEL_IR_ACK);
    }
    else if (CHANNEL_3 == Channel->ChannelNumber)
    {
        out32(DMA_BASE + DMA_CR3, Channel->ControlRegVal | CHANNEL_IR_ACK);
    }
}


