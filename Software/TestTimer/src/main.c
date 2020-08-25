#include <gpio.h>
#include <timer.h>
#include <cpu.h>
#include <config.h>

void Timer_Handler()
{
	// LEDs an Pins 4-7 umschalten
	int led_old = in32(GPIO_BASE + GPIO_DATA);      // vorherigen Wert lesen
	int led_new = led_old  ^ (0xf << 4);            // Wert invertieren
	out32(GPIO_BASE + GPIO_DATA, led_new);          // neuen Wert schreiben

	// Timer-Interrupt quittieren
	in32(TIMER_BASE + TIMER_STATUS);
}

int main()
{
	// Pins 4-7 als Ausgang konfigurieren
	out32(GPIO_BASE + GPIO_DIR_SET, (0xf << 4));

	// Timer konfigurieren (1 Interrupt je 10 us)
	out32(TIMER_BASE + TIMER_START, SYSTEM_FREQUENCY / 100000 - 1);
	cpu_enable_interrupt(TIMER_INTR);

	while(1);

	return 0;
}
