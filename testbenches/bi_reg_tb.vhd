library ieee;
use ieee.std_logic_1164.all;
library processor;

entity bi_reg_tb is
end bi_reg_tb;

architecture tb of bi_reg_tb is
    signal clk, enable, load_in, write_out, force_in : std_logic := 'Z';
    signal data, data_in, data_out : std_logic_vector(7 downto 0) := (others => 'Z');
    constant period : time := 1 ns;
    constant act_size : integer := 8;

    begin
        bi_reg_inst : entity processor.bi_reg
            generic map ( N => act_size )
            port map (
                clk => clk,
                enable => enable,
                load_in => load_in,
                write_out => write_out,
                force_in => force_in,
                data => data,
                data_in => data_in,
                data_out => data_out
            );

        process is
        begin
            -- run for 7*period
            enable <= '1';
            wait for period;
            data_in <= (others => '1');
            force_in <= '1';
            wait for period;
            force_in <= '0';
            assert data_out = (7 downto 0 => '1') report "Forcing in data doesn't work";
            write_out <= '1';
            wait for period;
            write_out <= '0';
            assert data = (7 downto 0 => '1') report "Writing to the shared line doesn't work";
            data <= (others => '0');
            load_in <= '1';
            wait for period;
            data <= (others => 'Z');
            load_in <= '0';
            assert data_out = (7 downto 0 => '0') report "Loading in the shared line doesn't work";
            wait for period;
            write_out <= '1';
            wait for period;
            write_out <= '0';
            assert data_out = (7 downto 0 => '0') report "Shared data outing doesn't work";
            assert data = (7 downto 0 => '0') report "Writing to the shared line doesn't work";
            wait for period;
            assert data = (7 downto 0 => 'Z') report "The data buffer is kept busy";
        end process;

        process is
        begin
            clk <= '0';
            wait for period / 2;
            clk <= '1';
            wait for period / 2;
        end process;
end tb;