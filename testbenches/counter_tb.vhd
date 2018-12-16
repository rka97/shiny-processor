library ieee;
use ieee.std_logic_1164.all;
library processor;

entity counter_tb is
end counter_tb;

architecture behave of counter_tb is
    signal clk, rst, enable : std_logic := 'Z';
    signal data : std_logic_vector(3 downto 0) := (others => 'Z');
    constant period : time := 1 ns;

begin
    counter_inst : entity processor.counter
        generic map (
            n => 4
        )
        port map (
            clk => clk,
            rst => rst,
            enable => enable,
            count => data
        );
    process is
    begin
        rst <= '1';
        wait for period;
        rst <= '0';
        enable <= '1';
        assert (data = "0000") report "t=0 does not work.";
        wait for period;
        assert (data = "0001") report "t=1 does not work.";
        wait for period;
        assert (data = "0010") report "t=2 does not work.";
        wait for period;
        assert (data = "0011") report "t=3 does not work.";
        wait for period;
        rst <= '1';
        wait for period;
        assert (data = "0000") report "reset does not work.";
    end process;

    process is
    begin
        clk <= '0';
        wait for period / 2;
        clk <= '1';
        wait for period / 2;
    end process;
end behave;