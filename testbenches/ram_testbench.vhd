LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
library processor;
--Use work.MyPackage.ALL;

ENTITY ram_testbench IS
END ram_testbench;

ARCHITECTURE mixed_testbench OF ram_testbench IS
	
	component ram IS
GENERIC ( n : integer := 32);
	PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		address : IN  std_logic_vector(9 DOWNTO 0);
		datain  : IN  std_logic_vector(n-1 DOWNTO 0);
		dataout : OUT std_logic_vector(n-1 DOWNTO 0));
END component ram;

	
	SIGNAL clk, we: std_logic;
	signal datain, dataout:  std_logic_vector (31 downto 0);
	signal address: std_logic_vector(9 downto 0);
	
	BEGIN
	process
	begin
	     clk <= '1';
	     wait for 50 ps;
	     clk <= '0';
	     wait for 50 ps;
	end process;

	PROCESS
	BEGIN
		-- Test Case 1
		address <= "0000000010";
		WAIT FOR 20 ps;
		ASSERT( dataout = x"00000002")
		REPORT  " error reading address 2 in memory without setting write enable"
		SEVERITY ERROR;
		WAIT FOR 40 ps;

		-- Test Case 2
		address <= "0000000011";
		datain <= x"11111111";
		we <= '0';
		WAIT FOR 20 ps;
		ASSERT( dataout = x"00000003")
		REPORT  " error reading address 3 in memory with we = 0"
		SEVERITY ERROR;
		WAIT FOR 50 ps;

		-- Test Case 3
		we <= '1';
		WAIT FOR 100 ps;
		ASSERT( dataout = x"11111111")
		REPORT  " error reading address 3 in memory with we = 0"
		SEVERITY ERROR;
		-- Stop Simulation
		WAIT;
		END PROCESS;

		uut: ram PORT MAP (clk =>clk, we => we, address=>address, datain=>datain, dataout=>dataout);
		
END mixed_testbench;
