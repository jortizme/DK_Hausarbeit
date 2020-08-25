library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity charset_v1_0 is
  port(
    clk       : in  std_ulogic;
    char_code : in  std_ulogic_vector(7 downto 0);
    char_line : in  std_ulogic_vector(3 downto 0);
    data      : out std_ulogic_vector(7 downto 0)
  );
end entity;

architecture rom of charset_v1_0 is
  type memory_t is array (0 to 4095) of std_ulogic_vector(data'range);
  constant memory : memory_t := (
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 0
    x"00", x"00", x"7e", x"81", x"a5", x"81", x"81", x"bd", x"99", x"81", x"7e", x"00", x"00", x"00", x"00", x"00", -- 1
    x"00", x"00", x"7e", x"ff", x"db", x"ff", x"ff", x"c3", x"e7", x"ff", x"7e", x"00", x"00", x"00", x"00", x"00", -- 2
    x"00", x"00", x"00", x"6c", x"fe", x"fe", x"fe", x"fe", x"7c", x"38", x"10", x"00", x"00", x"00", x"00", x"00", -- 3
    x"00", x"00", x"00", x"10", x"38", x"7c", x"fe", x"7c", x"38", x"10", x"00", x"00", x"00", x"00", x"00", x"00", -- 4
    x"00", x"00", x"18", x"3c", x"3c", x"e7", x"e7", x"e7", x"18", x"18", x"3c", x"00", x"00", x"00", x"00", x"00", -- 5
    x"00", x"00", x"18", x"3c", x"7e", x"ff", x"ff", x"7e", x"18", x"18", x"3c", x"00", x"00", x"00", x"00", x"00", -- 6
    x"00", x"00", x"00", x"00", x"00", x"18", x"3c", x"3c", x"18", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 7
    x"ff", x"ff", x"ff", x"ff", x"ff", x"e7", x"c3", x"c3", x"e7", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"00", -- 8
    x"00", x"00", x"00", x"00", x"3c", x"66", x"42", x"42", x"66", x"3c", x"00", x"00", x"00", x"00", x"00", x"00", -- 9
    x"ff", x"ff", x"ff", x"ff", x"c3", x"99", x"bd", x"bd", x"99", x"c3", x"ff", x"ff", x"ff", x"ff", x"00", x"00", -- 10
    x"00", x"00", x"1e", x"0e", x"1a", x"32", x"78", x"cc", x"cc", x"cc", x"78", x"00", x"00", x"00", x"00", x"00", -- 11
    x"00", x"00", x"3c", x"66", x"66", x"66", x"3c", x"18", x"7e", x"18", x"18", x"00", x"00", x"00", x"00", x"00", -- 12
    x"00", x"00", x"3f", x"33", x"3f", x"30", x"30", x"30", x"70", x"f0", x"e0", x"00", x"00", x"00", x"00", x"00", -- 13
    x"00", x"00", x"7f", x"63", x"7f", x"63", x"63", x"63", x"67", x"e7", x"e6", x"c0", x"00", x"00", x"00", x"00", -- 14
    x"00", x"00", x"18", x"18", x"db", x"3c", x"e7", x"3c", x"db", x"18", x"18", x"00", x"00", x"00", x"00", x"00", -- 15
    x"00", x"00", x"80", x"c0", x"e0", x"f8", x"fe", x"f8", x"e0", x"c0", x"80", x"00", x"00", x"00", x"00", x"00", -- 16
    x"00", x"00", x"02", x"06", x"0e", x"3e", x"fe", x"3e", x"0e", x"06", x"02", x"00", x"00", x"00", x"00", x"00", -- 17
    x"00", x"00", x"18", x"3c", x"7e", x"18", x"18", x"18", x"7e", x"3c", x"18", x"00", x"00", x"00", x"00", x"00", -- 18
    x"00", x"00", x"66", x"66", x"66", x"66", x"66", x"66", x"00", x"66", x"66", x"00", x"00", x"00", x"00", x"00", -- 19
    x"00", x"00", x"7f", x"db", x"db", x"db", x"7b", x"1b", x"1b", x"1b", x"1b", x"00", x"00", x"00", x"00", x"00", -- 20
    x"00", x"7c", x"c6", x"60", x"38", x"6c", x"c6", x"c6", x"6c", x"38", x"0c", x"c6", x"7c", x"00", x"00", x"00", -- 21
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"fe", x"fe", x"fe", x"00", x"00", x"00", x"00", x"00", -- 22
    x"00", x"00", x"18", x"3c", x"7e", x"18", x"18", x"18", x"7e", x"3c", x"18", x"7e", x"00", x"00", x"00", x"00", -- 23
    x"00", x"00", x"18", x"3c", x"7e", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", x"00", x"00", x"00", -- 24
    x"00", x"00", x"18", x"18", x"18", x"18", x"18", x"18", x"7e", x"3c", x"18", x"00", x"00", x"00", x"00", x"00", -- 25
    x"00", x"00", x"00", x"00", x"18", x"0c", x"fe", x"0c", x"18", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 26
    x"00", x"00", x"00", x"00", x"30", x"60", x"fe", x"60", x"30", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 27
    x"00", x"00", x"00", x"00", x"00", x"c0", x"c0", x"c0", x"fe", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 28
    x"00", x"00", x"00", x"00", x"28", x"6c", x"fe", x"6c", x"28", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 29
    x"00", x"00", x"00", x"10", x"38", x"38", x"7c", x"7c", x"fe", x"fe", x"00", x"00", x"00", x"00", x"00", x"00", -- 30
    x"00", x"00", x"00", x"fe", x"fe", x"7c", x"7c", x"38", x"38", x"10", x"00", x"00", x"00", x"00", x"00", x"00", -- 31
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 32 ' '
    x"00", x"00", x"18", x"3c", x"3c", x"3c", x"18", x"18", x"00", x"18", x"18", x"00", x"00", x"00", x"00", x"00", -- 33 '!'
    x"00", x"66", x"66", x"66", x"24", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 34 '"'
    x"00", x"00", x"6c", x"6c", x"fe", x"6c", x"6c", x"6c", x"fe", x"6c", x"6c", x"00", x"00", x"00", x"00", x"00", -- 35 '#'
    x"18", x"18", x"7c", x"c6", x"c2", x"c0", x"7c", x"06", x"86", x"c6", x"7c", x"18", x"18", x"00", x"00", x"00", -- 36 '$'
    x"00", x"00", x"00", x"00", x"c2", x"c6", x"0c", x"18", x"30", x"66", x"c6", x"00", x"00", x"00", x"00", x"00", -- 37 '%'
    x"00", x"00", x"38", x"6c", x"6c", x"38", x"76", x"dc", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 38 '&'
    x"00", x"30", x"30", x"30", x"60", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 39 '''
    x"00", x"00", x"0c", x"18", x"30", x"30", x"30", x"30", x"30", x"18", x"0c", x"00", x"00", x"00", x"00", x"00", -- 40 '('
    x"00", x"00", x"30", x"18", x"0c", x"0c", x"0c", x"0c", x"0c", x"18", x"30", x"00", x"00", x"00", x"00", x"00", -- 41 ')'
    x"00", x"00", x"00", x"00", x"66", x"3c", x"ff", x"3c", x"66", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 42 '*'
    x"00", x"00", x"00", x"00", x"18", x"18", x"7e", x"18", x"18", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 43 '+'
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"18", x"18", x"18", x"30", x"00", x"00", x"00", x"00", -- 44 ','
    x"00", x"00", x"00", x"00", x"00", x"00", x"fe", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 45 '-'
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"18", x"18", x"00", x"00", x"00", x"00", x"00", -- 46 '.'
    x"00", x"00", x"02", x"06", x"0c", x"18", x"30", x"60", x"c0", x"80", x"00", x"00", x"00", x"00", x"00", x"00", -- 47 '/'
    x"00", x"00", x"7c", x"c6", x"ce", x"de", x"f6", x"e6", x"c6", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 48 '0'
    x"00", x"00", x"18", x"38", x"78", x"18", x"18", x"18", x"18", x"18", x"7e", x"00", x"00", x"00", x"00", x"00", -- 49 '1'
    x"00", x"00", x"7c", x"c6", x"06", x"0c", x"18", x"30", x"60", x"c6", x"fe", x"00", x"00", x"00", x"00", x"00", -- 50 '2'
    x"00", x"00", x"7c", x"c6", x"06", x"06", x"3c", x"06", x"06", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 51 '3'
    x"00", x"00", x"0c", x"1c", x"3c", x"6c", x"cc", x"fe", x"0c", x"0c", x"1e", x"00", x"00", x"00", x"00", x"00", -- 52 '4'
    x"00", x"00", x"fe", x"c0", x"c0", x"c0", x"fc", x"06", x"06", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 53 '5'
    x"00", x"00", x"38", x"60", x"c0", x"c0", x"fc", x"c6", x"c6", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 54 '6'
    x"00", x"00", x"fe", x"c6", x"06", x"0c", x"18", x"30", x"30", x"30", x"30", x"00", x"00", x"00", x"00", x"00", -- 55 '7'
    x"00", x"00", x"7c", x"c6", x"c6", x"c6", x"7c", x"c6", x"c6", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 56 '8'
    x"00", x"00", x"7c", x"c6", x"c6", x"c6", x"7e", x"06", x"06", x"0c", x"78", x"00", x"00", x"00", x"00", x"00", -- 57 '9'
    x"00", x"00", x"00", x"18", x"18", x"00", x"00", x"00", x"18", x"18", x"00", x"00", x"00", x"00", x"00", x"00", -- 58 ':'
    x"00", x"00", x"00", x"18", x"18", x"00", x"00", x"00", x"18", x"18", x"30", x"00", x"00", x"00", x"00", x"00", -- 59 ';'
    x"00", x"00", x"06", x"0c", x"18", x"30", x"60", x"30", x"18", x"0c", x"06", x"00", x"00", x"00", x"00", x"00", -- 60 '<'
    x"00", x"00", x"00", x"00", x"00", x"7e", x"00", x"00", x"7e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 61 '='
    x"00", x"00", x"60", x"30", x"18", x"0c", x"06", x"0c", x"18", x"30", x"60", x"00", x"00", x"00", x"00", x"00", -- 62 '>'
    x"00", x"00", x"7c", x"c6", x"c6", x"0c", x"18", x"18", x"00", x"18", x"18", x"00", x"00", x"00", x"00", x"00", -- 63 '?'
    x"00", x"00", x"7c", x"c6", x"c6", x"de", x"de", x"de", x"dc", x"c0", x"7c", x"00", x"00", x"00", x"00", x"00", -- 64 '@'
    x"00", x"00", x"10", x"38", x"6c", x"c6", x"c6", x"fe", x"c6", x"c6", x"c6", x"00", x"00", x"00", x"00", x"00", -- 65 'A'
    x"00", x"00", x"fc", x"66", x"66", x"66", x"7c", x"66", x"66", x"66", x"fc", x"00", x"00", x"00", x"00", x"00", -- 66 'B'
    x"00", x"00", x"3c", x"66", x"c2", x"c0", x"c0", x"c0", x"c2", x"66", x"3c", x"00", x"00", x"00", x"00", x"00", -- 67 'C'
    x"00", x"00", x"f8", x"6c", x"66", x"66", x"66", x"66", x"66", x"6c", x"f8", x"00", x"00", x"00", x"00", x"00", -- 68 'D'
    x"00", x"00", x"fe", x"66", x"62", x"68", x"78", x"68", x"62", x"66", x"fe", x"00", x"00", x"00", x"00", x"00", -- 69 'E'
    x"00", x"00", x"fe", x"66", x"62", x"68", x"78", x"68", x"60", x"60", x"f0", x"00", x"00", x"00", x"00", x"00", -- 70 'F'
    x"00", x"00", x"3c", x"66", x"c2", x"c0", x"c0", x"de", x"c6", x"66", x"3a", x"00", x"00", x"00", x"00", x"00", -- 71 'G'
    x"00", x"00", x"c6", x"c6", x"c6", x"c6", x"fe", x"c6", x"c6", x"c6", x"c6", x"00", x"00", x"00", x"00", x"00", -- 72 'H'
    x"00", x"00", x"3c", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"3c", x"00", x"00", x"00", x"00", x"00", -- 73 'I'
    x"00", x"00", x"1e", x"0c", x"0c", x"0c", x"0c", x"0c", x"cc", x"cc", x"78", x"00", x"00", x"00", x"00", x"00", -- 74 'J'
    x"00", x"00", x"e6", x"66", x"6c", x"6c", x"78", x"6c", x"6c", x"66", x"e6", x"00", x"00", x"00", x"00", x"00", -- 75 'K'
    x"00", x"00", x"f0", x"60", x"60", x"60", x"60", x"60", x"62", x"66", x"fe", x"00", x"00", x"00", x"00", x"00", -- 76 'L'
    x"00", x"00", x"c6", x"ee", x"fe", x"fe", x"d6", x"c6", x"c6", x"c6", x"c6", x"00", x"00", x"00", x"00", x"00", -- 77 'M'
    x"00", x"00", x"c6", x"e6", x"f6", x"fe", x"de", x"ce", x"c6", x"c6", x"c6", x"00", x"00", x"00", x"00", x"00", -- 78 'N'
    x"00", x"00", x"38", x"6c", x"c6", x"c6", x"c6", x"c6", x"c6", x"6c", x"38", x"00", x"00", x"00", x"00", x"00", -- 79 'O'
    x"00", x"00", x"fc", x"66", x"66", x"66", x"7c", x"60", x"60", x"60", x"f0", x"00", x"00", x"00", x"00", x"00", -- 80 'P'
    x"00", x"00", x"7c", x"c6", x"c6", x"c6", x"c6", x"d6", x"de", x"7c", x"0c", x"0e", x"00", x"00", x"00", x"00", -- 81 'Q'
    x"00", x"00", x"fc", x"66", x"66", x"66", x"7c", x"6c", x"66", x"66", x"e6", x"00", x"00", x"00", x"00", x"00", -- 82 'R'
    x"00", x"00", x"7c", x"c6", x"c6", x"60", x"38", x"0c", x"c6", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 83 'S'
    x"00", x"00", x"7e", x"7e", x"5a", x"18", x"18", x"18", x"18", x"18", x"3c", x"00", x"00", x"00", x"00", x"00", -- 84 'T'
    x"00", x"00", x"c6", x"c6", x"c6", x"c6", x"c6", x"c6", x"c6", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 85 'U'
    x"00", x"00", x"c6", x"c6", x"c6", x"c6", x"c6", x"c6", x"6c", x"38", x"10", x"00", x"00", x"00", x"00", x"00", -- 86 'V'
    x"00", x"00", x"c6", x"c6", x"c6", x"c6", x"d6", x"d6", x"fe", x"7c", x"6c", x"00", x"00", x"00", x"00", x"00", -- 87 'W'
    x"00", x"00", x"c6", x"c6", x"6c", x"38", x"38", x"38", x"6c", x"c6", x"c6", x"00", x"00", x"00", x"00", x"00", -- 88 'X'
    x"00", x"00", x"66", x"66", x"66", x"66", x"3c", x"18", x"18", x"18", x"3c", x"00", x"00", x"00", x"00", x"00", -- 89 'Y'
    x"00", x"00", x"fe", x"c6", x"8c", x"18", x"30", x"60", x"c2", x"c6", x"fe", x"00", x"00", x"00", x"00", x"00", -- 90 'Z'
    x"00", x"00", x"3c", x"30", x"30", x"30", x"30", x"30", x"30", x"30", x"3c", x"00", x"00", x"00", x"00", x"00", -- 91 '['
    x"00", x"00", x"80", x"c0", x"e0", x"70", x"38", x"1c", x"0e", x"06", x"02", x"00", x"00", x"00", x"00", x"00", -- 92 '\'
    x"00", x"00", x"3c", x"0c", x"0c", x"0c", x"0c", x"0c", x"0c", x"0c", x"3c", x"00", x"00", x"00", x"00", x"00", -- 93 ']'
    x"10", x"38", x"6c", x"c6", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 94 '^'
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"ff", x"00", x"00", x"00", -- 95 '_'
    x"30", x"30", x"18", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 96 '`'
    x"00", x"00", x"00", x"00", x"00", x"78", x"0c", x"7c", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 97 'a'
    x"00", x"00", x"e0", x"60", x"60", x"78", x"6c", x"66", x"66", x"66", x"7c", x"00", x"00", x"00", x"00", x"00", -- 98 'b'
    x"00", x"00", x"00", x"00", x"00", x"7c", x"c6", x"c0", x"c0", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 99 'c'
    x"00", x"00", x"1c", x"0c", x"0c", x"3c", x"6c", x"cc", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 100 'd'
    x"00", x"00", x"00", x"00", x"00", x"7c", x"c6", x"fe", x"c0", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 101 'e'
    x"00", x"00", x"38", x"6c", x"64", x"60", x"f0", x"60", x"60", x"60", x"f0", x"00", x"00", x"00", x"00", x"00", -- 102 'f'
    x"00", x"00", x"00", x"00", x"00", x"76", x"cc", x"cc", x"cc", x"7c", x"0c", x"cc", x"78", x"00", x"00", x"00", -- 103 'g'
    x"00", x"00", x"e0", x"60", x"60", x"6c", x"76", x"66", x"66", x"66", x"e6", x"00", x"00", x"00", x"00", x"00", -- 104 'h'
    x"00", x"00", x"18", x"18", x"00", x"38", x"18", x"18", x"18", x"18", x"3c", x"00", x"00", x"00", x"00", x"00", -- 105 'i'
    x"00", x"00", x"06", x"06", x"00", x"0e", x"06", x"06", x"06", x"06", x"66", x"66", x"3c", x"00", x"00", x"00", -- 106 'j'
    x"00", x"00", x"e0", x"60", x"60", x"66", x"6c", x"78", x"6c", x"66", x"e6", x"00", x"00", x"00", x"00", x"00", -- 107 'k'
    x"00", x"00", x"38", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"3c", x"00", x"00", x"00", x"00", x"00", -- 108 'l'
    x"00", x"00", x"00", x"00", x"00", x"ec", x"fe", x"d6", x"d6", x"d6", x"c6", x"00", x"00", x"00", x"00", x"00", -- 109 'm'
    x"00", x"00", x"00", x"00", x"00", x"dc", x"66", x"66", x"66", x"66", x"66", x"00", x"00", x"00", x"00", x"00", -- 110 'n'
    x"00", x"00", x"00", x"00", x"00", x"7c", x"c6", x"c6", x"c6", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 111 'o'
    x"00", x"00", x"00", x"00", x"00", x"dc", x"66", x"66", x"66", x"7c", x"60", x"60", x"f0", x"00", x"00", x"00", -- 112 'p'
    x"00", x"00", x"00", x"00", x"00", x"76", x"cc", x"cc", x"cc", x"7c", x"0c", x"0c", x"1e", x"00", x"00", x"00", -- 113 'q'
    x"00", x"00", x"00", x"00", x"00", x"dc", x"76", x"66", x"60", x"60", x"f0", x"00", x"00", x"00", x"00", x"00", -- 114 'r'
    x"00", x"00", x"00", x"00", x"00", x"7c", x"c6", x"70", x"1c", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 115 's'
    x"00", x"00", x"10", x"30", x"30", x"fc", x"30", x"30", x"30", x"36", x"1c", x"00", x"00", x"00", x"00", x"00", -- 116 't'
    x"00", x"00", x"00", x"00", x"00", x"cc", x"cc", x"cc", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 117 'u'
    x"00", x"00", x"00", x"00", x"00", x"66", x"66", x"66", x"66", x"3c", x"18", x"00", x"00", x"00", x"00", x"00", -- 118 'v'
    x"00", x"00", x"00", x"00", x"00", x"c6", x"c6", x"d6", x"d6", x"fe", x"6c", x"00", x"00", x"00", x"00", x"00", -- 119 'w'
    x"00", x"00", x"00", x"00", x"00", x"c6", x"6c", x"38", x"38", x"6c", x"c6", x"00", x"00", x"00", x"00", x"00", -- 120 'x'
    x"00", x"00", x"00", x"00", x"00", x"c6", x"c6", x"c6", x"c6", x"7e", x"06", x"0c", x"f8", x"00", x"00", x"00", -- 121 'y'
    x"00", x"00", x"00", x"00", x"00", x"fe", x"cc", x"18", x"30", x"66", x"fe", x"00", x"00", x"00", x"00", x"00", -- 122 'z'
    x"00", x"00", x"0e", x"18", x"18", x"18", x"70", x"18", x"18", x"18", x"0e", x"00", x"00", x"00", x"00", x"00", -- 123 '{'
    x"00", x"00", x"18", x"18", x"18", x"18", x"00", x"18", x"18", x"18", x"18", x"00", x"00", x"00", x"00", x"00", -- 124 '|'
    x"00", x"00", x"70", x"18", x"18", x"18", x"0e", x"18", x"18", x"18", x"70", x"00", x"00", x"00", x"00", x"00", -- 125 '}'
    x"00", x"00", x"76", x"dc", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 126 '~'
    x"00", x"00", x"00", x"00", x"10", x"38", x"6c", x"c6", x"c6", x"fe", x"00", x"00", x"00", x"00", x"00", x"00", -- 127
    x"00", x"00", x"3c", x"66", x"c2", x"c0", x"c0", x"c2", x"66", x"3c", x"0c", x"06", x"7c", x"00", x"00", x"00", -- 128
    x"00", x"00", x"cc", x"cc", x"00", x"cc", x"cc", x"cc", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 129
    x"00", x"0c", x"18", x"30", x"00", x"7c", x"c6", x"fe", x"c0", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 130
    x"00", x"10", x"38", x"6c", x"00", x"78", x"0c", x"7c", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 131
    x"00", x"00", x"cc", x"cc", x"00", x"78", x"0c", x"7c", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 132
    x"00", x"60", x"30", x"18", x"00", x"78", x"0c", x"7c", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 133
    x"00", x"38", x"6c", x"38", x"00", x"78", x"0c", x"7c", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 134
    x"00", x"00", x"00", x"00", x"3c", x"66", x"60", x"66", x"3c", x"0c", x"06", x"3c", x"00", x"00", x"00", x"00", -- 135
    x"00", x"10", x"38", x"6c", x"00", x"7c", x"c6", x"fe", x"c0", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 136
    x"00", x"00", x"cc", x"cc", x"00", x"7c", x"c6", x"fe", x"c0", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 137
    x"00", x"60", x"30", x"18", x"00", x"7c", x"c6", x"fe", x"c0", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 138
    x"00", x"00", x"66", x"66", x"00", x"38", x"18", x"18", x"18", x"18", x"3c", x"00", x"00", x"00", x"00", x"00", -- 139
    x"00", x"18", x"3c", x"66", x"00", x"38", x"18", x"18", x"18", x"18", x"3c", x"00", x"00", x"00", x"00", x"00", -- 140
    x"00", x"60", x"30", x"18", x"00", x"38", x"18", x"18", x"18", x"18", x"3c", x"00", x"00", x"00", x"00", x"00", -- 141
    x"00", x"c6", x"c6", x"10", x"38", x"6c", x"c6", x"c6", x"fe", x"c6", x"c6", x"00", x"00", x"00", x"00", x"00", -- 142
    x"38", x"6c", x"38", x"00", x"38", x"6c", x"c6", x"c6", x"fe", x"c6", x"c6", x"00", x"00", x"00", x"00", x"00", -- 143
    x"18", x"30", x"60", x"00", x"fe", x"66", x"60", x"7c", x"60", x"66", x"fe", x"00", x"00", x"00", x"00", x"00", -- 144
    x"00", x"00", x"00", x"00", x"cc", x"76", x"36", x"7e", x"d8", x"d8", x"6e", x"00", x"00", x"00", x"00", x"00", -- 145
    x"00", x"00", x"3e", x"6c", x"cc", x"cc", x"fe", x"cc", x"cc", x"cc", x"ce", x"00", x"00", x"00", x"00", x"00", -- 146
    x"00", x"10", x"38", x"6c", x"00", x"7c", x"c6", x"c6", x"c6", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 147
    x"00", x"00", x"c6", x"c6", x"00", x"7c", x"c6", x"c6", x"c6", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 148
    x"00", x"60", x"30", x"18", x"00", x"7c", x"c6", x"c6", x"c6", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 149
    x"00", x"30", x"78", x"cc", x"00", x"cc", x"cc", x"cc", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 150
    x"00", x"60", x"30", x"18", x"00", x"cc", x"cc", x"cc", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 151
    x"00", x"00", x"c6", x"c6", x"00", x"c6", x"c6", x"c6", x"c6", x"7e", x"06", x"0c", x"78", x"00", x"00", x"00", -- 152
    x"00", x"c6", x"c6", x"38", x"6c", x"c6", x"c6", x"c6", x"c6", x"6c", x"38", x"00", x"00", x"00", x"00", x"00", -- 153
    x"00", x"c6", x"c6", x"00", x"c6", x"c6", x"c6", x"c6", x"c6", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 154
    x"00", x"18", x"18", x"3c", x"66", x"60", x"60", x"66", x"3c", x"18", x"18", x"00", x"00", x"00", x"00", x"00", -- 155
    x"00", x"38", x"6c", x"64", x"60", x"f0", x"60", x"60", x"60", x"e6", x"fc", x"00", x"00", x"00", x"00", x"00", -- 156
    x"00", x"00", x"66", x"66", x"3c", x"18", x"7e", x"18", x"7e", x"18", x"18", x"00", x"00", x"00", x"00", x"00", -- 157
    x"00", x"f8", x"cc", x"cc", x"f8", x"c4", x"cc", x"de", x"cc", x"cc", x"c6", x"00", x"00", x"00", x"00", x"00", -- 158
    x"00", x"0e", x"1b", x"18", x"18", x"18", x"7e", x"18", x"18", x"18", x"18", x"d8", x"70", x"00", x"00", x"00", -- 159
    x"00", x"18", x"30", x"60", x"00", x"78", x"0c", x"7c", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 160
    x"00", x"0c", x"18", x"30", x"00", x"38", x"18", x"18", x"18", x"18", x"3c", x"00", x"00", x"00", x"00", x"00", -- 161
    x"00", x"18", x"30", x"60", x"00", x"7c", x"c6", x"c6", x"c6", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 162
    x"00", x"18", x"30", x"60", x"00", x"cc", x"cc", x"cc", x"cc", x"cc", x"76", x"00", x"00", x"00", x"00", x"00", -- 163
    x"00", x"00", x"76", x"dc", x"00", x"dc", x"66", x"66", x"66", x"66", x"66", x"00", x"00", x"00", x"00", x"00", -- 164
    x"76", x"dc", x"00", x"c6", x"e6", x"f6", x"fe", x"de", x"ce", x"c6", x"c6", x"00", x"00", x"00", x"00", x"00", -- 165
    x"00", x"3c", x"6c", x"6c", x"3e", x"00", x"7e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 166
    x"00", x"38", x"6c", x"6c", x"38", x"00", x"7c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 167
    x"00", x"00", x"30", x"30", x"00", x"30", x"30", x"60", x"c6", x"c6", x"7c", x"00", x"00", x"00", x"00", x"00", -- 168
    x"00", x"00", x"00", x"00", x"00", x"00", x"fe", x"c0", x"c0", x"c0", x"00", x"00", x"00", x"00", x"00", x"00", -- 169
    x"00", x"00", x"00", x"00", x"00", x"00", x"fe", x"06", x"06", x"06", x"00", x"00", x"00", x"00", x"00", x"00", -- 170
    x"00", x"c0", x"c0", x"c6", x"cc", x"d8", x"30", x"60", x"dc", x"86", x"0c", x"18", x"3e", x"00", x"00", x"00", -- 171
    x"00", x"c0", x"c0", x"c6", x"cc", x"d8", x"30", x"66", x"ce", x"9e", x"3e", x"06", x"06", x"00", x"00", x"00", -- 172
    x"00", x"00", x"18", x"18", x"00", x"18", x"18", x"3c", x"3c", x"3c", x"18", x"00", x"00", x"00", x"00", x"00", -- 173
    x"00", x"00", x"00", x"00", x"36", x"6c", x"d8", x"6c", x"36", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 174
    x"00", x"00", x"00", x"00", x"d8", x"6c", x"36", x"6c", x"d8", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 175
    x"11", x"44", x"11", x"44", x"11", x"44", x"11", x"44", x"11", x"44", x"11", x"44", x"11", x"44", x"00", x"00", -- 176
    x"55", x"aa", x"55", x"aa", x"55", x"aa", x"55", x"aa", x"55", x"aa", x"55", x"aa", x"55", x"aa", x"00", x"00", -- 177
    x"dd", x"77", x"dd", x"77", x"dd", x"77", x"dd", x"77", x"dd", x"77", x"dd", x"77", x"dd", x"77", x"00", x"00", -- 178
    x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 179
    x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"f8", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 180
    x"18", x"18", x"18", x"18", x"18", x"f8", x"18", x"f8", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 181
    x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"f6", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 182
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"fe", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 183
    x"00", x"00", x"00", x"00", x"00", x"f8", x"18", x"f8", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 184
    x"36", x"36", x"36", x"36", x"36", x"f6", x"06", x"f6", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 185
    x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 186
    x"00", x"00", x"00", x"00", x"00", x"fe", x"06", x"f6", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 187
    x"36", x"36", x"36", x"36", x"36", x"f6", x"06", x"fe", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 188
    x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"fe", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 189
    x"18", x"18", x"18", x"18", x"18", x"f8", x"18", x"f8", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 190
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"f8", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 191
    x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"1f", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 192
    x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 193
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"ff", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 194
    x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"1f", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 195
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 196
    x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"ff", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 197
    x"18", x"18", x"18", x"18", x"18", x"1f", x"18", x"1f", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 198
    x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"37", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 199
    x"36", x"36", x"36", x"36", x"36", x"37", x"30", x"3f", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 200
    x"00", x"00", x"00", x"00", x"00", x"3f", x"30", x"37", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 201
    x"36", x"36", x"36", x"36", x"36", x"f7", x"00", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 202
    x"00", x"00", x"00", x"00", x"00", x"ff", x"00", x"f7", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 203
    x"36", x"36", x"36", x"36", x"36", x"37", x"30", x"37", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 204
    x"00", x"00", x"00", x"00", x"00", x"ff", x"00", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 205
    x"36", x"36", x"36", x"36", x"36", x"f7", x"00", x"f7", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 206
    x"18", x"18", x"18", x"18", x"18", x"ff", x"00", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 207
    x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 208
    x"00", x"00", x"00", x"00", x"00", x"ff", x"00", x"ff", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 209
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"ff", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 210
    x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"3f", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 211
    x"18", x"18", x"18", x"18", x"18", x"1f", x"18", x"1f", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 212
    x"00", x"00", x"00", x"00", x"00", x"1f", x"18", x"1f", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 213
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"3f", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 214
    x"36", x"36", x"36", x"36", x"36", x"36", x"36", x"ff", x"36", x"36", x"36", x"36", x"36", x"36", x"00", x"00", -- 215
    x"18", x"18", x"18", x"18", x"18", x"ff", x"18", x"ff", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 216
    x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"f8", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 217
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"1f", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 218
    x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"00", -- 219
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"00", -- 220
    x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"f0", x"00", x"00", -- 221
    x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"0f", x"00", x"00", -- 222
    x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"ff", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 223
    x"00", x"00", x"00", x"00", x"00", x"76", x"dc", x"d8", x"d8", x"dc", x"76", x"00", x"00", x"00", x"00", x"00", -- 224
    x"00", x"00", x"00", x"00", x"7c", x"c6", x"fc", x"c6", x"c6", x"fc", x"c0", x"c0", x"40", x"00", x"00", x"00", -- 225
    x"00", x"00", x"fe", x"c6", x"c6", x"c0", x"c0", x"c0", x"c0", x"c0", x"c0", x"00", x"00", x"00", x"00", x"00", -- 226
    x"00", x"00", x"00", x"00", x"fe", x"6c", x"6c", x"6c", x"6c", x"6c", x"6c", x"00", x"00", x"00", x"00", x"00", -- 227
    x"00", x"00", x"fe", x"c6", x"60", x"30", x"18", x"30", x"60", x"c6", x"fe", x"00", x"00", x"00", x"00", x"00", -- 228
    x"00", x"00", x"00", x"00", x"00", x"7e", x"d8", x"d8", x"d8", x"d8", x"70", x"00", x"00", x"00", x"00", x"00", -- 229
    x"00", x"00", x"00", x"00", x"66", x"66", x"66", x"66", x"7c", x"60", x"60", x"c0", x"00", x"00", x"00", x"00", -- 230
    x"00", x"00", x"00", x"00", x"76", x"dc", x"18", x"18", x"18", x"18", x"18", x"00", x"00", x"00", x"00", x"00", -- 231
    x"00", x"00", x"7e", x"18", x"3c", x"66", x"66", x"66", x"3c", x"18", x"7e", x"00", x"00", x"00", x"00", x"00", -- 232
    x"00", x"00", x"38", x"6c", x"c6", x"c6", x"fe", x"c6", x"c6", x"6c", x"38", x"00", x"00", x"00", x"00", x"00", -- 233
    x"00", x"00", x"38", x"6c", x"c6", x"c6", x"c6", x"6c", x"6c", x"6c", x"ee", x"00", x"00", x"00", x"00", x"00", -- 234
    x"00", x"00", x"1e", x"30", x"18", x"0c", x"3e", x"66", x"66", x"66", x"3c", x"00", x"00", x"00", x"00", x"00", -- 235
    x"00", x"00", x"00", x"00", x"00", x"7e", x"db", x"db", x"7e", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 236
    x"00", x"00", x"03", x"06", x"7e", x"db", x"db", x"f3", x"7e", x"60", x"c0", x"00", x"00", x"00", x"00", x"00", -- 237
    x"00", x"00", x"1c", x"30", x"60", x"60", x"7c", x"60", x"60", x"30", x"1c", x"00", x"00", x"00", x"00", x"00", -- 238
    x"00", x"00", x"00", x"7c", x"c6", x"c6", x"c6", x"c6", x"c6", x"c6", x"c6", x"00", x"00", x"00", x"00", x"00", -- 239
    x"00", x"00", x"00", x"fe", x"00", x"00", x"fe", x"00", x"00", x"fe", x"00", x"00", x"00", x"00", x"00", x"00", -- 240
    x"00", x"00", x"00", x"18", x"18", x"7e", x"18", x"18", x"00", x"00", x"ff", x"00", x"00", x"00", x"00", x"00", -- 241
    x"00", x"00", x"30", x"18", x"0c", x"06", x"0c", x"18", x"30", x"00", x"7e", x"00", x"00", x"00", x"00", x"00", -- 242
    x"00", x"00", x"0c", x"18", x"30", x"60", x"30", x"18", x"0c", x"00", x"7e", x"00", x"00", x"00", x"00", x"00", -- 243
    x"00", x"00", x"0e", x"1b", x"1b", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"00", x"00", -- 244
    x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"18", x"d8", x"d8", x"70", x"00", x"00", x"00", x"00", x"00", -- 245
    x"00", x"00", x"00", x"18", x"18", x"00", x"7e", x"00", x"18", x"18", x"00", x"00", x"00", x"00", x"00", x"00", -- 246
    x"00", x"00", x"00", x"00", x"76", x"dc", x"00", x"76", x"dc", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 247
    x"00", x"38", x"6c", x"6c", x"38", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 248
    x"00", x"00", x"00", x"00", x"00", x"00", x"18", x"18", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 249
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"18", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 250
    x"00", x"0f", x"0c", x"0c", x"0c", x"0c", x"0c", x"ec", x"6c", x"3c", x"1c", x"00", x"00", x"00", x"00", x"00", -- 251
    x"00", x"d8", x"6c", x"6c", x"6c", x"6c", x"6c", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 252
    x"00", x"70", x"d8", x"30", x"60", x"c8", x"f8", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", -- 253
    x"00", x"00", x"00", x"00", x"7c", x"7c", x"7c", x"7c", x"7c", x"7c", x"00", x"00", x"00", x"00", x"00", x"00", -- 254
    x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00", x"00"  -- 255
  );
begin
  lookup_proc: process is
    variable addr_concat : std_ulogic_vector(11 downto 0);
    variable addr_i      : integer range 0 to 4095;
  begin
    wait until rising_edge(clk);
    addr_concat := char_code & char_line;
    addr_i      := to_integer(unsigned(addr_concat));
    data        <= memory(addr_i);
  end process;
end architecture;