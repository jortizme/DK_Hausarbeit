-------------------------------------------------------------------------------
-- DMA-Kontroller
-------------------------------------------------------------------------------
-- Modul Digitale Komponenten
-- Hochschule Osnabrueck
-- Joaquin Ortiz, Filip Mijac
---------------------------------------------------------------------------------------------------
-- Offsets:
-- 0x00 Source Address Kanal_1 Register         (SAR0)      (Write Only)
-- 0x04 Destination Address Kanal_1 Register    (DESTR0)    (Write Only)
-- 0x08 Transfer Antahl Kana_1 Register         (TRAAR0)    (RW)
-- 0x0C Control Register Kanal_1                (CR0)       (RW)
-- 0x10 Source Address Kanal_2 Register         (SAR1)      (Write Only)
-- 0x14 Destination Address Kanal_2 Register    (DESTR1)    (Write Only)
-- 0x18 Transfer Antahl Kana_2 Register         (TRAAR1)    (RW)
-- 0x1C Control Register Kanal_2                (CR1)       (RW)
-- 0x20 Source Address Kanal_3 Register         (SAR2)      (Write Only)
-- 0x24 Destination Address Kanal_3 Register    (DESTR2)    (Write Only)
-- 0x28 Transfer Antahl Kana_3 Register         (TRAAR2)    (RW)
-- 0x2C Control Register Kanal_3                (CR2)       (RW)
-- 0x30 Source Address Kanal_4 Register         (SAR3)      (Write Only)
-- 0x34 Destination Address Kanal_4 Register    (DESTR3)    (Write Only)
-- 0x38 Transfer Antahl Kana_4 Register         (TRAAR3)    (RW)
-- 0x3C Control Register Kanal_4                (CR3)       (RW)
-- 0x40 Status Register                         (SR)        (Read Only)
---------------------------------------------------------------------------------------------------
-- Control Register (CR0 - CR3):
--  1 .. 0 : Betriebsmodus
--  2      : Byte_Transfer
--  3      : Freigabe Interrupt
--  4      : Externes-Ereignis-Enable
--  8      : Kanal-Enable               (Write-Only)
--  9      : Interrupt-Quittierung      (Write-Only)

---------------------------------------------------------------------------------------------------
-- Status Register (SR):
--  0      : Kanal_1 aktiv
--  1      : Kanal_2 aktiv
--  2      : Kanal_3 aktiv
--  3      : Kanal_4 aktiv
--  16     : Interrupt Kanal_1  
--  17     : Interrupt Kanal_2
--  18     : Interrupt Kanal_3  
--  19     : Interrupt Kanal_4
---------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DMA_Kontroller is 
    generic(
        BUSWIDTH : positive;
        WORDWIDTH : positive
    );
    port(
        Takt            : in std_logic;
        Reset           : in std_logic;

        --Slave interface signals
        S_STB           : in std_logic;
        S_WE            : in std_logic;
        S_ADR           : in std_logic_vector(7 downto 0);
        S_DAT_O         : out std_logic_vector(WORDWIDTH - 1 downto 0);
        S_DAT_I         : in std_logic_vector(WORDWIDTH - 1 downto 0);
        S_ACK           : out std_logic;
        
        --Master interface signals
        M_STB           : out std_logic;
        M_WE            : out std_logic;
        M_ADR           : out std_logic_vector(WORDWIDTH - 1 downto 0);
        M_SEL           : out std_logic_vector(3 downto 0);
        M_DAT_O         : out std_logic_vector(WORDWIDTH - 1 downto 0);
        M_DAT_I         : in std_logic_vector(WORDWIDTH - 1 downto 0);
        M_ACK           : in std_logic;

        --Extern interrupts from peripherals
        S0_Ready         : in std_logic;
        S1_Ready         : in std_logic;
        S2_Ready         : in std_logic;
        S3_Ready         : in std_logic;

        --Interrupts to CPU

        --Fuer die Synthese verwenden
        Kanal_Interrupt : out std_logic

        --Fuer die Simulation verwenden
        --Kanal1_Interrupt : out std_logic;
        --Kanal2_Interrupt : out std_logic;
        --Kanal3_Interrupt : out std_logic;
        --Kanal4_Interrupt : out std_logic
    );
end entity;


architecture rtl of DMA_Kontroller is

    --Signale von Kanal_1
    signal K0_STB_OUT       : std_logic;
    signal K0_WE_OUT        : std_logic;
    signal K0_ADR_OUT       : std_logic_vector(BUSWIDTH - 1 downto 0);
    signal K0_SEL_OUT       : std_logic_vector(3 downto 0);
    signal K0_DAT_OUT       : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal K0_DAT_INPUT     : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal K0_ACK_INPUT     : std_logic;

    signal TRA0_ANZ_STD      : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal TRA0_Fertig       : std_logic := '0';
    signal Kanal_0_IR        : std_logic := '0';
    signal BetriebMod_0      : std_logic_vector(1 downto 0);
    signal ByteTrans_0       : std_logic;
    signal ExEreigEn_0       : std_logic;
    signal FreigabeIR_0      : std_logic;
    signal Kanal_Aktiv_0     : std_logic;

    --Signale von Kanal_2
    signal K1_STB_OUT       : std_logic;
    signal K1_WE_OUT        : std_logic;
    signal K1_ADR_OUT       : std_logic_vector(BUSWIDTH - 1 downto 0);
    signal K1_SEL_OUT       : std_logic_vector(3 downto 0);
    signal K1_DAT_OUT       : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal K1_DAT_INPUT     : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal K1_ACK_INPUT     : std_logic;

    signal TRA1_ANZ_STD      : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal TRA1_Fertig       : std_logic := '0';
    signal Kanal_1_IR        : std_logic := '0';
    signal BetriebMod_1      : std_logic_vector(1 downto 0);
    signal ByteTrans_1       : std_logic;
    signal ExEreigEn_1       : std_logic;
    signal FreigabeIR_1      : std_logic;
    signal Kanal_Aktiv_1     : std_logic;

    --Signale von Kanal_3
    signal K2_STB_OUT       : std_logic;
    signal K2_WE_OUT        : std_logic;
    signal K2_ADR_OUT       : std_logic_vector(BUSWIDTH - 1 downto 0);
    signal K2_SEL_OUT       : std_logic_vector(3 downto 0);
    signal K2_DAT_OUT       : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal K2_DAT_INPUT     : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal K2_ACK_INPUT     : std_logic;

    signal TRA2_ANZ_STD      : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal TRA2_Fertig       : std_logic := '0';
    signal Kanal_2_IR        : std_logic := '0';
    signal BetriebMod_2      : std_logic_vector(1 downto 0);
    signal ByteTrans_2       : std_logic;
    signal ExEreigEn_2       : std_logic;
    signal FreigabeIR_2      : std_logic;
    signal Kanal_Aktiv_2     : std_logic;

    
    --Signale von Kanal_4
    signal K3_STB_OUT       : std_logic;
    signal K3_WE_OUT        : std_logic;
    signal K3_ADR_OUT       : std_logic_vector(BUSWIDTH - 1 downto 0);
    signal K3_SEL_OUT       : std_logic_vector(3 downto 0);
    signal K3_DAT_OUT       : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal K3_DAT_INPUT     : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal K3_ACK_INPUT     : std_logic;

    signal TRA3_ANZ_STD      : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal TRA3_Fertig       : std_logic := '0';
    signal Kanal_3_IR        : std_logic := '0';
    signal BetriebMod_3      : std_logic_vector(1 downto 0);
    signal ByteTrans_3       : std_logic;
    signal ExEreigEn_3       : std_logic;
    signal FreigabeIR_3      : std_logic;
    signal Kanal_Aktiv_3     : std_logic;

    signal Status           : std_logic_vector(BUSWIDTH - 1 downto 0) := (others=>'0'); 
    signal CR0              : std_logic_vector(BUSWIDTH - 1 downto 0) := (others=>'0');
    signal CR1              : std_logic_vector(BUSWIDTH - 1 downto 0) := (others=>'0');
    signal CR2              : std_logic_vector(BUSWIDTH - 1 downto 0) := (others=>'0');
    signal CR3              : std_logic_vector(BUSWIDTH - 1 downto 0) := (others=>'0');

    --Signale zum Starten der Kanäle und zur Quittierung der entsprechenden Interrupts
    signal M0_Valid : std_logic := '0';
    signal M1_Valid : std_logic := '0';
    signal M2_Valid : std_logic := '0';
    signal M3_Valid : std_logic := '0';
    signal Quittung_0 : std_logic := '0';
    signal Quittung_1 : std_logic := '0';
    signal Quittung_2 : std_logic := '0';
    signal Quittung_3 : std_logic := '0';

    signal Interrupt0_i  : std_logic := '0';
    signal Interrupt1_i  : std_logic := '0';
    signal Interrupt2_i  : std_logic := '0';
    signal Interrupt3_i  : std_logic := '0';

    --Enable Signale zum Laden der Register
    signal EnSAR0   : std_logic;
    signal EnDEST0   : std_logic;
    signal EnTRAA0   : std_logic;
    signal EnCR0    : std_logic;
    signal EnSAR1   : std_logic;
    signal EnDEST1   : std_logic;
    signal EnTRAA1   : std_logic;
    signal EnCR1    : std_logic;
    signal EnSAR2   : std_logic;
    signal EnDEST2   : std_logic;
    signal EnTRAA2   : std_logic;
    signal EnCR2    : std_logic;
    signal EnSAR3   : std_logic;
    signal EnDEST3   : std_logic;
    signal EnTRAA3   : std_logic;
    signal EnCR3    : std_logic;

begin

    S_ACK <= S_STB;
    
    Interrupt0_i <= FreigabeIR_0 and TRA0_Fertig;
    Interrupt1_i <= FreigabeIR_1 and TRA1_Fertig;
    Interrupt2_i <= FreigabeIR_2 and TRA2_Fertig;
    Interrupt3_i <= FreigabeIR_3 and TRA3_Fertig;
    
    --Fuer die Sythese verwenden
    Kanal_Interrupt <= Interrupt0_i or Interrupt1_i or Interrupt2_i or Interrupt3_i;

    --Fuer die Simulation verwenden
    --Kanal1_Interrupt <= Interrupt0_i;
    --Kanal2_Interrupt <= Interrupt1_i;
    --Kanal3_Interrupt <= Interrupt2_i;
    --Kanal4_Interrupt <= Interrupt3_i;

    -- Kontrollregister mit Steuersignalen verbinden
    BetriebMod_0    <= CR0(1 downto 0);  
    ByteTrans_0     <= CR0(2);
    FreigabeIR_0    <= CR0(3);  
    ExEreigEn_0     <= CR0(4);

    BetriebMod_1    <= CR1(1 downto 0);  
    ByteTrans_1     <= CR1(2);
    FreigabeIR_1    <= CR1(3);  
    ExEreigEn_1     <= CR1(4);

    BetriebMod_2    <= CR2(1 downto 0);  
    ByteTrans_2     <= CR2(2);
    FreigabeIR_2    <= CR2(3);  
    ExEreigEn_2     <= CR2(4);
    
    BetriebMod_3    <= CR3(1 downto 0);  
    ByteTrans_3     <= CR3(2);
    FreigabeIR_3    <= CR3(3);  
    ExEreigEn_3     <= CR3(4); 

    -- Statusregister mit Statussignalen verbinden
    Status(0) <= Kanal_Aktiv_0;
    Status(1) <= Kanal_Aktiv_1;
    Status(2) <= Kanal_Aktiv_2;
    Status(3) <= Kanal_Aktiv_3;
    Status(16) <= Interrupt0_i;
    Status(17) <= Interrupt1_i;
    Status(18) <= Interrupt2_i;
    Status(19) <= Interrupt3_i;

    Decoder: process(S_STB, S_ADR, S_WE)
	begin
		-- Default-Werte
		EnSAR0      <= '0';
		EnDEST0     <= '0';
		EnTRAA0     <= '0';
        EnCR0       <= '0';
        EnSAR1      <= '0';
		EnDEST1     <= '0';
		EnTRAA1     <= '0';
        EnCR1       <= '0';
        EnSAR2      <= '0';
		EnDEST2     <= '0';
		EnTRAA2     <= '0';
        EnCR2       <= '0';
        EnSAR3      <= '0';
		EnDEST3     <= '0';
		EnTRAA3     <= '0';
        EnCR3       <= '0';
        M0_Valid    <= '0';
        M1_Valid    <= '0';
        M2_Valid    <= '0';
        M3_Valid    <= '0';   
        Quittung_0  <= '0';
        Quittung_1  <= '0';
        Quittung_2  <= '0';
        Quittung_3  <= '0';

		if S_STB = '1' then
            if S_WE = '1' then
                
                case S_ADR is 
                    when x"00" => EnSAR0 <= '1';
                    when x"04" => EnDEST0 <= '1';
                    when x"08" => EnTRAA0 <= '1';
                    when x"0C" => EnCR0 <= '1';
                                    if Kanal_Aktiv_0 = '0' and S_DAT_I(8) = '1' then 
                                        M0_Valid <= '1';
                                    elsif Kanal_Aktiv_0 = '1' and S_DAT_I(9) = '1' then 
                                        Quittung_0 <= '1';
                                    end if;

                    when x"10" => EnSAR1 <= '1';
                    when x"14" => EnDEST1 <= '1';
                    when x"18" => EnTRAA1 <= '1';
                    when x"1C" => EnCR1 <= '1';
                                    if  Kanal_Aktiv_1 = '0' and S_DAT_I(8) = '1' then 
                                        M1_Valid <= '1';
                                    elsif  Kanal_Aktiv_1 = '1' and S_DAT_I(9) = '1' then 
                                        Quittung_1 <= '1';
                                    end if;

                    when x"20" => EnSAR2 <= '1';
                    when x"24" => EnDEST2 <= '1';
                    when x"28" => EnTRAA2 <= '1';
                    when x"2C" => EnCR2 <= '1';
                                    if Kanal_Aktiv_2 = '0' and S_DAT_I(8) = '1' then 
                                        M2_Valid <= '1';
                                    elsif Kanal_Aktiv_2 = '1' and S_DAT_I(9) = '1' then 
                                        Quittung_2 <= '1';
                                    end if;

                    when x"30" => EnSAR3 <= '1';
                    when x"34" => EnDEST3 <= '1';
                    when x"38" => EnTRAA3 <= '1';
                    when x"3C" => EnCR3 <= '1';
                                    if  Kanal_Aktiv_3 = '0' and S_DAT_I(8) = '1' then 
                                        M3_Valid <= '1';
                                    elsif  Kanal_Aktiv_3 = '1' and S_DAT_I(9) = '1' then 
                                        Quittung_3 <= '1';
                                    end if;
                    when others => null;
                end case;
            end if;
		end if;
    end process;

    Lesedaten_MUX: process(S_ADR, TRA0_ANZ_STD, TRA1_ANZ_STD, TRA2_ANZ_STD, TRA3_ANZ_STD, CR0, CR1, CR2, CR3, Status)
	begin
		S_DAT_O <= (others=>'0');
        if S_ADR = x"08" then S_DAT_O(TRA0_ANZ_STD'range)     <= TRA0_ANZ_STD;
        elsif S_ADR = x"0C" then S_DAT_O(CR0'range)             <= CR0;
        elsif S_ADR = x"18" then S_DAT_O(TRA1_ANZ_STD'range)      <= TRA1_ANZ_STD;
        elsif S_ADR = x"1C" then S_DAT_O(CR1'range)              <= CR1;
        elsif S_ADR = x"28" then S_DAT_O(TRA2_ANZ_STD'range)      <= TRA2_ANZ_STD;
        elsif S_ADR = x"2C" then S_DAT_O(CR2'range)              <= CR2;
        elsif S_ADR = x"38" then S_DAT_O(TRA3_ANZ_STD'range)      <= TRA3_ANZ_STD;
        elsif S_ADR = x"3C" then S_DAT_O(CR3'range)              <= CR3;
        elsif S_ADR = x"40" then S_DAT_O(Status'range)          <= Status;
		end if;		
	end process;

    --Control Register von Kanal_1
    Kontrol_Register0: process(Takt)
    begin
        if rising_edge(Takt) then
            if Reset = '1' then
                CR0 <= x"00000000";
            elsif EnCR0 = '1' then
                CR0  <= S_DAT_I;
            end if;
        end if;
    end process;

    --Control Register von Kanal_2
    Kontrol_Register1: process(Takt)
    begin
        if rising_edge(Takt) then
            if Reset = '1' then
				CR1 <= x"00000000";
            elsif EnCR1 = '1' then
                CR1 <= S_DAT_I;
            end if;
        end if;
    end process;

    --Control Register von Kanal_3
    Kontrol_Register2: process(Takt)
    begin
        if rising_edge(Takt) then
            if Reset = '1' then
				CR2 <= x"00000000";
            elsif EnCR2 = '1' then
                CR2 <= S_DAT_I;
            end if;
        end if;
    end process;

    --Control Register von Kanal_4
    Kontrol_Register3: process(Takt)
    begin
        if rising_edge(Takt) then
            if Reset = '1' then
				CR3 <= x"00000000";
            elsif EnCR3 = '1' then
                CR3 <= S_DAT_I;
            end if;
        end if;
    end process;

    Kanal1: entity work.DMA_Kanal
    generic map(
        BUSWIDTH        => BUSWIDTH,
        WORDWIDTH       => WORDWIDTH
    )port map(
        Takt           => Takt,

        BetriebsMod     => BetriebMod_0,
        Byte_Trans      => ByteTrans_0 ,
        Ex_EreigEn      => ExEreigEn_0,
        Reset           => Reset,
        Tra_Fertig      => TRA0_Fertig,
        Tra_Anzahl_Stand => TRA0_ANZ_STD,
        Slave_Interface  => S_DAT_I,

        S_Ready         => S0_Ready,
        Sou_W           => EnSAR0,
        Dest_W          => EnDEST0,
        Tra_Anz_W       => EnTRAA0,
        M_Valid         => M0_Valid,
        Quittung        => Quittung_0,
        Kanal_Aktiv     => Kanal_Aktiv_0,

        M_STB           => K0_STB_OUT,
        M_WE            => K0_WE_OUT,
        M_ADR           => K0_ADR_OUT,
        M_SEL           => K0_SEL_OUT,
        M_DAT_O         => K0_DAT_OUT,
        M_DAT_I         => K0_DAT_INPUT, 
        M_ACK           => K0_ACK_INPUT
    );

    Kanal2: entity work.DMA_Kanal
    generic map(
        BUSWIDTH        => BUSWIDTH,
        WORDWIDTH       => WORDWIDTH
    )port map(
        Takt           => Takt,

        BetriebsMod     => BetriebMod_1,
        Byte_Trans      => ByteTrans_1,
        Ex_EreigEn      => ExEreigEn_1,
        Reset           => Reset,
        Tra_Fertig      => TRA1_Fertig,
        Tra_Anzahl_Stand => TRA1_ANZ_STD,
        Slave_Interface  => S_DAT_I,

        S_Ready         => S1_Ready,
        Sou_W           => EnSAR1,
        Dest_W          => EnDEST1,
        Tra_Anz_W       => EnTRAA1,
        M_Valid         => M1_Valid,
        Quittung        => Quittung_1,
        Kanal_Aktiv     => Kanal_Aktiv_1,

        M_STB           => K1_STB_OUT,
        M_WE            => K1_WE_OUT,
        M_ADR           => K1_ADR_OUT,
        M_SEL           => K1_SEL_OUT,
        M_DAT_O         => K1_DAT_OUT,
        M_DAT_I         => K1_DAT_INPUT, 
        M_ACK           => K1_ACK_INPUT
    );

    
    Kanal3: entity work.DMA_Kanal
    generic map(
        BUSWIDTH        => BUSWIDTH,
        WORDWIDTH       => WORDWIDTH
    )port map(
        Takt           => Takt,

        BetriebsMod     => BetriebMod_2,
        Byte_Trans      => ByteTrans_2,
        Ex_EreigEn      => ExEreigEn_2,
        Reset           => Reset,
        Tra_Fertig      => TRA2_Fertig,
        Tra_Anzahl_Stand => TRA2_ANZ_STD,
        Slave_Interface  => S_DAT_I,

        S_Ready         => S2_Ready,
        Sou_W           => EnSAR2,
        Dest_W          => EnDEST2,
        Tra_Anz_W       => EnTRAA2,
        M_Valid         => M2_Valid,
        Quittung        => Quittung_2,
        Kanal_Aktiv     => Kanal_Aktiv_2,

        M_STB           => K2_STB_OUT,
        M_WE            => K2_WE_OUT,
        M_ADR           => K2_ADR_OUT,
        M_SEL           => K2_SEL_OUT,
        M_DAT_O         => K2_DAT_OUT,
        M_DAT_I         => K2_DAT_INPUT, 
        M_ACK           => K2_ACK_INPUT
    );

    
    Kanal4: entity work.DMA_Kanal
    generic map(
        BUSWIDTH        => BUSWIDTH,
        WORDWIDTH       => WORDWIDTH
    )port map(
        Takt           => Takt,

        BetriebsMod     => BetriebMod_3,
        Byte_Trans      => ByteTrans_3,
        Ex_EreigEn      => ExEreigEn_3,
        Reset           => Reset,
        Tra_Fertig      => TRA3_Fertig,
        Tra_Anzahl_Stand => TRA3_ANZ_STD,
        Slave_Interface  => S_DAT_I,

        S_Ready         => S3_Ready,
        Sou_W           => EnSAR3,
        Dest_W          => EnDEST3,
        Tra_Anz_W       => EnTRAA3,
        M_Valid         => M3_Valid,
        Quittung        => Quittung_3,
        Kanal_Aktiv     => Kanal_Aktiv_3,

        M_STB           => K3_STB_OUT,
        M_WE            => K3_WE_OUT,
        M_ADR           => K3_ADR_OUT,
        M_SEL           => K3_SEL_OUT,
        M_DAT_O         => K3_DAT_OUT,
        M_DAT_I         => K3_DAT_INPUT, 
        M_ACK           => K3_ACK_INPUT
    );

    Arbiters:block

    signal AR0_M_STB_OUT    : std_logic;
    signal AR0_M_WE_OUT     : std_logic;
    signal AR0_M_ADR_OUT    : std_logic_vector(BUSWIDTH - 1 downto 0);
    signal AR0_M_SEL_OUT    : std_logic_vector(3 downto 0);
    signal AR0_M_ACK_INPUT  : std_logic;
    signal AR0_M_DAT_OUT    : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal AR0_M_DAT_INPUT  : std_logic_vector(WORDWIDTH - 1 downto 0);

    signal AR1_M_STB_OUT    : std_logic;
    signal AR1_M_WE_OUT     : std_logic;
    signal AR1_M_ADR_OUT    : std_logic_vector(BUSWIDTH - 1 downto 0);
    signal AR1_M_SEL_OUT    : std_logic_vector(3 downto 0);
    signal AR1_M_ACK_INPUT  : std_logic;
    signal AR1_M_DAT_OUT    : std_logic_vector(WORDWIDTH - 1 downto 0);
    signal AR1_M_DAT_INPUT  : std_logic_vector(WORDWIDTH - 1 downto 0);

    begin
        --Verbindung von Kanal_1 und Kanal_2
        Arbiter1: entity work.wb_arbiter

        port map(
            -- Clock and Reset
            CLK_I     => Takt,
            RST_I     => Reset,

            -- Slave 0 Interface (priority)
            S0_STB_I  => K0_STB_OUT,
            S0_WE_I   => K0_WE_OUT,
            S0_WRO_I  => '0', -- Kanal1 must not write to ROM
            S0_SEL_I  => K0_SEL_OUT,
            S0_ADR_I  => K0_ADR_OUT,
            S0_ACK_O  => K0_ACK_INPUT,
            S0_DAT_I  => K0_DAT_OUT,
            S0_DAT_O  => K0_DAT_INPUT,
            
            -- Slave 1 Interface
            S1_STB_I  => K1_STB_OUT,
            S1_WE_I   => K1_WE_OUT,
            S1_WRO_I  => '0', -- Kanal2 must not write to ROM
            S1_SEL_I  => K1_SEL_OUT,
            S1_ADR_I  => K1_ADR_OUT,
            S1_ACK_O  => K1_ACK_INPUT,
            S1_DAT_I  => K1_DAT_OUT,
            S1_DAT_O  => K1_DAT_INPUT,
            
            -- Master Interface     
            M_STB_O   => AR0_M_STB_OUT,
            M_WE_O    => AR0_M_WE_OUT,
            M_WRO_O   => open,
            M_ADR_O   => AR0_M_ADR_OUT,
            M_SEL_O   => AR0_M_SEL_OUT,
            M_ACK_I   => AR0_M_ACK_INPUT,
            M_DAT_O   => AR0_M_DAT_OUT,
            M_DAT_I   => AR0_M_DAT_INPUT
        );

        --Verbindung von Kanal_3 und Kanal_4
        Arbiter2: entity work.wb_arbiter

        port map(
            -- Clock and Reset
            CLK_I     => Takt,
            RST_I     => Reset,

            -- Slave 0 Interface (priority)
            S0_STB_I  => K2_STB_OUT,
            S0_WE_I   => K2_WE_OUT,
            S0_WRO_I  => '0', -- Kanal3 must not write to ROM
            S0_SEL_I  => K2_SEL_OUT,
            S0_ADR_I  => K2_ADR_OUT,
            S0_ACK_O  => K2_ACK_INPUT,
            S0_DAT_I  => K2_DAT_OUT,
            S0_DAT_O  => K2_DAT_INPUT,
            
            -- Slave 1 Interface
            S1_STB_I  => K3_STB_OUT,
            S1_WE_I   => K3_WE_OUT,
            S1_WRO_I  => '0', -- Kanal4 must not write to ROM
            S1_SEL_I  => K3_SEL_OUT,
            S1_ADR_I  => K3_ADR_OUT,
            S1_ACK_O  => K3_ACK_INPUT,
            S1_DAT_I  => K3_DAT_OUT,
            S1_DAT_O  => K3_DAT_INPUT,
            
            -- Master Interface
            M_STB_O   => AR1_M_STB_OUT,
            M_WE_O    => AR1_M_WE_OUT,
            M_WRO_O   => open,
            M_ADR_O   => AR1_M_ADR_OUT,
            M_SEL_O   => AR1_M_SEL_OUT,
            M_ACK_I   => AR1_M_ACK_INPUT,
            M_DAT_O   => AR1_M_DAT_OUT,
            M_DAT_I   => AR1_M_DAT_INPUT
        );

        --Verbindung von den Arbitern 1 und 2
        Arbiter3: entity work.wb_arbiter

        port map(
            -- Clock and Reset
            CLK_I     => Takt,
            RST_I     => Reset,

            -- Slave 0 Interface (priority)
            S0_STB_I  => AR0_M_STB_OUT,
            S0_WE_I   => AR0_M_WE_OUT,
            S0_WRO_I  => '0', -- Arbiter1 must not write to ROM
            S0_SEL_I  => AR0_M_SEL_OUT,
            S0_ADR_I  => AR0_M_ADR_OUT,
            S0_ACK_O  => AR0_M_ACK_INPUT,
            S0_DAT_I  => AR0_M_DAT_OUT,
            S0_DAT_O  => AR0_M_DAT_INPUT,

            -- Slave 1 Interface
            S1_STB_I  => AR1_M_STB_OUT,
            S1_WE_I   => AR1_M_WE_OUT,
            S1_WRO_I  => '0', -- Arbiter2 must not write to ROM
            S1_SEL_I  => AR1_M_SEL_OUT,
            S1_ADR_I  => AR1_M_ADR_OUT,
            S1_ACK_O  => AR1_M_ACK_INPUT,
            S1_DAT_I  => AR1_M_DAT_OUT,
            S1_DAT_O  => AR1_M_DAT_INPUT,
            
            -- Master Interface
            M_STB_O   => M_STB,
            M_WE_O    => M_WE,
            M_WRO_O   => open,
            M_ADR_O   => M_ADR,
            M_SEL_O   => M_SEL,
            M_ACK_I   => M_ACK,
            M_DAT_O   => M_DAT_O,
            M_DAT_I   => M_DAT_I
        );

    end block;

end architecture;
