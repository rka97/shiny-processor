library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library processor;

entity reg_file is
    generic (
        N, num_reg : natural
    );
    port (
        clk, src_en, dst_en, mdr_force_in : in std_logic;
        src_sel, dst_sel : in std_logic_vector(num_reg-1 downto 0);
        data : inout std_logic_vector(N-1 downto 0);
        mdr_data_in : in std_logic_vector(N-1 downto 0);
        mar_data_out, mdr_data_out : out std_logic_vector(N-1 downto 0)
    );
end entity reg_file;

architecture structural of reg_file is
    signal decoded_src_sel, decoded_dst_sel : std_logic_vector(num_reg-1 downto 0);
    begin
        decoded_src_sel <= src_sel when (src_en = '1') else (others => '0');
        decoded_dst_sel <= dst_sel when (dst_en = '1') else (others => '0');
        regs: for i in 0 to num_reg-3 generate
            bi_reg_inst : entity processor.bi_reg_bare
                generic map ( N => N )
                port map (
                    clk => clk,
                    enable => '1',
                    load_in => decoded_dst_sel(i),
                    write_out => decoded_src_sel(i),
                    data => data
                );
        end generate regs;
        
        mar_reg : entity processor.bi_reg
            generic map (N => N)
            port map (
                clk => clk,
                enable => '1',
                load_in => decoded_dst_sel(num_reg-2),
                write_out => decoded_src_sel(num_reg-2),
                force_in => '0',
                data => data,
                data_in => (others => 'Z'),
                data_out => mar_data_out
            );
        
        mdr_reg : entity processor.bi_reg
            generic map (N => N)
            port map (
                clk => clk,
                enable => '1',
                load_in => decoded_dst_sel(num_reg-1),
                write_out => decoded_src_sel(num_reg-1),
                force_in => mdr_force_in,
                data => data,
                data_in => mdr_data_in,
                data_out => mdr_data_out
            );

end structural;