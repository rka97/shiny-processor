LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity counter is
generic(n:integer:=4);--max count 6, need 3 bits
port (
	clk   : in std_logic;
	rst : in std_logic;
	count : out std_logic_vector(n-1 downto 0));
end counter;

architecture behavioral of counter is
signal temp : std_logic_vector(n-1 downto 0);
begin

	process(clk, rst)
	begin
		if (rst = '1') then
			--if reset'event then
				temp <= (others => '0');
			--end if;
		elsif (rising_edge(clk)) then
			temp <= temp + 1;
		end if;
	end process;
	count <= temp;
end architecture;