/*
-------------------------------------------------------------------------------
-- DMA-Kanal
-------------------------------------------------------------------------------
-- Modul Digitale Komponenten
-- Hochschule Osnabrueck
-- Joaquin Ortiz, Filip Mijac
-------------------------------------------------------------------------------

 *Dieses Programm zeigt die Funktionalitaet von den Kanaelen in den 3 verschiedenen Modi (PERI_SPEI, SPEI_PERI, SPEI_SPEI).
 *Der Kanal 0 speichert die vom Computer gesendeten Bytes in einem Array, nachdem er 64 Bytes kopiert hat wird
 *der Kanal 1 gestartet, damit er die Bytes in ein permanentes Array umkopiert. Der Kanal 2 sendet die kopierten
 *Bytes von diesem Array per UART an den Computer zurueck. Somit werden Saetze mit der UART-Console an den Kanal 0
 *gesendet, dann intern im Program mit dem Kanal 1 gespeichert und abschliessend zurueck per UART an den Computer mit
 *dem Kanal 2 uebertragen, damit der Benutzer die gesendeten Saetze wieder sieht.
 */

#include <gpio.h>
#include <timer.h>
#include <uart.h>
#include <cpu.h>
#include <config.h>
#include <dma.h>

#define SATZ_LENGHT 64
#define TEXT_LENGHT 1024
Config_Channel_Info* volatile Channel_0_p;
Config_Channel_Info* volatile Channel_1_p;
Config_Channel_Info* volatile Channel_2_p;
volatile char*volatile auxText;

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
		ChannelEnable(Channel_1_p);

		//Interrupt Kanal 0 bestaetigen
		InterruptAck(Channel_0_p);
		//Kanal 0 aktivieren
		ChannelEnable(Channel_0_p);

		if((offset_K1 + SATZ_LENGHT) >= TEXT_LENGHT)
			offset_K1 = 0;
		else
			offset_K1 = offset_K1 + SATZ_LENGHT;
	}

	if(status & DMA_CHA1_IRQ)
	{
		//Interrupt quittieren
		InterruptAck(Channel_1_p);

		//Quelladresse von Kanal 2 festlegen
		out32(DMA_BASE+ DMA_SAR2, (uint32_t)(auxText + offset_K2));
		//Kanal 2 starten
		ChannelEnable(Channel_2_p);

		if((offset_K2 + SATZ_LENGHT) >= TEXT_LENGHT)
			offset_K2 = 0;
		else
		offset_K2 = offset_K2 + SATZ_LENGHT;
	}

	if(status & DMA_CHA2_IRQ)
	{
		//Interrupt quittieren
		InterruptAck(Channel_2_p);
	}
}

int main(){

	//
	//Dieses Feld wird andauern ueberschrieben
	//
	char ReceiverFifo[SATZ_LENGHT];

	//
	//Hier werden die erhaltenen Saetze gespeichert, werden mehr als TEXT_LENGHT Bytes gespeichert, dann
	//werden die Bytes vom Anfang ueberschrieben
	//
	char Text[TEXT_LENGHT];

	//
	//UART initialisieren
	//
    UART_Init(UART_BASE, 115200, 8, PARITY_NONE, STOPPBITS_10);

    Config_Channel_Info Channel_0_Config = {CHANNEL_0,UART_BASE + UART_RDR,(uint32_t)ReceiverFifo,SATZ_LENGHT,PERI_SPEI,TRUE,TRUE,TRUE};
    Channel_0_p = &Channel_0_Config;

    //
    //Zieladresse noch nicht definiert (dynamisch)
    //
    Config_Channel_Info Channel_1_Config = {CHANNEL_1,(uint32_t)ReceiverFifo,0,SATZ_LENGHT,SPEI_SPEI,FALSE,TRUE,FALSE};
    Channel_1_p = &Channel_1_Config;

    //
    //Quelladresse noch nicht definiert (dynamisch)
    //
    Config_Channel_Info Channel_2_Config = {CHANNEL_2,0,UART_BASE + UART_TDR,SATZ_LENGHT,SPEI_PERI,TRUE,TRUE,TRUE};
    Channel_2_p = &Channel_2_Config;

    //
    //Kanaele einstellen
    //
    DMA_init(&Channel_0_Config);
    DMA_init(&Channel_1_Config);
    DMA_init(&Channel_2_Config);


    //auxText ist ein globaler Zeiger, er ist noetig da die Zieladdrese vom Kanal 1 und die Quelladdrese vom Kanal 2
    //sich immer aendern wird und in der ISR neu angepasst werden muessen
    auxText = Text;

    //
	//TX Interrupt vom UART freigeben
    //
	out32(UART_BASE + UART_CR, in32(UART_BASE + UART_CR) | UART_TX_IRQ );

	//Zur spaeteren Verwendung in der ISR, damit sparen wir ein Lesezugriff
	//im Wishbone-Bus (beim Lesen vom Kontroll-Register)
	Channel_0_Config.ControlRegVal = in32(DMA_BASE + DMA_CR0);
	Channel_1_Config.ControlRegVal = in32(DMA_BASE + DMA_CR1);
	Channel_2_Config.ControlRegVal = in32(DMA_BASE + DMA_CR2);

    //
    //Kanal 0 starten
    //
    ChannelEnable(&Channel_0_Config);

    uint32_t i;

   while(1)
    {
	   i++;
    }

    return 0;
}
