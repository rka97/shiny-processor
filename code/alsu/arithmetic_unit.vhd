library ieee;
use ieee.std_logic_1164.all;

entity arithmetic_unit is
    generic (N : natural);
    port (
        Sel : in std_logic_vector(1 downto 0);
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        Cin : in std_logic;
        F : out std_logic_vector(N-1 downto 0);
        Cout, Overflow : out std_logic
    );
end arithmetic_unit;

architecture behavioral of arithmetic_unit is
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

    signal temp_B : std_logic_vector(N-1 downto 0);
    signal temp_C : std_logic;
    signal temp_Sum : std_logic_vector(N-1 downto 0);
    signal temp_F : std_logic_vector(N-1 downto 0);
    begin
        adder_inst : adder
            generic map (N => N)
            port map (
                A => A,
                B => temp_B,
                Cin => Cin,
                Sum => temp_Sum,
                Cout => temp_C
            );

        process(A, B, Cin, Sel)
        begin
            if (Sel = "00") then
                temp_B <= (others => '0');
            elsif (Sel = "01") then
                temp_B <= B;
            elsif (Sel = "10") then
                temp_B <= not B;
            elsif (Sel = "11") then
                temp_B <= (others => '1');
            end if;
        end process;

        temp_F <= (others => '0') when (Sel = "11" and Cin = '1') else temp_Sum;
        F <= temp_F;
        Cout <= '0' when (Sel = "11" and Cin = '1') else temp_C;
        Overflow <= '1' when (A(N-1) = '0' and B(N-1) = '0' and F(N-1) = '1' and Sel = "01") else
                    '1' when (A(N-1) = '1' and B(N-1) = '1' and F(N-1) = '0' and Sel = "01") else 
                    '1' when (A(N-1) = '0' and B(N-1) = '1' and F(N-1) = '1' and Sel = "10") else
                    '1' when (A(N-1) = '1' and B(N-1) = '0' and F(N-1) = '0' and Sel = "11") else
                    '0';
end behavioral;