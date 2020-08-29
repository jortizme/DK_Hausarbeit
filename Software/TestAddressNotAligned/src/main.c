/*
-------------------------------------------------------------------------------
-- DMA-Kanal
-------------------------------------------------------------------------------
-- Modul Digitale Komponenten
-- Hochschule Osnabrueck
-- Joaquin Ortiz, Filip Mijac
-------------------------------------------------------------------------------
*/
/*
 *Dieses Programm zeigt die Fähigkeit der Kanäle, Bytes zu übertragen egal
 *ob die Adresse Word-Aligned ist oder nicht
 */

#include <gpio.h>
#include <timer.h>
#include <cpu.h>
#include <config.h>
#include <dma.h>

#define TEXT_MAX_LENGTH  1024
volatile uint32_t configChannel_0;

void DMA_Handler()
{
	uint32_t status = in32(DMA_BASE + DMA_SR);

	if(status & DMA_CHA0_IRQ)
	{
		InterruptAck(CHANNEL_0, configChannel_0);
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
while(Gedicht[i] != '\0')
	i++;

const uint32_t TextLength = ++i;
char NeuesGedicht[TEXT_MAX_LENGTH];
bool_t Tra_Fertig = FALSE;

DMA_init(CHANNEL_0, (uint32_t)(Gedicht+10), (uint32_t)(NeuesGedicht+6), TextLength, SPEI_SPEI, FALSE, TRUE, FALSE);
configChannel_0 = in32(DMA_BASE + DMA_CR0);
ChannelEnable(CHANNEL_0, configChannel_0);

	while(1)
	{
		if((in32(DMA_BASE + DMA_SR) & CHANNEL_0) == 0 && Tra_Fertig == FALSE)
		{
			for(int i = 0; i <= TextLength; i++)
			{
				if(NeuesGedicht[i] == '\0')
					break;

				else if(Gedicht[i + 10] != NeuesGedicht[i + 6])
					out32(DMA_BASE + DMA_CR0, in32(DMA_BASE +  DMA_CR0) & ~(1<<3));
			}

			Tra_Fertig = TRUE;
		}
	}

	return 0;
}
