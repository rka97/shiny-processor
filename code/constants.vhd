library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
package p_constants is
constant N : integer := 32;

constant R0out : std_logic_vector(31 downto 0) := "0000" & (27 downto 0 => '0');
constant R1out : std_logic_vector(31 downto 0) := "0001" & (27 downto 0 => '0');
constant R2out : std_logic_vector(31 downto 0) := "0010" & (27 downto 0 => '0');
constant R3out : std_logic_vector(31 downto 0) := "0011" & (27 downto 0 => '0');
constant R4out : std_logic_vector(31 downto 0) := "0100" & (27 downto 0 => '0');
constant R5out : std_logic_vector(31 downto 0) := "0101" & (27 downto 0 => '0');
constant R6out : std_logic_vector(31 downto 0) := "0110" & (27 downto 0 => '0');
constant R7out : std_logic_vector(31 downto 0) := "0111" & (27 downto 0 => '0');
constant PCout : std_logic_vector(31 downto 0) := "0111" & (27 downto 0 => '0');
constant IRout : std_logic_vector(31 downto 0) := "1000" & (27 downto 0 => '0');
constant MDRout2 : std_logic_vector(31 downto 0) := "1001" & (27 downto 0 => '0');
constant FLAGout : std_logic_vector(31 downto 0) := "1010" & (27 downto 0 => '0');
constant TMP1out : std_logic_vector(31 downto 0) := "1011" & (27 downto 0 => '0');
constant TMP2out : std_logic_vector(31 downto 0) := "1100" & (27 downto 0 => '0');

constant R0in : std_logic_vector(N-1 downto 0) := (12 => '1' ,others =>'0');
constant R1in : std_logic_vector(N-1 downto 0) := (13 => '1' ,others =>'0');
constant R2in : std_logic_vector(N-1 downto 0) := (14 => '1' ,others =>'0');
constant R3in : std_logic_vector(N-1 downto 0) := (15 => '1' ,others =>'0');
constant R4in : std_logic_vector(N-1 downto 0) := (16 => '1' ,others =>'0');
constant R5in : std_logic_vector(N-1 downto 0) := (17 => '1' ,others =>'0');
constant R6in : std_logic_vector(N-1 downto 0) := (18 => '1' ,others =>'0');
constant R7in : std_logic_vector(N-1 downto 0) := (19 => '1' ,others =>'0');
constant PCin : std_logic_vector(N-1 downto 0) := (19 => '1' ,others =>'0');
constant IRin : std_logic_vector(N-1 downto 0) := (20 => '1' ,others =>'0');
constant MARin2 : std_logic_vector(N-1 downto 0) := (21 => '1' ,others =>'0');
constant MDRin1 : std_logic_vector(N-1 downto 0) := (22 => '1' ,others =>'0');
constant MDRin2 : std_logic_vector(N-1 downto 0) := (23 => '1' ,others =>'0');
constant FLAGin : std_logic_vector(N-1 downto 0) := (24 => '1' ,others =>'0');
constant TMP1in : std_logic_vector(N-1 downto 0) := (25 => '1' ,others =>'0');
constant TMP2in : std_logic_vector(N-1 downto 0) := (26 => '1' ,others =>'0');
constant MARin1 : std_logic_vector(N-1 downto 0) := (27 => '1' ,others =>'0');

constant F_A : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "0000" & (9 downto 0 => '0');
constant F_ApB : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "0001" & (9 downto 0 => '0');
constant F_AmBm1 : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "0010" & (9 downto 0 => '0');
constant F_Am1 : std_logic_vector(31 downto 0) :=  (31 downto 12 => '0') & "0011" & (9 downto 0 => '0');

constant F_Ap1 : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "00001" & (6 downto 0 => '0');
constant F_ApBp1 : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "00011" & (6 downto 0 => '0');
constant F_AmB : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "00101" & (6 downto 0 => '0');
--constant F_0 : std_logic_vector(31 downto 0) :=  (31 downto 12 => '0') & "00111" & (6 downto 0 => '0');

constant F_AandB : std_logic_vector(31 downto 0) :=  (31 downto 12 => '0') & "0100" & (7 downto 0 => '0');
constant F_AorB : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "0101" & (7 downto 0 => '0');
constant F_AxorB : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "0110" & (7 downto 0 => '0');
constant F_AnotB : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "0111" & (7 downto 0 => '0');

constant F_LSR : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "1000" & (7 downto 0 => '0');
constant F_ROR : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "1001" & (7 downto 0 => '0');
constant F_RRC : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "1010" & (7 downto 0 => '0');
constant F_ASR : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "1011" & (7 downto 0 => '0');
constant F_LSL : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "1100" & (7 downto 0 => '0');
constant F_ROL : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "1101" & (7 downto 0 => '0');
constant F_RLC : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "1110" & (7 downto 0 => '0');
constant F_0 : std_logic_vector(31 downto 0) := (31 downto 12 => '0') & "1111" & (7 downto 0 => '0');

constant RD : std_logic_vector(N-1 downto 0) := (6 => '1' ,others =>'0');
constant WT : std_logic_vector(N-1 downto 0) := (5 => '1' ,others =>'0');
constant HLT : std_logic_vector(N-1 downto 0) := (4 => '1' ,others =>'0');
constant NOP : std_logic_vector(N-1 downto 0) := (3 => '1' ,others =>'0');

end package;