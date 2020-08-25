#include <gpio.h>
#include <uart.h>
#include <cpu.h>
#include <config.h>
#include <stdio.h>
#include <dma.h>




#define SATZ_LENGTH 64
#define PHRASE_LENGHT 512
//uint32_t uart_config;
uint32_t channel_1_config;
uint32_t channel_2_config;

#if 1
uint32_t offset;
bool_t zumSpeicher;

char Receiver_FIFO_1[SATZ_LENGTH];
char gesamtReceived[PHRASE_LENGHT];

void DMA_Handler()
{
	uint32_t status = in32(DMA_BASE + DMA_SR);

    if(status & DMA_CHA0_IRQ)
    {
    		if((status & CHANNEL_2) == 0)
    		{
    			DMA_init(CHANNEL_2, (uint32_t)Receiver_FIFO_1,(uint32_t)(gesamtReceived + offset), SATZ_LENGTH, SPEI_SPEI, FALSE, TRUE, FALSE);
    			ChannelEnable(CHANNEL_2);
    			out32(DMA_BASE + DMA_CR0, channel_1_config | CHANNEL_IR_ACK);
    			zumSpeicher = TRUE;
    			if(offset < PHRASE_LENGHT)
    			{
    				ChannelEnable(CHANNEL_1);
    			}

    		}
    		else
    		{
    			out32(DMA_BASE + DMA_CR0, channel_1_config | CHANNEL_IR_ACK);
    		}

    }

    if(status & DMA_CHA1_IRQ)
    {

    	if(zumSpeicher == FALSE)
    	{
    		out32(DMA_BASE + DMA_CR1, channel_2_config | CHANNEL_IR_ACK);

        	if((status & CHANNEL_2) == 0 && offset < PHRASE_LENGHT)
        	{
        		DMA_init(CHANNEL_2, (uint32_t)Receiver_FIFO_1,(uint32_t)gesamtReceived, SATZ_LENGTH, SPEI_SPEI, FALSE, TRUE, FALSE);
        		ChannelEnable(CHANNEL_2);
        		zumSpeicher = TRUE;
    			if(offset < PHRASE_LENGHT)
    			{
    				ChannelEnable(CHANNEL_1);
    			}
        	}
    	}
    	else
    	{
    		out32(DMA_BASE + DMA_CR1, channel_2_config | CHANNEL_IR_ACK);
    		DMA_init(CHANNEL_2, (uint32_t)(gesamtReceived + offset),UART_BASE + UART_TDR, SATZ_LENGTH, SPEI_PERI, TRUE, TRUE, TRUE);
    		ChannelEnable(CHANNEL_2);
    		offset = offset + SATZ_LENGTH;
    		zumSpeicher = FALSE;
    	}


    }

}

int main() {

	UART_Init(UART_BASE, 115200, 8, PARITY_NONE, STOPPBITS_10);
	//uart_config = in32(UART_BASE + UART_CR);
	out32(UART_BASE + UART_CR, in32(UART_BASE + UART_CR) | UART_TX_IRQ);

	DMA_init(CHANNEL_1,UART_BASE + UART_RDR, (uint32_t)Receiver_FIFO_1, SATZ_LENGTH, PERI_SPEI, TRUE, TRUE, TRUE);

	offset = 0;
	channel_1_config = in32(DMA_BASE + DMA_CR0);
	channel_2_config = in32(DMA_BASE + DMA_CR1);

	ChannelEnable(CHANNEL_1);
	zumSpeicher = TRUE;

	while(1)
	{
		//while(offset < PHRASE_LENGHT);
		//while(in32(DMA_BASE + DMA_SR) & CHANNEL_2);

		//out32(DMA_BASE + DMA_CR0, 0);
		//out32(DMA_BASE + DMA_CR1, 0);

	}

	return 0;

}
#endif

//Man bekommt vom Computer was und sendet es zur�ck ohne dass die CPU das ganze Steuert
#if 0


	void DMA_Handler()
	{
	    uint32_t status = in32(DMA_BASE + DMA_SR);

	    if(status & DMA_CHA0_IRQ)
	    {
	       out32(UART_BASE + UART_CR, uart_config | UART_TX_IRQ);
	       out32(DMA_BASE + DMA_CR0, channel_1_config | CHANNEL_IR_ACK);
	       ChannelEnable(CHANNEL_1);

	    }

	    if(status & DMA_CHA1_IRQ)
	    {
	        out32(UART_BASE + UART_CR, uart_config & ~UART_TX_IRQ);
	        out32(DMA_BASE + DMA_CR1, channel_2_config | CHANNEL_IR_ACK);
	        ChannelEnable(CHANNEL_2);
	    }

	}

int main() {

	char Satz[SATZ_LENGTH];
	UART_Init(UART_BASE, 115200, 8, PARITY_NONE, STOPPBITS_10);

	DMA_init(CHANNEL_1, UART_BASE + UART_RDR,(uint32_t)Satz, SATZ_LENGTH, PERI_SPEI, TRUE, TRUE, TRUE);
	DMA_init(CHANNEL_2, (uint32_t)Satz, UART_BASE + UART_TDR,SATZ_LENGTH, SPEI_PERI, TRUE, TRUE, TRUE);

	uart_config = in32(UART_BASE + UART_CR);
	channel_1_config = in32(DMA_BASE + DMA_CR0);
	channel_2_config = in32(DMA_BASE + DMA_CR1);

	ChannelEnable(CHANNEL_1);
	ChannelEnable(CHANNEL_2);

	while(1)
	{

	}

	return 0;
}

#endif







