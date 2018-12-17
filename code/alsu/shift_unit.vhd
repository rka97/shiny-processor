library ieee;
use ieee.std_logic_1164.all;

entity shift_unit is
    generic (N : natural);
    port (
        Sel : in std_logic_vector(2 downto 0);
        A : in std_logic_vector(N-1 downto 0);
        Cin : in std_logic;
        F : out std_logic_vector(N-1 downto 0);
        Cout : out std_logic
    );
end shift_unit;

architecture behavioral of shift_unit is
    begin
        process(Sel, A, Cin)
        begin
            if (Sel = "000") then
                Cout <= A(0);
                F <= '0' & A(N-1 downto 1);
            elsif (Sel = "001") then
                Cout <= A(0);
                F <= A(0) & A(N-1 downto 1);
            elsif (Sel = "010") then
                Cout <= A(0);
                F <= Cin & A(N-1 downto 1);
            elsif (Sel = "011") then
                Cout <= A(0);
                F <= A(N-1) & A(N-1 downto 1);
            elsif (Sel = "100") then
                Cout <= A(N-1);
                F <= A(N-2 downto 0) & '0';
            elsif (Sel = "101") then
                Cout <= A(N-1);
                F <= A(N-2 downto 0) & A(N-1);
            elsif (Sel = "110") then
                Cout <= A(N-1);
                F <= A(N-2 downto 0) & Cin;
            else
                Cout <= '0';
                F <= (others => '0');
            end if;
        end process;
end behavioral;