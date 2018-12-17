library ieee;
use ieee.std_logic_1164.all;

entity adder_tb is
end adder_tb;

architecture tb of adder_tb is
    signal A : std_logic_vector(3 downto 0);
    signal B : std_logic_vector(3 downto 0);
    signal Cin : std_logic;
    signal Sum : std_logic_vector(3 downto 0);
    signal Cout : std_logic;

    component adder is
        generic (N : natural);
        port (
            A : in std_logic_vector(N-1 downto 0);
            B : in std_logic_vector(N-1 downto 0);
            Cin : in std_logic;
            Sum : out std_logic_vector(N-1 downto 0);
            Cout : out std_logic
        );
    end component adder;

    begin
        adder_inst : adder
            generic map (N => 4)
            port map (
                A => A,
                B => B,
                Cin => Cin,
                Sum => Sum,
                Cout => Cout
            );

        process is
        begin
            A <= "0001";
            B <= "0000";
            Cin <= '0';
            wait for 1 ns;
            A <= "0101";
            B <= "1010";
            Cin <= '0';
            wait for 1 ns;
            A <= "0001";
            B <= "1001";
            Cin <= '0';
            wait for 1 ns;
        end process;
end tb;