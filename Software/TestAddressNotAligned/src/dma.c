
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


void DMA_init(uint32_t channelNumber, uint32_t sourceAddress, uint32_t destinationAddress, uint32_t transferNumber, 
                betriebsmodus_t betrieb, bool_t byteTransfer, bool_t IRFreigabe, bool_t exEreignisEn)
{
    uint32_t controlRegVal = 0;

    controlRegVal = controlRegVal | ((exEreignisEn << 4) | (IRFreigabe << 3)  |  (byteTransfer << 2) | betrieb);

    if(CHANNEL_0 == channelNumber)
    {
        //Source Address configuration
        out32(DMA_BASE + DMA_SAR0, sourceAddress);

        //Destination Address configuration
        out32(DMA_BASE + DMA_DESTR0, destinationAddress);

        //Number of transfers
        out32(DMA_BASE + DMA_TRAAR0, transferNumber);

        //Control Register
        out32(DMA_BASE + DMA_CR0, controlRegVal);
    }
    else if(CHANNEL_1 == channelNumber)
    {
        //Source Address configuration
        out32(DMA_BASE + DMA_SAR1, sourceAddress);

        //Destination Address configuration
        out32(DMA_BASE + DMA_DESTR1, destinationAddress);

        //Number of transfers
        out32(DMA_BASE + DMA_TRAAR1, transferNumber);

        //Control Register
        out32(DMA_BASE + DMA_CR1, controlRegVal);
    }
    else if(CHANNEL_2 == channelNumber)
    {
        //Source Address configuration
        out32(DMA_BASE + DMA_SAR2, sourceAddress);

        //Destination Address configuration
        out32(DMA_BASE + DMA_DESTR2, destinationAddress);

        //Number of transfers
        out32(DMA_BASE + DMA_TRAAR2, transferNumber);

        //Control Register
        out32(DMA_BASE + DMA_CR2, controlRegVal);
    }
    else if(CHANNEL_3 == channelNumber)
    {
        //Source Address configuration
        out32(DMA_BASE + DMA_SAR3, sourceAddress);

        //Destination Address configuration
        out32(DMA_BASE + DMA_DESTR3, destinationAddress);

        //Number of transfers
        out32(DMA_BASE + DMA_TRAAR3, transferNumber);

        //Control Register
        out32(DMA_BASE + DMA_CR3, controlRegVal);
    }

    	// enable interrupt for DMA
	    cpu_enable_interrupt(DMA_INTR);
}


void ChannelEnable(uint32_t channelNumber, uint32_t ControlRegisterValue)
{
    if(CHANNEL_0 == channelNumber)
    {
        out32(DMA_BASE + DMA_CR0, ControlRegisterValue | CHANNEL_EN);
    }
    else if (CHANNEL_1 == channelNumber)
    {
        out32(DMA_BASE + DMA_CR1, ControlRegisterValue | CHANNEL_EN);
    }
    else if (CHANNEL_2 == channelNumber) 
    {
        out32(DMA_BASE + DMA_CR2, ControlRegisterValue | CHANNEL_EN);
    }
    else if (CHANNEL_3 == channelNumber)
    {
        out32(DMA_BASE + DMA_CR3, ControlRegisterValue | CHANNEL_EN);
    }
}

void InterruptAck(uint32_t channelNumber, uint32_t ControlRegisterValue)
{
    if(CHANNEL_0 == channelNumber)
    {
        out32(DMA_BASE + DMA_CR0, ControlRegisterValue | CHANNEL_IR_ACK);
    }
    else if (CHANNEL_1 == channelNumber)
    {
        out32(DMA_BASE + DMA_CR1, ControlRegisterValue | CHANNEL_IR_ACK);
    }
    else if (CHANNEL_2 == channelNumber)
    {
        out32(DMA_BASE + DMA_CR2, ControlRegisterValue | CHANNEL_IR_ACK);
    }
    else if (CHANNEL_3 == channelNumber)
    {
        out32(DMA_BASE + DMA_CR3, ControlRegisterValue | CHANNEL_IR_ACK);
    }
}


