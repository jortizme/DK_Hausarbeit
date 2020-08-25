entity Timer_tb is
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.wishbone_test_pack.all;

architecture bench of Timer_tb is
    constant CLOCK_PERIOD : time     := 20 ns;
    
    constant Timer_Value  : std_logic_vector(3 downto 0) := x"0";
    constant Timer_Start  : std_logic_vector(3 downto 0) := x"4";
    constant Timer_Status : std_logic_vector(3 downto 0) := x"8";

    signal CLK       : std_logic;
    signal RST       : std_logic;
    signal Sys_STB   : std_logic;
    signal Sys_WE    : std_logic;
    signal Sys_ADR   : std_logic_vector(3 downto 0);
    signal Sys_SEL   : std_logic_vector(3 downto 0);
    signal Sys_DAT   : std_logic_vector(31 downto 0) := (others=>'0');
    signal Timer_ACK : std_logic;
    signal Timer_DAT : std_logic_vector(31 downto 0);
    signal Timer_IRQ : std_logic;

begin
	uut: entity work.Timer 
	port map ( 
        CLK_I     => CLK,
        RST_I     => RST,
        STB_I     => Sys_STB,
        WE_I      => Sys_WE,
        ADR_I     => Sys_ADR,
        DAT_I     => Sys_DAT,
        ACK_O     => Timer_ACK,
        DAT_O     => Timer_DAT,
        Timer_IRQ => Timer_IRQ
    );

	stim_and_verify: process
		variable write_data : std_logic_vector(31 downto 0);
		variable read_data  : std_logic_vector(31 downto 0);
		
		procedure execute_test(n : integer) is
		begin
			report "Teste mit Startwert " & integer'image(n);
		
			-- Zaehler mit dem Wert n starten
			wishbone_write(x"f", Timer_Start, std_logic_vector(to_unsigned(n, 32)), CLK, Sys_STB, Sys_WE, Sys_SEL, Sys_ADR, Sys_DAT, Timer_ACK, Timer_DAT);		
			
			-- Auf Interrupt warten
			for i in 0 to n loop
				assert Timer_IRQ='0' report "Timer_IRQ zu frueh" severity error;   
				wait until falling_edge(CLK);
			end loop;
			assert Timer_IRQ='1' report "Timer_IRQ nicht ausgeloest" severity error;   
			
			-- Interrupt quittieren
			wishbone_read(Timer_Status, read_data, CLK, Sys_STB, Sys_WE, Sys_SEL, Sys_ADR, Sys_DAT, Timer_ACK, Timer_DAT);
			assert Timer_IRQ='0' report "Timer_IRQ nicht zurueckgesetzt" severity failure;   
		end procedure;
	begin
		RST <= '1';
		wishbone_init(Sys_STB, Sys_WE, Sys_SEL, Sys_ADR, Sys_DAT);        
		wait_cycle(2, CLK);
		RST <= '0';
		wait_cycle(2, CLK);

		execute_test(7);
		execute_test(31);
		
		report "Alle Tests beendet";
    wait;
  end process;

  clocking: process
  begin
    clk <= '0';
    wait for CLOCK_PERIOD / 2;
    clk <= '1';
    wait for CLOCK_PERIOD / 2;
  end process;

end;