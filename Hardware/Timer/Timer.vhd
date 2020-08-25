--------------------------------------------------------------------------------
-- Dateiname: Timer.vhd
--
-- Timer Komponente
--
-- Erstellt: 12.05.2014, Rainer Hoeckmann
--
-- Aenderungen:
-- 2020-04-29 cyc_i entfernt, zu std_logic geaendert
-- 2020-05-28 Aufteilung in Prozesse geaendert
--------------------------------------------------------------------------------
-- Registers:
-- 0x0: Timer_Value  (RW)
-- 0x4: Timer_Start  (RW)
-- 0x8: Timer_Status (R)
--    [31:1]: unused
--    [0]:    Timer_IRQ (Reset on Read)
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Timer is
    port(
      CLK_I      : in  std_logic;
      RST_I      : in  std_logic;
      STB_I      : in  std_logic;
      WE_I       : in  std_logic;
      ADR_I      : in  std_logic_vector(3 downto 0);
      DAT_I      : in  std_logic_vector(31 downto 0);
      ACK_O      : out std_logic;
      DAT_O      : out std_logic_vector(31 downto 0);
      Timer_IRQ  : out std_logic
    );
end entity;

architecture rtl of Timer is 

	-- Typ fuer den Lesedatenmultiplexer
	type RD_Mux_Type is (RD_SEL_Nichts, RD_SEL_Start, RD_SEL_Value, RD_SEL_Status);
	
	-- Interne Version des Ausgangssignals
	signal Timer_IRQ_i    : std_logic := '0';
	
	-- Register
	signal Timer_Value    : unsigned(31 downto 0)         := (others=>'0');
	signal Timer_Start    : unsigned(31 downto 0)         := (others=>'0');
	signal Timer_Status   : std_logic_vector(31 downto 0) := (others=>'0');
	signal TC             : std_logic := '0';
	
	-- Kombinatorische Signale
	signal RD_Sel         : RD_Mux_Type;
	signal Lese_Status    : std_logic;
	signal Schreibe_Start : std_logic;
	signal Schreibe_Value : std_logic;
  
begin
	-- Interne Version des Ausgangsignals nach aussen fuehren
	Timer_IRQ <= Timer_IRQ_i;
	
	-- Timer_Status mit Statussignal verbinden
	Timer_Status(0) <= Timer_IRQ_i;
  
	-- Kombinatorischer Prozess zur Dekodierung der Bussignale
	Decoding: process(STB_I, WE_I, ADR_I) is
	begin
	
		-- Default-Zuweisungen
		ACK_O          <= '0';
		Lese_Status    <= '0';
		Schreibe_Start <= '0';
		Schreibe_Value <= '0';
		RD_Sel         <= RD_SEL_Nichts;
  
		-- TODO: Dekodierung der Bussignale beschreiben
	end process;
	
	-- Kombinatorischer Prozess fuer den Lesedatenmultiplexer
	Mux_Lesedaten: process(RD_Sel, Timer_Start, Timer_Value, Timer_Status) is
	begin
		-- TODO: Zuweisung an DAT_O beschreiben
	end process;
	
	-- Synchroner Prozess fuer das Register Timer_Start
	Reg_Timer_Start: process(CLK_I) is
	begin
		if rising_edge(CLK_I) then
			-- TODO: Zuweisung an Timer_Start beschreiben
		end if;
	end process;

	-- Synchroner Prozess fuer das Register Timer_Value, 
	-- (umfasst auch den Multiplexer fuer die Schreibdaten sowie das Oder-Gatter)
	Reg_Timer_Value: process(CLK_I) is
		variable Timer_Value_var : unsigned(Timer_Value'range);
	begin
		if rising_edge(CLK_I) then
		
			-- alten Zahlerstand vom Signal lesen
			Timer_Value_var := Timer_Value;
			
			-- Default-Zuweisung
			TC <= '0';
			
			-- TODO: Verhalten des Zaehlers beschreiben
			
			-- neuen Zahlerstand dem Signal zuweisen
			Timer_Value <= Timer_Value_var;
		end if;
	end process;
	
	-- Synchroner Prozess fuer das Register Timer_IRQ_i
	Reg_Timer_IRQ_i: process(CLK_I) is
	begin
		if rising_edge(CLK_I) then
			-- TODO: Register Timer_IRQ_i beschreiben
		end if;
	end process;
end architecture;