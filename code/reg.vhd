library ieee;
use ieee.std_logic_1164.all;

entity reg is
    generic ( N : natural );
    port (
        clk, enable, load : in std_logic;
        data_in : in std_logic_vector(N-1 downto 0);
        data_out : out std_logic_vector(N-1 downto 0)
    );
end entity reg;


architecture behavorial of reg is
    begin
        process (clk, enable) is
        variable feedback : std_logic_vector(N-1 downto 0) := (others => '0');
        begin
            if (enable = '1') then
                if rising_edge(clk) then
                    if (load = '1') then
                        feedback := data_in;
                    end if;
                end if;
                data_out <= feedback;
            else
                data_out <= (others => 'Z');
            end if;
        end process;
end behavorial;
    
    