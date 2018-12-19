library ieee;
use ieee.std_logic_1164.all;
library processor;

entity branch_tb is
end branch_tb;

architecture tb of branch_tb is
    signal clk : std_logic := '1';
    signal rst, z, c : std_logic := '0';
    signal offset : std_logic_vector(8 downto 0) := (others => '0');
    signal instruction : std_logic_vector(2 downto 0) := "UUU";
    signal counter_rst : std_logic := '0';
    signal control_word : std_logic_vector(31 downto 0);
    signal state : std_logic_vector(1 downto 0);
    constant period : time := 100 ps;
    constant counter_bits : integer := 2;
    constant control_word_width : integer := 32;

    begin
        process is
        begin
            clk <= '0';
            wait for period / 2;
            clk <= '1';
            wait for period / 2;
        end process;

        process is
        begin
            rst <= '1';
            instruction <= "000";
            offset <= "011110000";
            wait for period;
            rst <= '0';
            wait for 2*period;
            assert control_word = x"82000000" report "wrong control word must be 16#82000000";
            wait for period;
            assert control_word = x"F0100200" report "wrong control word must be 16#F0100200";
            -- ============================================================================ --
            rst <= '1';
            instruction <= "001";
            offset <= "011110000";
            z <= '1';
            wait for period;
            rst <= '0';
            wait for 2*period;
            assert control_word = x"82000000" report "wrong control word must be 16#82000000";
            wait for period;
            assert control_word = x"F0100200" report "wrong control word must be 16#F0100200";
            -- ============================================================================ --
            rst <= '1';
            instruction <= "010";
            offset <= "011110000";
            z <= '0';
            wait for period;
            rst <= '0';
            wait for 2*period;
            assert control_word = x"82000000" report "wrong control word must be 16#82000000";
            wait for period;
            assert control_word = x"F0100200" report "wrong control word must be 16#F0100200";
            -- ============================================================================ --
            rst <= '1';
            instruction <= "011";
            offset <= "011110000";
            c <= '0';
            wait for period;
            rst <= '0';
            wait for 2*period;
            assert control_word = x"82000000" report "wrong control word must be 16#82000000";
            wait for period;
            assert control_word = x"F0100200" report "wrong control word must be 16#F0100200";
            -- ============================================================================ --
            rst <= '1';
            instruction <= "100";
            offset <= "011110000";
            z <= '1';
            c <= 'Z';
            wait for period;
            rst <= '0';
            wait for 2*period;
            assert control_word = x"82000000" report "wrong control word must be 16#82000000";
            wait for period;
            assert control_word = x"F0100200" report "wrong control word must be 16#F0100200";

            rst <= '1';
            instruction <= "100";
            offset <= "011110000";
            z <= 'Z';
            c <= '0';
            wait for period;
            rst <= '0';
            wait for 2*period;
            assert control_word = x"82000000" report "wrong control word must be 16#82000000";
            wait for period;
            assert control_word = x"F0100200" report "wrong control word must be 16#F0100200";

            rst <= '1';
            instruction <= "100";
            offset <= "011110000";
            z <= '1';
            c <= '0';
            wait for period;
            rst <= '0';
            wait for 2*period;
            assert control_word = x"82000000" report "wrong control word must be 16#82000000";
            wait for period;
            assert control_word = x"F0100200" report "wrong control word must be 16#F0100200";
            -- ============================================================================ --
            rst <= '1';
            instruction <= "101";
            offset <= "011110000";
            c <= '1';
            wait for period;
            rst <= '0';
            wait for 2*period;
            assert control_word = x"82000000" report "wrong control word must be 16#82000000";
            wait for period;
            assert control_word = x"F0100200" report "wrong control word must be 16#F0100200";
            -- ============================================================================ --
            rst <= '1';
            instruction <= "110";
            offset <= "011110000";
            z <= '1';
            c <= 'Z';
            wait for period;
            rst <= '0';
            wait for 2*period;
            assert control_word = x"82000000" report "wrong control word must be 16#82000000";
            wait for period;
            assert control_word = x"F0100200" report "wrong control word must be 16#F0100200";

            rst <= '1';
            instruction <= "110";
            offset <= "011110000";
            z <= 'Z';
            c <= '1';
            wait for period;
            rst <= '0';
            wait for 2*period;
            assert control_word = x"82000000" report "wrong control word must be 16#82000000";
            wait for period;
            assert control_word = x"F0100200" report "wrong control word must be 16#F0100200";

            rst <= '1';
            instruction <= "110";
            offset <= "011110000";
            z <= '1';
            c <= '1';
            wait for period;
            rst <= '0';
            wait for 2*period;
            assert control_word = x"82000000" report "wrong control word must be 16#82000000";
            wait for period;
            assert control_word = x"F0100200" report "wrong control word must be 16#F0100200";
            -- ============================================================================ --
        end process;

        branch_inst : entity processor.branch
            generic map(
                counter_bits => counter_bits,
                control_word_width => control_word_width
            )
            port map(
                clk => clk,
                rst => rst,
                z => z,
                c => c,
                offset => offset,
                instruction => instruction,
                counter_rst => counter_rst,
                control_word => control_word,
                inner_state => state
            );
end tb;