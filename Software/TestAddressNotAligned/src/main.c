/*
-------------------------------------------------------------------------------
-- DMA-Kanal
-------------------------------------------------------------------------------
-- Modul Digitale Komponenten
-- Hochschule Osnabrueck
-- Joaquin Ortiz, Filip Mijac
-------------------------------------------------------------------------------

 *Dieses Programm zeigt die Faehigkeit der Kanaele, Bytes zu uebertragen egal
 *ob die Adresse Word-Aligned ist oder nicht
 */

#include <gpio.h>
#include <timer.h>
#include <cpu.h>
#include <config.h>
#include <dma.h>

#define TEXT_MAX_LENGTH  1024
volatile uint32_t configChannel_0;
Config_Channel_Info* volatile Channel_0_p;

void DMA_Handler()
{
	uint32_t status = in32(DMA_BASE + DMA_SR);

	if(status & DMA_CHA0_IRQ)
	{
		//
		//Interrupt quittieren
		//
		InterruptAck(Channel_0_p);
	}
}

int main()
{
	const char Gedicht[TEXT_MAX_LENGTH] =
	    "Habe nun, ach! Philosophie,\r\n"
	    "Juristerei und Medizin,\r\n"
	    "Und leider auch Theologie\r\n"
	    "Durchaus studiert, mit heissem Bemuehn.\r\n"
	    "Da steh ich nun, ich armer Tor!\r\n"
	    "Und bin so klug als wie zuvor;\r\n"
	    "Heisse Magister, heisse Doktor gar\r\n"
	    "Und ziehe schon an die zehen Jahr\r\n"
	    "Herauf, herab und quer und krumm\r\n"
	    "Meine Schueler an der Nase herum -\r\n"
	    "Und sehe, dass wir nichts wissen koennen!\r\n";

	uint32_t i = 0;
	//
	//L�nge des Gedichtes bestimmen
	//
	while(Gedicht[i] != '\0')
		i++;

	const uint32_t TextLength = ++i;
	char NeuesGedicht[TEXT_MAX_LENGTH];
	bool_t Tra_Fertig = FALSE;

	//
	//Struct mit der Einstellung des Kanals 0
	//
	Config_Channel_Info Channel_0_Config = {CHANNEL_0,(uint32_t)(Gedicht+10),(uint32_t)(NeuesGedicht+6),TextLength,SPEI_SPEI,FALSE,TRUE,FALSE};

	//
	//Channel Initialisierung
	//
	DMA_init(&Channel_0_Config);

	//
	//Wert vom Kontroll-Register speichern
	//
	Channel_0_Config.ControlRegVal = in32(DMA_BASE + DMA_CR0);

	//
	//Zuweisung an die globale Variable
	//
	Channel_0_p = &Channel_0_Config;

	//
	//Kanal starten
	//
	ChannelEnable(&Channel_0_Config);

		while(1)
		{
			if((in32(DMA_BASE + DMA_SR) & CHANNEL_0) == 0 && Tra_Fertig == FALSE)
			{
				for(int i = 0; i <= TextLength; i++)
				{
					if(NeuesGedicht[i] == '\0')
						break;

					//
					//Ist der Transfer erfolgreich, soll die folgende Anweisung immer falsch sein
					//
					else if(Gedicht[i + 10] != NeuesGedicht[i + 6])
						out32(DMA_BASE + DMA_CR0, in32(DMA_BASE +  DMA_CR0) & ~(1<<3));
				}

				Tra_Fertig = TRUE;
			}
		}

	return 0;
}
