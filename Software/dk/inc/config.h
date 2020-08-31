#pragma once

#include <cpu.h>

// System clock frequency in Hz
#define SYSTEM_FREQUENCY 50000000

// GPIO configuration
#define GPIO_BASE        0x00008100

// UART configuration
#define UART_BASE        0x00008200

// Timer configuration
#define TIMER_BASE       0x00008300
#define TIMER_INTR       IP3_INTR
#define Timer_Handler    IP3_Handler

//DMA configuration
#define DMA_BASE        0x00030000
#define DMA_INTR        IP2_INTR
#define DMA_Handler     IP2_Handler

