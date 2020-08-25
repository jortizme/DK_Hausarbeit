#include <dma.h>
#include <config.h>
#include <cpu.h>

//  --------------------------------------
//  DMA-System initialization
//  Joaquin Ortiz
//  Filip Mijac
//  HS-Onsnabrueck
//  ---------------------------------------


void DMA_init(uint32_t channelNumber, uint32_t sourceAddress, uint32_t destinationAddress, uint32_t transferNumber, 
                betriebsmodus_t betrieb, bool_t byteTransfer, bool_t IRFreigabe, bool_t exEreignisEn)
{
    uint32_t controlRegVal = 0;

    controlRegVal = controlRegVal | ((exEreignisEn << 4) | (IRFreigabe << 3)  |  (byteTransfer << 2) | betrieb);

    if(CHANNEL_1 == channelNumber)
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
    else if(CHANNEL_2 == channelNumber)
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

    	// enable interrupt for DMA
	    cpu_enable_interrupt(DMA_INTR);
}


void ChannelEnable(uint32_t channelNumber)
{
    if(CHANNEL_1 == channelNumber)
    {
        out32(DMA_BASE + DMA_CR0, in32(DMA_BASE + DMA_CR0) | CHANNEL_EN);
    }
    else if (CHANNEL_2 == channelNumber) 
    {
        out32(DMA_BASE + DMA_CR1, in32(DMA_BASE + DMA_CR1) | CHANNEL_EN);    
    }
}



