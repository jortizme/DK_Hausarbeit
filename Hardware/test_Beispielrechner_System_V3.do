# Benoetigte Dateien uebersetzen
vcom Prozessor/df_serial_in_v1_0.vhd
vcom Prozessor/df_serial_out_v1_0.vhd
vcom Prozessor/df_wishbone_interface.vhd
vcom Prozessor/serial_wishbone_interface.vhd
vcom Prozessor/div.vhd
vcom Prozessor/mult.vhd
vcom Prozessor/wb_arbiter.vhd
vcom Prozessor/bsr2_processor_core.vhd
vcom Prozessor/bsr2_processor.vhd
vcom Speicher/bsr2_ram.vhd
vcom Speicher/bsr2_rom.vhd
vcom GPIO/GPIO.vhd
vcom UART/Serieller_Sender.vhd
vcom UART/Serieller_Empfaenger.vhd
vcom UART/UART.vhd


vcom Beispielrechner_System.vhd
vcom test_serial.vhd
vcom txt_util_pack.vhd
vcom Beispielrechner_System_V3_testbench.vhd

# Simulator starten
vsim -t ns -voptargs=+acc work.Beispielrechner_System_V3_testbench

# Breite der Namensspalte
configure wave -namecolwidth 128
# Breite der Wertespalte
configure wave -valuecolwidth 128
# Angezeigte Pfadelemente
configure wave -signalnamewidth 1
# sim: nicht anzeigen
configure wave -datasetprefix 0
# Einheit der Zeitachse
configure wave -timelineunits ms

set NumericStdNoWarnings 1

# Signale hinzufuegen
if {1} {
    add wave              /Beispielrechner_System_V3_testbench/uut/CLK
}
	
if {1} {
	add wave -divider "Externe Signale"
    add wave /Beispielrechner_System_V3_testbench/BTN
    add wave /Beispielrechner_System_V3_testbench/LED
    add wave /Beispielrechner_System_V3_testbench/RXD
    add wave /Beispielrechner_System_V3_testbench/TXD
}

if {1} {
	add wave -divider "Wishbone Bus"
	add wave              /Beispielrechner_System_V3_testbench/uut/SYS_STB
	add wave              /Beispielrechner_System_V3_testbench/uut/SYS_WE
	add wave              /Beispielrechner_System_V3_testbench/uut/SYS_WRO
	add wave              /Beispielrechner_System_V3_testbench/uut/SYS_SEL
	add wave -hexadecimal /Beispielrechner_System_V3_testbench/uut/SYS_ADR
	add wave -hexadecimal /Beispielrechner_System_V3_testbench/uut/SYS_DAT_O
	add wave              /Beispielrechner_System_V3_testbench/uut/SYS_ACK
	add wave -hexadecimal /Beispielrechner_System_V3_testbench/uut/SYS_DAT_I
}

if {1} {
	add wave -divider "UART"
	add wave /beispielrechner_system_v3_testbench/uut/UART_Inst/STB_I
	add wave /beispielrechner_system_v3_testbench/uut/UART_Inst/WE_I
	add wave /beispielrechner_system_v3_testbench/uut/UART_Inst/ADR_I
	add wave /beispielrechner_system_v3_testbench/uut/UART_Inst/DAT_I
	add wave /beispielrechner_system_v3_testbench/uut/UART_Inst/DAT_O
	add wave /beispielrechner_system_v3_testbench/uut/UART_Inst/ACK_O
	add wave /beispielrechner_system_v3_testbench/uut/UART_Inst/Interrupt
}

if {1} {
	add wave -divider "GPIO"
	add wave              /beispielrechner_system_v3_testbench/uut/GPIO_Inst/STB_I
	add wave              /beispielrechner_system_v3_testbench/uut/GPIO_Inst/WE_I
	add wave -hexadecimal /beispielrechner_system_v3_testbench/uut/GPIO_Inst/ADR_I
	add wave -hexadecimal /beispielrechner_system_v3_testbench/uut/GPIO_Inst/DAT_I
	add wave              /beispielrechner_system_v3_testbench/uut/GPIO_Inst/ACK_O
	add wave -hexadecimal /beispielrechner_system_v3_testbench/uut/GPIO_Inst/DAT_O
}

if {1} {
	add wave -divider "RAM"
	add wave              /beispielrechner_system_v3_testbench/uut/RAM_Inst/STB_I
	add wave              /beispielrechner_system_v3_testbench/uut/RAM_Inst/WE_I
	add wave              /beispielrechner_system_v3_testbench/uut/RAM_Inst/SEL_I
	add wave -hexadecimal /beispielrechner_system_v3_testbench/uut/RAM_Inst/ADR_I
	add wave -hexadecimal /beispielrechner_system_v3_testbench/uut/RAM_Inst/DAT_I
	add wave -hexadecimal /beispielrechner_system_v3_testbench/uut/RAM_Inst/DAT_O
	add wave              /beispielrechner_system_v3_testbench/uut/RAM_Inst/ACK_O
}
	
if {1} {
	add wave -divider "ROM"
	add wave              /beispielrechner_system_v3_testbench/uut/ROM_Block/ROM_Inst/STB_I
	add wave              /beispielrechner_system_v3_testbench/uut/ROM_Block/ROM_Inst/WE_I
	add wave -hexadecimal /beispielrechner_system_v3_testbench/uut/ROM_Block/ROM_Inst/ADR_I
	add wave -hexadecimal /beispielrechner_system_v3_testbench/uut/ROM_Block/ROM_Inst/DAT_I
	add wave -hexadecimal /beispielrechner_system_v3_testbench/uut/ROM_Block/ROM_Inst/DAT_O
	add wave              /beispielrechner_system_v3_testbench/uut/ROM_Block/ROM_Inst/ACK_O
}
	
if {1} {
	add wave -divider "Prozessor"
	add wave -hexadecimal /Beispielrechner_System_V3_testbench/UUT/CPU_Inst/core/PC
	add wave              /Beispielrechner_System_V3_testbench/UUT/CPU_Inst/core/DissBlock/Diss_Inst
}

# Simulation ausfuehren
run 480 us

# Alles Anzeigen
wave zoom full

