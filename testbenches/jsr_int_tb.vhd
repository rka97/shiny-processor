library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library processor;
Use processor.p_constants.ALL;
entity jsr_int_tb is

end entity jsr_int_tb;

architecture tb of jsr_int_tb is
--signal irout :std_logic_vector (15 downto 0);
signal op : std_logic_vector (n-1 downto 0) := (others => 'Z');
signal clk,rst,enable : std_logic;
signal ir : std_logic_vector (15 downto 0);
signal count: std_logic_vector (3 downto 0);
	--count : in std_logic_vector (1 downto 0);
begin
fsm: entity processor.jsr_int generic map(n => 32)
port map (ir => ir, op => op,
	clk => clk,rst =>rst,enable =>enable, count => count );
 process is
            begin
                clk <= '0';
                wait for 100 ps;
                clk <= '1';
                wait for 100 ps;
            end process;
 process is
            begin
              -- case 1 jsr forcing counter values
		ir <= "0100000000000000";
		count <= "0000";
		enable<='1';
		wait for 100 ps;
		assert( op = (BrIRout or F_A or TMP2in))
		report  " error in jsr count 0"
		severity error;
		count <= "0001";
		wait for 100 ps;
		assert( op = (SPout or F_Am1 or TMP1in or SPin or MARin2))
		report  " error in jsr count 1"
		severity error;
		count <= "0010";
		wait for 100 ps;
		assert( op = (PCout or F_Ap1 or MDRin or WT))
		report  " error in jsr count 2"
		severity error;
		count <= "0011";
		wait for 100 ps;
		assert( op = (TMP2out or F_A or PCin))
		report  " error in jsr count 3"
		severity error;
		wait for 100 ps;

		--case 2 ret forcing counter values
		ir <= "0011000000000000";
		count <= "0000";
		enable<='1';
		wait for 100 ps;
		assert( op = (SPout or F_A or MARin2 or TMP1in or RD))
		report  " error in ret count 0"
		severity error;
		count <= "0001";
		wait for 100 ps;
		assert( op = ( F_Ap1 or SPin))
		report  " error in ret count 1"
		severity error;
		count <= "0010";
		wait for 100 ps;
		assert( op = (MDRout or F_A or PCin))
		report  " error in ret count 2"
		severity error;
		wait for 100 ps;
		
		--case 3 hitr forcing counter values
		ir <= "0011100000000000";
		count <= "0000";
		enable<='1';
		wait for 100 ps;
		assert( op = (SPout or F_Am1 or SPin or MARin2))
		report  " error in hitr count 0"
		severity error;
		count <= "0001";
		wait for 100 ps;
		assert( op = ( FLAGout or F_A or MDRin or WT))
		report  " error in hitr count 1"
		severity error;
		count <= "0010";
		wait for 100 ps;
		assert( op = (SPout or F_Am1 or SPin or MARin2))
		report  " error in hitr count 2"
		severity error;
		wait for 100 ps;
		count <= "0011";
		wait for 100 ps;
		assert( op = ( PCout or F_A or MDRin or WT))
		report  " error in hitr count 3"
		severity error;
		count <= "0100";
		wait for 100 ps;
		assert( op = ( BrIRout or F_A or PCin))
		report  " error in hitr count 5"
		severity error;
		wait for 100 ps;

		--case 4 iret forcing counter values
		ir <= "0010000000000000";
		count <= "0000";
		enable<='1';
		wait for 100 ps;
		assert( op = (SPout or MARin1 or RD))
		report  " error in iret count 0"
		severity error;
		count <= "0001";
		wait for 100 ps;
		assert( op = ( SPout or F_Ap1 or SPin))
		report  " error in iret count 1"
		severity error;
		count <= "0010";
		wait for 100 ps;
		assert( op = (MDRout or F_A or PCin))
		report  " error in iret count 2"
		severity error;
		wait for 100 ps;
		count <= "0011";
		wait for 100 ps;
		assert( op = ( SPout or MARin1 or RD))
		report  " error in iret count 3"
		severity error;
		count <= "0100";
		wait for 100 ps;
		assert( op = (SPout or F_Ap1 or SPin))
		report  " error in iret count 4"
		severity error;
		wait for 100 ps;
		count <= "0101";
		wait for 100 ps;
		assert( op = ( MDRout or F_A or FLAGin))
		report  " error in iret count 5"
		severity error;
		wait for 100 ps;

		--case 6 NOP forcing counter values
		ir <= "0000000000000000";
		count <= "0000";
		enable<='1';
		wait for 100 ps;
		assert( op = (NoOP))
		report  " error in NOP"
		severity error;
		wait for 100 ps;

		--case 5 HLT forcing counter values
		ir <= "0001000000000000";
		wait for 100 ps;
		assert( op = (HLT))
		report  " error in HLT"
		severity error;
		wait for 100 ps;

            end process;
end tb;