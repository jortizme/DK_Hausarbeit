#include <gpio.h>
#include <timer.h>
#include <cpu.h>
#include <config.h>

#define TEXT_LEGNTH  1024

void DMA_Handler()
{
	uint32_t status = in32(DMA_BASE + DMA_SR);

	if(status & DMA_CHA0_IRQ)
	{

	}

}

int main()
{
	char Gedicht[] = "Im weiten Mantel bis ans Kinn verhüllet,
Ging ich den Felsenweg, den schroffen, grauen,
Hernieder dann zu winterhaften Auen,
Unruhgen Sinns, zur nahen Flucht gewillet.

Auf einmal schien der neue Tag enthüllet:
Ein Mädchen kam, ein Himmel anzuschauen,
So musterhaft wie jene lieben Frauen
Der Dichterwelt. Mein Sehnen war gestillet.

Doch wandt ich mich hinweg und ließ sie gehen
Und wickelte mich enger in die Falten,
Als wollt ich trutzend in mir selbst erwarmens

Und folgt ihr doch. Sie stand. Da wars geschehen!
In meiner Hülle konnt ich mich nicht halten,
Die warf ich weg, sie lag in meinen Armen.";

uint32_t i = 0;
while(Gedicht[i] != '\0')
	i++;

const uint32_t TextLength = ++i;
char NuesGedicht[TextLength];

DMA_init(CHANNEL_0, (uint32_t)Gedicht, (uint32_t)NuesGedicht, TextLength, SPEI_SPEI, FALSE, TRUE, FALSE);
ChannelEnable(CHANNEL_1);

	while(1)
	{
		while((in32(DMA_BASE + DMA_SR) & CHANNEL_0));

		for(int i = 0; i < TextLength, i++)
		{
			if(Gedicht[i] != NeuesGedicht[i])
				out32(DMA_BASE + DMA_CR0, in32(DMA_BASE +  DMA_CR0) & ~(1<<3));
		}

	}

	return 0;
}
