
#if 0


#include <gpio.h>
#include <uart.h>
#include <cpu.h>
#include <config.h>
#include <stdio.h>
#include <dma.h>


#define SATZ_LENGTH 128
#define PHRASE_LENGHT 1024
//uint32_t uart_config;
uint32_t channel_1_config;
uint32_t channel_2_config;

char Receiver_FIFO_1[SATZ_LENGTH];
//char Receiver_FIFO_2[SATZ_LENGTH];
char* aux;
uint32_t offset;

void DMA_Handler()
{
	uint32_t status = in32(DMA_BASE + DMA_SR);
	uint32_t Modus = in32(DMA_BASE + DMA_CR1);

    if(status & DMA_CHA0_IRQ)
    {
    	DMA_init(CHANNEL_2, (uint32_t)Receiver_FIFO_1,(uint32_t)(aux + offset), SATZ_LENGTH, SPEI_SPEI, FALSE, TRUE, FALSE);
    	ChannelEnable(CHANNEL_2);
    	out32(DMA_BASE + DMA_CR0, channel_1_config | CHANNEL_IR_ACK);
    	ChannelEnable(CHANNEL_1);

    }

    if(status & DMA_CHA1_IRQ)
    {
    	if((Modus & 0b11) == SPEI_PERI)
    	{
    		out32(DMA_BASE + DMA_CR1, channel_2_config | CHANNEL_IR_ACK);
    		offset = offset  + SATZ_LENGTH;
    	}

    	else if((Modus & 0b11) == SPEI_SPEI)
    	{
    		out32(DMA_BASE + DMA_CR1, channel_2_config | CHANNEL_IR_ACK);
    		DMA_init(CHANNEL_2, (uint32_t)(aux + offset),UART_BASE + UART_TDR, SATZ_LENGTH, SPEI_PERI, TRUE, TRUE, TRUE);
    		ChannelEnable(CHANNEL_2);
    	}

    }

}
int main() {

	char gesamtReceived[PHRASE_LENGHT];
	aux = gesamtReceived;

	UART_Init(UART_BASE, 115200, 8, PARITY_NONE, STOPPBITS_10);
	//uart_config = in32(UART_BASE + UART_CR);
	out32(UART_BASE + UART_CR, in32(UART_BASE + UART_CR) | UART_TX_IRQ);

	DMA_init(CHANNEL_1,UART_BASE + UART_RDR, (uint32_t)Receiver_FIFO_1, SATZ_LENGTH , PERI_SPEI, TRUE, TRUE, TRUE);

	offset = 0;
	channel_1_config = in32(DMA_BASE + DMA_CR0);
	channel_2_config = in32(DMA_BASE + DMA_CR1);

	ChannelEnable(CHANNEL_1);

	//bool_t UsedFIFO_1 = TRUE;
	//bool_t UsedFIFO_2 = FALSE;

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



