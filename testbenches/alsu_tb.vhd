library ieee;
use ieee.std_logic_1164.all;

entity alsu_tb is
end alsu_tb;

architecture tb of alsu_tb is
    signal Sel : std_logic_vector(3 downto 0) := (others => 'Z');
    signal A : std_logic_vector(15 downto 0) := (others => 'Z');
    signal B : std_logic_vector(15 downto 0) := (others => 'Z');
    signal Cin : std_logic := 'Z';
    signal F : std_logic_vector(15 downto 0) := (others => 'Z');
    signal Cout : std_logic := 'Z';

    component alsu is
        generic (N : natural);
        port (
            Sel : in std_logic_vector(3 downto 0);
            A : in std_logic_vector(N-1 downto 0);
            B : in std_logic_vector(N-1 downto 0);
            Cin : in std_logic;
            F : out std_logic_vector(N-1 downto 0);
            Cout : out std_logic
        );
    end component alsu;

    begin
        alsu_inst : alsu
            generic map (N => 16)
            port map (
                Sel => Sel,
                A => A,
                B => B,
                Cin => Cin,
                F => F,
                Cout => Cout
            );

        process is
        begin
            -- total: 9+4+10=23 ns
            -- su
            A <= x"0F0F";
            Cin <= '0';
            Sel <= "1000";
            wait for 1 ns;
            Sel <= "1001";
            wait for 1 ns;
            Cin <= '0';
            Sel <= "1010";
            wait for 1 ns;
            Cin <= '1';
            wait for 1 ns;
            A <= x"F0F0";
            Sel <= "1011";
            wait for 1 ns;
            Sel <= "1100";
            A <= x"F0F0";
            wait for 1 ns;
            Sel <= "1101";
            wait for 1 ns;
            Sel <= "1110";
            Cin <= '0';
            wait for 1 ns;
            Cin <= '1';
            wait for 1 ns;
            Sel <= "1111";
            wait for 1 ns;
            -- au
            A <= x"0F0F";
            Cin <= '0';
            Sel <= "0000";
            wait for 1 ns;
            B <= x"0001";
            Sel <= "0001";
            wait for 1 ns;
            A <= x"FFFF";
            wait for 1 ns;
            Sel <= "0010";
            wait for 1 ns;
            Sel <= "0011";
            wait for 1 ns;
            Cin <= '1';
            A <= x"0F0E";
            Sel <= "0000";
            wait for 1 ns;
            A <= x"FFFF";
            Sel <= "0001";
            wait for 1 ns;
            Sel <= "0010";
            A <= x"0F0F";
            wait for 1 ns;
            Sel <= "0011";
            wait for 1 ns;
            -- lu
            A <= x"0F0F";
            B <= x"000A";
            Sel <= "0100";
            wait for 1 ns;
            Sel <= "0101";
            wait for 1 ns;
            Sel <= "0110";
            wait for 1 ns;
            Sel <= "0111";
            wait for 1 ns;
            
        end process;
end tb;