library ieee;
use ieee.std_logic_1164.all;
library processor;

entity bi_reg is
    generic ( N : natural );
    port (
        clk, enable, load_in, write_out, force_in  : in std_logic;
        data : inout std_logic_vector(N-1 downto 0);
        data_in : in std_logic_vector(N-1 downto 0);
        data_out : out std_logic_vector(N-1 downto 0)
    );
end entity bi_reg;

architecture structural of bi_reg is
    signal actual_data_in : std_logic_vector(N-1 downto 0) := (others => 'Z');
    signal actual_data_out : std_logic_vector(N-1 downto 0) := (others => 'Z');
    signal actual_load : std_logic := 'Z';
    signal actual_write : std_logic := 'Z';
    begin
        actual_load <= '1' when (load_in = '1' and not (write_out = '1')) else 
                        '1' when (force_in = '1') else '0';
        actual_write <= '1' when (write_out = '1') else '0'; -- and not (load_in = '1')
        actual_data_in <= data_in when (force_in = '1') else data;
        data <= actual_data_out when (actual_write = '1') else (others => 'Z');
        data_out <= actual_data_out;
        reg_inst : entity processor.reg
            generic map ( N => N )
            port map (
                clk => clk,
                enable => enable,
                load => actual_load,
                data_in => actual_data_in,
                data_out => actual_data_out
            );
end structural;

library ieee;
use ieee.std_logic_1164.all;
library processor;
entity bi_reg_bare is
    generic ( N : natural );
    port (
        clk, enable, load_in, write_out  : in std_logic;
        data : inout std_logic_vector(N-1 downto 0)
    );
end entity bi_reg_bare;

architecture structural of bi_reg_bare is
    signal actual_data_out : std_logic_vector(N-1 downto 0) := (others => 'Z');
    signal actual_load : std_logic := 'Z';
    signal actual_write : std_logic := 'Z';
    begin
        actual_load <= '1' when (load_in = '1' and not (write_out = '1')) else '0';
        actual_write <= '1' when (write_out = '1') else '0'; -- and not (load_in = '1')
        data <= actual_data_out when (actual_write = '1') else (others => 'Z');
        reg_inst : entity processor.reg
            generic map ( N => N )
            port map (
                clk => clk,
                enable => enable,
                load => actual_load,
                data_in => data,
                data_out => actual_data_out
            );
end structural;

