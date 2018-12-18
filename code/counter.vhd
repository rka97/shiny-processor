library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity counter is
generic( max_nbits : integer := 4); -- max count 6, need 3 bits
port (
	clk, rst, enable : in std_logic;
	count	: out std_logic_vector(max_nbits-1 downto 0));
end counter;

architecture behavioral of counter is
begin
	process(clk, rst, enable)
	variable temp : std_logic_vector(max_nbits-1 downto 0) := (others => '0');
	begin
		if (enable = '1') then
			if falling_edge(clk) then
				if (rst = '1') then
					temp := (others => '0');
				else
					temp := temp + 1;
				end if;
			end if;
		end if;	
		count <= temp;
	end process;
end architecture;