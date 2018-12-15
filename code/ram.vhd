LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
library processor;
ENTITY ram IS
GENERIC ( n : integer := 32);
	PORT(
		clk : IN std_logic;
		we  : IN std_logic;
		address : IN  std_logic_vector(n-1 DOWNTO 0);
		datain  : IN  std_logic_vector(n-1 DOWNTO 0);
		dataout : OUT std_logic_vector(n-1 DOWNTO 0));
END ENTITY ram;

ARCHITECTURE mixed_ram OF ram IS

	TYPE ram_type IS ARRAY(0 TO 511) OF std_logic_vector(n-1 DOWNTO 0);
	SIGNAL ram : ram_type ;
	
	BEGIN
		PROCESS(clk) IS
			BEGIN
				IF rising_edge(clk) THEN  
					IF we = '1' THEN
						ram(to_integer(unsigned(address))) <= datain;
					END IF;
				END IF;
		END PROCESS;
		dataout <= ram(to_integer(unsigned(address)));
END mixed_ram;

