#include <gpio.h>
#include <uart.h>
#include <cpu.h>
#include <config.h>
#include <stdio.h>
#include <dma.h>

#define SATZ_LENGHT 64
#define TEXT_LENGHT 1024
uint32_t configKanal_0;
uint32_t configKanal_1;
uint32_t configKanal_2;
char* auxText;

void DMA_Handler()
{
	uint32_t status = in32(DMA_BASE + DMA_SR);
	static uint32_t offset_K1 = 0;
	static uint32_t offset_K2 = 0;

	if(status & DMA_CHA0_IRQ)
	{
		//Zieladresse von Kanal 1 festlegen
		out32(DMA_BASE+ DMA_DESTR1, (uint32_t)(auxText + offset_K1));
		//Kanal 1 aktivieren
		out32(DMA_BASE + DMA_CR1, configKanal_1 | CHANNEL_EN);

		//Interrupt kanal 0 bestätigen
		out32(DMA_BASE + DMA_CR0, configKanal_0 | CHANNEL_IR_ACK);
		//Kanal 0 aktivieren
		out32(DMA_BASE + DMA_CR0, configKanal_0 | CHANNEL_EN);

		if((offset_K1 + SATZ_LENGHT) >= TEXT_LENGHT)
			offset_K1 = 0;
		else
			offset_K1 = offset_K1 + SATZ_LENGHT;
	}

	if(status & DMA_CHA1_IRQ)
	{
		out32(DMA_BASE + DMA_CR1, configKanal_1 | CHANNEL_IR_ACK);

		//Quelladresse von Kanal 2 festlegen
		out32(DMA_BASE+ DMA_SAR2, (uint32_t)(auxText + offset_K2));
		//Kanal 2 starten
		out32(DMA_BASE + DMA_CR2, configKanal_2 | CHANNEL_EN);

		if((offset_K2 + SATZ_LENGHT) >= TEXT_LENGHT)
			offset_K2 = 0;
		else
		offset_K2 = offset_K2 + SATZ_LENGHT;
	}

	if(status & DMA_CHA2_IRQ)
	{
		out32(DMA_BASE + DMA_CR2, configKanal_2 | CHANNEL_IR_ACK);
	}

}

int main(){

	char ReceiverFifo[SATZ_LENGHT];
	char Text[TEXT_LENGHT];

    UART_Init(UART_BASE, 115200, 8, PARITY_NONE, STOPPBITS_10);
    DMA_init(CHANNEL_0, UART_BASE + UART_RDR, (uint32_t)ReceiverFifo, SATZ_LENGHT, PERI_SPEI, TRUE, TRUE, TRUE);
    //Zieladresse noch nicht definiert (dynamisch)
    DMA_init(CHANNEL_1, (uint32_t)ReceiverFifo, 0, SATZ_LENGHT, SPEI_SPEI, FALSE, TRUE, FALSE);
    //Quelladresse noch nicht definiert (dynamisch)
    DMA_init(CHANNEL_2, 0, UART_BASE + UART_TDR, SATZ_LENGHT, SPEI_PERI, TRUE, TRUE, TRUE);

    auxText = Text;

	//TX Interrupt vom UART freigeben
	out32(UART_BASE + UART_CR, in32(UART_BASE + UART_CR) | UART_TX_IRQ );
	//Globale Variablen zur späteren Verwendung
    configKanal_0 = in32(DMA_BASE + DMA_CR0);
    configKanal_1 = in32(DMA_BASE + DMA_CR1);
    configKanal_2 = in32(DMA_BASE + DMA_CR2);

    //Kanal 0 starten
    out32(DMA_BASE + DMA_CR0, configKanal_0 | CHANNEL_EN);

   while(1)
    {

    }

    return 0;
}
