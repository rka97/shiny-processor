library ieee;
use ieee.std_logic_1164.all;
library processor;

entity decoder_tb is
end decoder_tb;

architecture behave of decoder_tb is
    signal enable : std_logic;
    signal A : std_logic_vector(1 downto 0);
    signal F : std_logic_vector(3 downto 0);

begin
    decoder_inst_tb : entity processor.decoder
        generic map (
            Nsel => 2,
            Nout => 4
        )
        port map (
            enable => enable,
            A => A,
            F => F
        );
    
    process is
    begin
        A <= "00";
        enable <= '0';
        wait for 1 ns;
        A <= "00";
        enable <= '1';
        wait for 1 ns;
        assert (F = "0001") report "Selection 00 does not work.";
        A <= "01";
        wait for 1 ns;
        assert (F = "0010") report "Selection 01 does not work.";
        A <= "10";
        wait for 1 ns;
        assert (F = "0100") report "Selection 10 does not work.";
        A <= "11";
        wait for 1 ns;
        assert (F = "1000") report "Selection 11 does not work.";
    end process;
end behave;