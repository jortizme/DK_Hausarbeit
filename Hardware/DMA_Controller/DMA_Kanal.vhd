-------------------------------------------------------------------------------
-- DMA-Kanal
-------------------------------------------------------------------------------
-- Modul Digitale Komponenten
-- Hochschule Osnabrueck
-- Joaquin Ortiz, Filip Mijac
-------------------------------------------------------------------------------
--
-- Betriebsmodus:
--   00 - Speicher-Speicher
--   01 - Peripherie-Speicher
--   10 - Speicher-Peripherie
--   11 - *Nicht-Definiert*

-- Byte_Trans
-- 0 - False, es wird wortweise übertragen
-- 1 - True, es wird byteweise übertragen

-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DMA_Kanal is
    generic(
        BUSWIDTH : positive;
        WORDWIDTH : positive
    );
    port(
        Takt            : in std_logic;

        BetriebsMod     : in std_logic_vector(1 downto 0);
        Byte_Trans      : in std_logic;
        Ex_EreigEn      : in std_logic;
        Reset           : in std_logic;
        Tra_Fertig      : out std_logic;
        Tra_Anzahl_Stand: out std_logic_vector(WORDWIDTH - 1 downto 0);
        Slave_Interface : in  std_logic_vector(WORDWIDTH - 1 downto 0);

        S_Ready         : in std_logic;
        Sou_W           : in std_logic;
        Dest_W          : in std_logic;
        Tra_Anz_W       : in std_logic;
        M_Valid         : in std_logic;
        Quittung        : in std_logic;
        Kanal_Aktiv     : out std_logic;

        M_STB           : out std_logic;
        M_WE            : out std_logic;
        M_ADR           : out std_logic_vector(BUSWIDTH - 1 downto 0);
        M_SEL           : out std_logic_vector(3 downto 0);
        M_DAT_O         : out std_logic_vector(WORDWIDTH - 1 downto 0);
        M_DAT_I         : in std_logic_vector(WORDWIDTH - 1 downto 0);
        M_ACK           : in std_logic
    );

end entity;

architecture rtl of DMA_Kanal is

    -- Typ fuer die Ansteuerung des Multiplexers
    type AdrDemul_type is (S,D,X);
    
    -- Signale zwischen Steuerwerk und Rechenwerk
    signal AdrSel       : AdrDemul_type := X;
    signal SourceEn     : std_logic;
    signal DestEn       : std_logic;     
    signal CntEn        : std_logic;
    signal DataEn       : std_logic;
    signal CntTC        : std_logic := '0';
    signal Byte_Trans_i  : std_logic;
    signal BetriebsMod_i : std_logic_vector(1 downto 0);

begin

    Rechenwerk: block

        --Interne Signale des Rechenwerks
        signal M_DAT_Out_i   :   std_logic_vector(WORDWIDTH - 1 downto 0) := (others => '0');
        signal M_ADR_i       :  std_logic_vector(BUSWIDTH - 1 downto 0) := (others => '0');
        signal M_SEL_i       :   std_logic_vector(3 downto 0);
        signal Sour_A_Out    :   std_logic_vector(BUSWIDTH - 1 downto 0) := (others => '0');
        signal Dest_A_Out    :   std_logic_vector(BUSWIDTH - 1 downto 0) := (others => '0');
        signal Sel_Sou_Byte  :   std_logic_vector(1 downto 0);
        signal Sel_Dest_Byte :  std_logic_vector(1 downto 0);
        signal Zwei_Bits_Adr :  std_logic_vector(1 downto 0);
        signal ByteMod_Addr_i  :  std_logic_vector(BUSWIDTH - 1 downto 0);
        signal ByteMod_Dat_i :  std_logic_vector(WORDWIDTH - 1 downto 0) := (others => '0');
        signal Vergleicher_o_Sou :  std_logic_vector(BUSWIDTH - 1 downto 0) := (others => '0');
        signal Vergleicher_o_Dest :  std_logic_vector(BUSWIDTH - 1 downto 0) := (others => '0');
        signal OutputData_i  : std_logic_vector(WORDWIDTH - 1 downto 0);
        signal Tra_Anzahl_Stand_i :  std_logic_vector(WORDWIDTH - 1 downto 0) := (others => '0');

    begin

        Zwei_Bits_Adr <= M_ADR_i(1 downto 0);
        Sel_Sou_Byte  <= Sour_A_Out(1 downto 0);
        Sel_Dest_Byte <= Dest_A_Out(1 downto 0);

        --Wert des internen Signals an Port zuweisen
        process(M_DAT_Out_i, Tra_Anzahl_Stand_i)
        begin
            M_DAT_O  <= M_DAT_Out_i;
            Tra_Anzahl_Stand <=  Tra_Anzahl_Stand_i;
        end process;

        --Beschreibung: Speichert die Source-Adresse und erhöht sie 
        SourceAdrRegister: process(Takt)
            variable AnfangsAdresse :  unsigned(31 downto 0) := (others => '0');
            variable Aktuelle_Adresse :  unsigned(31 downto 0) := (others => '0');
        begin

            if rising_edge(Takt) then 

                if Reset = '1' then
                    Aktuelle_Adresse := (others => '0');
                    AnfangsAdresse := (others => '0');

                elsif Sou_W = '1' then
                    AnfangsAdresse := unsigned(Slave_Interface);

                elsif M_Valid = '1' then
                    Aktuelle_Adresse := AnfangsAdresse;

                elsif SourceEn = '1' then

                    if Byte_Trans_i = '0' then
                        Aktuelle_Adresse := Aktuelle_Adresse  + 4;
                    else
                        Aktuelle_Adresse := Aktuelle_Adresse  + 1;
                    end if;

                end if;
            
                Sour_A_Out <= std_logic_vector(Aktuelle_Adresse);
            end if;

        end process;

        --Beschreibung: Speichert die Destination-Adresse und erhöht sie 
        DestAdrRegister: process(Takt)
            variable AnfangsAdresse :  unsigned(31 downto 0) := (others => '0');
            variable Aktuelle_Adresse :  unsigned(31 downto 0) := (others => '0');
        begin

            if rising_edge(Takt) then 

                if Reset = '1' then
                    Aktuelle_Adresse := (others => '0');
                    AnfangsAdresse := (others => '0');

                elsif Dest_W = '1' then
                    AnfangsAdresse := unsigned(Slave_Interface);
    
                elsif M_Valid = '1' then
                    Aktuelle_Adresse := AnfangsAdresse;

                elsif DestEn = '1' then

                    if Byte_Trans_i = '0' then
                        Aktuelle_Adresse := Aktuelle_Adresse  + 4;
                    else
                        Aktuelle_Adresse := Aktuelle_Adresse  + 1;
                    end if;

                end if;
            
                Dest_A_Out <= std_logic_vector(Aktuelle_Adresse);
            end if;

        end process;

        --Beschreibung: Speichert den Wert der Adresse, deren letzten beiden Bits 
        --mit "00" enden. Erforderlich im byteweisen Transfer. 
        Addresvergleicher_Source: process(Takt)
            variable Q : std_logic_vector(31 downto 0) := (others => '0');
        begin

            if rising_edge(Takt) then
                
                Q := Sour_A_Out; 

                if Reset = '1' then
                    Vergleicher_o_Sou <= (others => '0');
                    
                elsif Q(1 downto 0) /= "00" then
                    Q(1 downto 0) := (others => '0');
                end if;

                Vergleicher_o_Sou <= Q;
            end if;
        end process;

                --Beschreibung: Speichert den Wert der Adresse, deren letzten beiden Bits 
        --mit "00" enden. Erforderlich im byteweisen Transfer. 
        Addresvergleicher_Destination: process(Takt)
            variable Q : std_logic_vector(31 downto 0) := (others => '0');
        begin    
            if rising_edge(Takt) then

                Q := Dest_A_Out;

                if Reset = '1' then
                    Vergleicher_o_Dest <= (others => '0');
                    
                elsif Q(1 downto 0) /= "00" then
                    Q(1 downto 0) := (others => '0');
                end if;

                Vergleicher_o_Dest <= Q;
            end if;
        end process;

        --Beschreibung: Kombinatorischer Block zur Bestimmung der M_Adr im
        --byteweisen Transfer.
        Block_A: process(BetriebsMod_i, AdrSel, Vergleicher_o_Sou, Vergleicher_o_Dest, M_ADR_i)
        variable Q : std_logic_vector(BUSWIDTH - 1 downto 0) := (others => '0');
        begin       

            if ((BetriebsMod_i = "10" or BetriebsMod_i = "00") and AdrSel = S)  then
                ByteMod_Addr_i <= Vergleicher_o_Sou;
            
            elsif ((BetriebsMod_i = "01" or BetriebsMod_i = "00") and AdrSel = D) then
                ByteMod_Addr_i <= Vergleicher_o_Dest;
                
            elsif ((BetriebsMod_i = "10" and AdrSel = D) or (BetriebsMod_i = "01" and AdrSel = S)) then
                Q := M_ADR_i;
                if Q (1 downto 0) /= "00" then
                    Q(1 downto 0) := "00";
                end if;
                ByteMod_Addr_i <= Q;
            end if;

        end process;

        --Dieser Prozess sorgt für eine Umwandlung von WortModus in ByteModus,
        --wenn im SPEI-SPEI-Modus eine nicht aligned Source-Addresse kommt, oder wenn
        --das ganze Wort nicht zu kopieren ist
        Dynamische_Parametrierung: process(BetriebsMod, Byte_Trans, Tra_Anzahl_Stand_i, Sour_A_Out, Dest_A_Out)
        variable Q : std_logic_vector(1 downto 0) := (others => '0');
        variable V : std_logic_vector(1 downto 0) := (others => '0');
        begin

            Q := Sour_A_Out(1 downto 0);
            V := Dest_A_Out(1 downto 0);

            if Byte_Trans = '1' and (BetriebsMod = "10" or  BetriebsMod = "01") then
                Byte_Trans_i <= Byte_Trans;

            elsif Byte_Trans = '0' then

                if BetriebsMod = "00" and (Q /= "00" or V /= "00" ) then
                    Byte_Trans_i <= '1'; -- Byte_Modus

                elsif BetriebsMod = "10" or BetriebsMod = "00"  then
            
                    if Q /= "00" or (Q = "00" and unsigned(Tra_Anzahl_Stand_i) < 5)then
                        Byte_Trans_i <= '1'; -- Byte_Modus

                    elsif Q = "00" and unsigned(Tra_Anzahl_Stand_i) >= 5 then
                        Byte_Trans_i <= '0'; -- Wort_Modus
                    end if;

                elsif BetriebsMod = "01" then

                    if V /= "00" or (V = "00" and unsigned(Tra_Anzahl_Stand_i) < 5)then
                        Byte_Trans_i <= '1'; -- Byte_Modus

                    elsif V = "00" and unsigned(Tra_Anzahl_Stand_i) >= 5 then
                        Byte_Trans_i <= '0'; -- Wort_Modus
                    end if;

                end if;

            end if;

            if Byte_Trans = '1' and BetriebsMod = "00" then
                BetriebsMod_i <= "11";
            else
            BetriebsMod_i <= BetriebsMod;
            end if;
            
        end process;

        --Zähler
        Zaehler:process(Takt)
            variable AnfangsWert : unsigned(WORDWIDTH - 1 downto 0) := (others => '0');            
            variable Aktueller_Wert : unsigned(WORDWIDTH - 1 downto 0) := (others => '0');
        begin
            if rising_edge(Takt) then
            
                CntTC <= '0';

                if Reset = '1' then
                    Aktueller_Wert := (others => '0');

                elsif Tra_Anz_W = '1' then
                    AnfangsWert := unsigned(Slave_Interface) - 1;

                elsif M_Valid = '1' then
                    Aktueller_Wert := AnfangsWert;

                elsif CntEn = '1' then

                    if Byte_Trans_i = '1' then
                        Aktueller_Wert := Aktueller_Wert - 1;
                    elsif Byte_Trans_i = '0' then
                        Aktueller_Wert := Aktueller_Wert - 4;
                    end if;
                end if; 

                if Aktueller_Wert = 0 then
					CntTC <= '1';
                end if;

                Tra_Anzahl_Stand_i <= std_logic_vector(Aktueller_Wert + 1) ;
                
            end if;
        end process;

        --Beschreibung: Bestimmt die interne M_ADR
        AddresMult:process(AdrSel, Sour_A_Out, Dest_A_Out)
        begin
            case (AdrSel) is
                when S => M_ADR_i <= Sour_A_Out;
                when D => M_ADR_i <= Dest_A_Out;
                when others => M_ADR_i <= (others => '0') ;
            end case;
        end process;

        --Beschreibung: Bestimmt den internen Sel_Vektor
        SelMult:process(Zwei_Bits_Adr)
        begin
            case(Zwei_Bits_Adr) is
                when "00" =>   M_SEL_i <= "0001";  
                when "01" =>   M_SEL_i <= "0010"; 
                when "10" =>   M_SEL_i <= "0100"; 
                when "11" =>   M_SEL_i <= "1000";
                when others => null;
            end case;
        end process;

        --Beschreibung: Bestimmt welches Byte wird im Lesevorgang gelesen, und
        --in welche Position soll es im Schreibvorgang verchoben werden
        ByteMult:process(Sel_Sou_Byte, Sel_Dest_Byte, M_DAT_I)
        variable Byte       :   std_logic_vector(7 downto 0) := (others => '0');
        variable Wort       :   std_logic_vector(31 downto 0) := (others => '0');

        begin

            Wort := (others => '0');

            case(Sel_Sou_Byte) is
                when "00" =>   Byte := M_DAT_I(7 downto 0);
                when "01" =>   Byte := M_DAT_I(15 downto 8);
                when "10" =>   Byte := M_DAT_I(23 downto 16);
                when "11" =>   Byte := M_DAT_I(31 downto 24);
                when others => null;
            end case;

            case(Sel_Dest_Byte) is
                when "00" =>    Wort(7 downto 0)   := Byte;
                when "01" =>    Wort(15 downto 8)  := Byte;
                when "10" =>    Wort(23 downto 16) := Byte;
                when "11" =>    Wort(31 downto 24) := Byte;
                when others => null;
            end case;

            ByteMod_Dat_i <= Wort;

        end process;

        --Beschreibung: Schaltet die Signale zum Bus
        OutputMult: process(M_ADR_i,ByteMod_Addr_i,M_SEL_i,ByteMod_Dat_i, Byte_Trans_i, M_DAT_I)
        
        begin
            case(Byte_Trans_i) is
                when '0'    =>  M_SEL <= "1111";
                                M_ADR  <= M_ADR_i;
                                OutputData_i <= M_DAT_I;

                when '1'    =>  M_SEL <= M_SEL_i;
                                M_ADR <= ByteMod_Addr_i;
                                OutputData_i <= ByteMod_Dat_i;
                when others => null;
            end case;

        end process;
        
        --Beschreibung: Speichert den gelesenen Wert um ihn im Schreibvorgang
        --zu senden
        Output_Data_Reg: process(Takt)
        begin

            if rising_edge(Takt) then
                
                if Reset = '1' then
                    M_DAT_Out_i <= (others => '0');
                    
                elsif DataEn = '1' then
                    M_DAT_Out_i <= OutputData_i;
                end if;
            end if;

        end process;

    end block;

    Steuerwerk: block

    --Typ fuer die Zustandswerte 
    type Zustand_type is (Z_IDLE, Z_WAIT, Z_LESE, Z_WRITE, Z_FERTIG, Z_ERROR);

    --Interne Signale des Steuerwerks
    signal Zustand      : Zustand_type := Z_IDLE;
    signal Folgezustand : Zustand_type;	

    --Interne Signale für die Initialisierung
    signal STB_i            : std_logic := '0';
    signal WE_i             : std_logic := '0';
    signal Tra_Fertig_i     : std_logic := '0';
    signal Kanal_Aktiv_i    : std_logic := '0';

    begin

        --Wer des internen Signals an Port zuweisen
        process(STB_i, WE_i, Tra_Fertig_i, Kanal_Aktiv_i)
        begin
            M_STB <= STB_i;
            M_WE <= WE_i;
            Tra_Fertig <= Tra_Fertig_i;
            Kanal_Aktiv <= Kanal_Aktiv_i;
        end process;


    -- Prozess zur Berechnung des Folgezustands und der Mealy-Ausgaenge
    Transition: process(Zustand, M_Valid, Quittung , Ex_EreigEn, S_Ready, M_ACK, CntTC, BetriebsMod_i,  Byte_Trans_i)
    begin

        -- Default-Werte fuer den Folgezustand und die Mealy-Ausgaenge
        SourceEn     <= '0';
        DestEn       <= '0';     
        CntEn        <= '0';
        DataEn       <= '0';
        Folgezustand <= Z_ERROR;
        
        case( Zustand ) is

            when Z_IDLE =>  
                            if BetriebsMod_i = "11" or (BetriebsMod_i = "00" and Ex_EreigEn = '1') then
                                Folgezustand <= Z_IDLE;

                            elsif M_Valid = '0' then
                                Folgezustand <= Z_IDLE;

                            elsif M_Valid = '1' then
                                Folgezustand <= Z_WAIT;
                            end if; 
            when Z_WAIT =>
                            if Ex_EreigEn = '1' and S_Ready = '0' then
                                Folgezustand <= Z_WAIT;
                    
                            elsif Ex_EreigEn = '0'  or (Ex_EreigEn = '1' and S_Ready = '1') then
                                Folgezustand <= Z_LESE;
                            end if;
            when Z_LESE =>
                            if M_ACK = '0' then
                                Folgezustand <= Z_LESE;

                            elsif M_ACK = '1' then
                                DataEn <= '1';
                                Folgezustand <= Z_WRITE;
                            end if;
            when Z_WRITE =>
                            if M_ACK = '0' then
                                Folgezustand <= Z_WRITE;

                            elsif M_ACK = '1' and CntTC = '1' then
                                Folgezustand <= Z_FERTIG;

                            elsif M_ACK = '1' and CntTC = '0'then
                                CntEn <= '1';
                                case(BetriebsMod_i) is
                                    when "00" => DestEn <= '1'; SourceEn <= '1';
                                    when "01" => DestEn <= '1';
                                    when "10" => SourceEn <= '1';
                                    when others => null;
                                end case;
                                Folgezustand <= Z_WAIT;
                            end if;          
            when Z_FERTIG =>
                            if Quittung = '0' then
                                Folgezustand <= Z_FERTIG;

                            elsif Quittung = '1' then
                                Folgezustand <= Z_IDLE;
                            end if;
            when Z_ERROR => null;

        end case;
    end process;


		-- Register fuer Zustand und Moore-Ausgaenge
		Reg: process(Takt)
		begin
			if rising_edge(Takt) then
            
                if Reset = '1' then
                    Zustand <= Z_IDLE;
                else
                    Zustand <= Folgezustand;
                end if;

                if Reset = '1' then
                    STB_i <='0'; WE_i <='0'; AdrSel <= X; Tra_Fertig_i <='0'; Kanal_Aktiv_i <= '0';
                else
                    case (Folgezustand) is
                        when Z_IDLE =>
                                        STB_i        <='0';
                                        WE_i         <='0';
                                        AdrSel       <= X;
                                        Tra_Fertig_i <='0';
                                        Kanal_Aktiv_i <= '0';
                        when Z_WAIT =>
                                        STB_i        <='0';
                                        WE_i         <='0';
                                        AdrSel       <= X;
                                        Tra_Fertig_i <='0';
                                        Kanal_Aktiv_i <= '1';
                        when Z_LESE =>
                                        STB_i        <='1';
                                        WE_i         <='0';
                                        AdrSel       <= S;
                                        Tra_Fertig_i <='0';
                                        Kanal_Aktiv_i <= '1';
                        when Z_WRITE =>
                                        STB_i        <='1';
                                        WE_i         <='1';
                                        AdrSel       <= D;
                                        Tra_Fertig_i <='0';
                                        Kanal_Aktiv_i <= '1';
                        when Z_FERTIG =>
                                        STB_i        <='0';
                                        WE_i         <='0';
                                        AdrSel       <= X;
                                        Tra_Fertig_i <='1';
                                        Kanal_Aktiv_i <= '1';
                        when Z_ERROR =>
                                        STB_i        <='X';
                                        WE_i         <='X';
                                        AdrSel       <= X;
                                        Tra_Fertig_i <='X';
                                        Kanal_Aktiv_i <= 'X';
                    end case;
                end if;
            end if;
        end process;
    end block;

end architecture ; 


