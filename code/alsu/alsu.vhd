library ieee;
use ieee.std_logic_1164.all;

entity alsu is
    generic (N : natural);
    port (
        Sel : in std_logic_vector(3 downto 0);
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        Cin : in std_logic;
        F : out std_logic_vector(N-1 downto 0);
        Cout : out std_logic
    );
end alsu;

architecture structural of alsu is
    component arithmetic_unit is
        generic (N : natural);
        port (
            Sel : in std_logic_vector(1 downto 0);
            A : in std_logic_vector(N-1 downto 0);
            B : in std_logic_vector(N-1 downto 0);
            Cin : in std_logic;
            F : out std_logic_vector(N-1 downto 0);
            Cout : out std_logic
        );
    end component arithmetic_unit;

    component logic_unit is
        generic (N : natural);
        port (
            Sel : in std_logic_vector(1 downto 0);
            A : in std_logic_vector(N-1 downto 0);
            B : in std_logic_vector(N-1 downto 0);
            F : out std_logic_vector(N-1 downto 0)
        );
    end component logic_unit;

    component shift_unit is
        generic (N : natural);
        port (
            Sel : in std_logic_vector(2 downto 0);
            A : in std_logic_vector(N-1 downto 0);
            Cin : in std_logic;
            F : out std_logic_vector(N-1 downto 0);
            Cout : out std_logic
        );
    end component shift_unit;
    
    signal au_F : std_logic_vector(N-1 downto 0);
    signal au_Cout : std_logic;
    signal lu_F : std_logic_vector(N-1 downto 0);
    signal su_F : std_logic_vector(N-1 downto 0);
    signal su_Cout : std_logic;

    begin
        au_inst : arithmetic_unit
        generic map (N => N)
        port map (
            Sel => Sel(1 downto 0),
            A => A,
            B => B,
            Cin => Cin,
            F => au_F,
            Cout => au_Cout
        );

        lu_inst : logic_unit
        generic map (N => N)
        port map (
            Sel => Sel(1 downto 0),
            A => A,
            B => B,
            F => lu_F
        );

        su_inst : shift_unit
        generic map (N => N)
        port map (
            Sel => Sel(2 downto 0),
            A => A,
            Cin => Cin,
            F => su_F,
            Cout => su_Cout
        );

        F <= au_F when Sel(3 downto 2) = "00" else
            lu_F when Sel(3 downto 2) = "01" else
            su_F;
        
        Cout <= au_Cout when Sel(3 downto 2) = "00" else
            '0' when Sel(3 downto 2) = "01" else
            su_Cout;
end structural;