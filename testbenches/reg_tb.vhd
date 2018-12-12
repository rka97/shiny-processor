library ieee;
use ieee.std_logic_1164.all;
library processor;

entity reg_tb is
end reg_tb;

architecture tb of reg_tb is
    signal clk, enable, load : std_logic := 'Z';
    signal data_in, data_out : std_logic_vector(7 downto 0) := (others => 'Z');
    constant period : time := 1 ns;
    constant act_size : integer := 8;

    begin
        reg_inst : entity processor.reg
            generic map ( N => act_size )
            port map (
                clk => clk,
                enable => enable,
                load => load,
                data_in => data_in,
                data_out => data_out
            );

        process is
        begin
            -- run for 4*period
            wait for period;
            enable <= '0';
            assert data_out = (7 downto 0 => 'Z') report "Data is not all Z's";
            wait for period;
            enable <= '1';
            assert data_out = (7 downto 0 => 'Z') report "Data is not all Z's";
            wait for period;
            data_in <= (others => '1');
            load <= '1';
            wait for period;
            load <= '0';
            assert data_out = (7 downto 0 => '1') report "Data is not all 1's";
            wait for period;
            enable <= '0';
            wait for period / 4;
            assert data_out = (7 downto 0 => 'Z') report "Data is not all Z's";
        end process;

        process is
        begin
            clk <= '0';
            wait for period / 2;
            clk <= '1';
            wait for period / 2;
        end process;
end tb;