library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package p_constants is

constant N : integer := 32;

constant R0out        : std_logic_vector(31 downto 0) := "0000" & (27 downto 0 => '0');
constant R1out        : std_logic_vector(31 downto 0) := "0001" & (27 downto 0 => '0');
constant R2out        : std_logic_vector(31 downto 0) := "0010" & (27 downto 0 => '0');
constant R3out        : std_logic_vector(31 downto 0) := "0011" & (27 downto 0 => '0');
constant R4out        : std_logic_vector(31 downto 0) := "0100" & (27 downto 0 => '0');
constant R5out        : std_logic_vector(31 downto 0) := "0101" & (27 downto 0 => '0');
constant R6out        : std_logic_vector(31 downto 0) := "0110" & (27 downto 0 => '0');
constant SPout        : std_logic_vector(31 downto 0) := "0110" & (27 downto 0 => '0');
constant R7out        : std_logic_vector(31 downto 0) := "0111" & (27 downto 0 => '0');
constant PCout        : std_logic_vector(31 downto 0) := "0111" & (27 downto 0 => '0');
constant IRout        : std_logic_vector(31 downto 0) := "1000" & (27 downto 0 => '0');
constant MARout       : std_logic_vector(31 downto 0) := "1001" & (27 downto 0 => '0');
constant MDRout       : std_logic_vector(31 downto 0) := "1010" & (27 downto 0 => '0');
constant FLAGout      : std_logic_vector(31 downto 0) := "1011" & (27 downto 0 => '0');
constant TMP1out      : std_logic_vector(31 downto 0) := "1100" & (27 downto 0 => '0');
constant TMP2out      : std_logic_vector(31 downto 0) := "1101" & (27 downto 0 => '0');
constant BrIRout      : std_logic_vector(31 downto 0) := "1110" & (27 downto 0 => '0');
constant NoSrc        : std_logic_vector(31 downto 0) := "1111" & (27 downto 0 => '0');

constant R0in         : std_logic_vector(N-1 downto 0) := (13 => '1', others =>'0'); -- 0
constant R1in         : std_logic_vector(N-1 downto 0) := (14 => '1', others =>'0'); -- 1
constant R2in         : std_logic_vector(N-1 downto 0) := (15 => '1', others =>'0'); -- 2
constant R3in         : std_logic_vector(N-1 downto 0) := (16 => '1', others =>'0'); -- 3
constant R4in         : std_logic_vector(N-1 downto 0) := (17 => '1', others =>'0'); -- 4
constant R5in         : std_logic_vector(N-1 downto 0) := (18 => '1', others =>'0'); -- 5
constant R6in         : std_logic_vector(N-1 downto 0) := (19 => '1', others =>'0'); -- 6
constant SPin         : std_logic_vector(N-1 downto 0) := (19 => '1', others =>'0'); -- 6
constant R7in         : std_logic_vector(N-1 downto 0) := (20 => '1', others =>'0'); -- 7
constant PCin         : std_logic_vector(N-1 downto 0) := (20 => '1', others =>'0'); -- 7
constant IRin         : std_logic_vector(N-1 downto 0) := (21 => '1', others =>'0'); -- 8
constant MARin2       : std_logic_vector(N-1 downto 0) := (22 => '1', others =>'0'); -- 9
constant MDRin        : std_logic_vector(N-1 downto 0) := (23 => '1', others =>'0'); -- 10
constant FLAGin       : std_logic_vector(N-1 downto 0) := (24 => '1', others =>'0'); -- 11
constant TMP1in       : std_logic_vector(N-1 downto 0) := (25 => '1', others =>'0'); -- 12
constant TMP2in       : std_logic_vector(N-1 downto 0) := (26 => '1', others =>'0'); -- 13
constant MARin1       : std_logic_vector(N-1 downto 0) := (27 => '1', others =>'0'); -- 14

constant F_A          : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "0000" & (8 downto 0 => '0');
constant F_ApB        : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "0001" & (8 downto 0 => '0');
constant F_AmBm1      : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "0010" & (8 downto 0 => '0');
constant F_Am1        : std_logic_vector(31 downto 0) :=  (31 downto 13 => '0') & "0011" & (8 downto 0 => '0');

constant F_Ap1        : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "00001" & (7 downto 0 => '0');
constant F_ApBp1      : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "00011" & (7 downto 0 => '0');
constant F_AmB        : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "00101" & (7 downto 0 => '0');
constant F_Zero       : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "00110" & (7 downto 0 => '0');

constant F_AandB      : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "0100" & (8 downto 0 => '0');
constant F_AorB       : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "0101" & (8 downto 0 => '0');
constant F_AxorB      : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "0110" & (8 downto 0 => '0');
constant F_AnotB      : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "0111" & (8 downto 0 => '0');

constant F_LSR        : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "1000" & (8 downto 0 => '0');
constant F_ROR        : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "1001" & (8 downto 0 => '0');
constant F_RRC        : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "1010" & (8 downto 0 => '0');
constant F_ASR        : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "1011" & (8 downto 0 => '0');
constant F_LSL        : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "1100" & (8 downto 0 => '0');
constant F_ROL        : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "1101" & (8 downto 0 => '0');
constant F_RLC        : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "1110" & (8 downto 0 => '0');
constant F_HI         : std_logic_vector(31 downto 0) := (31 downto 13 => '0') & "1111" & (8 downto 0 => '0');

constant RD           : std_logic_vector(N-1 downto 0) := (6 => '1', others =>'0');
constant WT           : std_logic_vector(N-1 downto 0) := (5 => '1', others =>'0');
constant HLT          : std_logic_vector(N-1 downto 0) := (4 => '1', others =>'0');
constant NOP          : std_logic_vector(N-1 downto 0) := (3 => '1', others =>'0');
constant ForceFlag    : std_logic_vector(N-1 downto 0) := (2 => '1', others =>'0');

end package;