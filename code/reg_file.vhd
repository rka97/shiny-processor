library ieee;
use ieee.std_logic_1164.all;
library processor;

entity reg_file is
    generic (
        N : natural := 32;
        num_reg : natural := 16 -- minimum 15
    );
    port (
        clk, src_en, dst_en, mdr_force_in, flags_force_in, mar_in1 : in std_logic;
        src_sel, dst_sel : in std_logic_vector(num_reg-1 downto 0);
        data_1 : in std_logic_vector(N-1 downto 0);
        data_2 : inout std_logic_vector(N-1 downto 0);
        mdr_data_in, flags_data_in : in std_logic_vector(N-1 downto 0);
        mar_data_out, mdr_data_out, flags_data_out, tmp1_data_out, tmp2_data_out, IR_data_out : out std_logic_vector(N-1 downto 0)
    );
end entity reg_file;

architecture structural of reg_file is
    signal decoded_src_sel, decoded_dst_sel : std_logic_vector(num_reg-1 downto 0);
    signal mar_activation : std_logic := '0';
    begin
        decoded_src_sel <= src_sel when (src_en = '1') else (others => '0');
        decoded_dst_sel <= dst_sel when (dst_en = '1') else (others => '0');
        regs: for i in 0 to 7 generate -- change this, don't make it hard-coded
            bi_reg_inst : entity processor.bi_reg_bare
                generic map ( N => N )
                port map (
                    clk => clk,
                    enable => '1',
                    load_in => decoded_dst_sel(i),
                    write_out => decoded_src_sel(i),
                    data_in => data_1,
                    data_out => data_2
                );
        end generate regs;
        
        ir_reg : entity processor.bi_reg
            generic map (N => N)
            port map (
                clk => clk,
                enable => '1',
                load_in => decoded_dst_sel(8),
                write_out => decoded_src_sel(8),
                force_in => '0',
                data_in => data_1,
                data_out => data_2,
                data_in_f => (others => 'Z'),
                data_out_f => IR_data_out
            );
        
        mar_reg : entity processor.bi_reg
            generic map (N => N)
            port map (
                clk => clk,
                enable => '1',
                load_in => decoded_dst_sel(9),
                write_out => decoded_src_sel(9),
                force_in => mar_in1,
                data_in => data_1,
                data_out => data_2,
                data_in_f => data_2,
                data_out_f => mar_data_out
            );

        mdr_reg : entity processor.bi_reg
            generic map (N => N)
            port map (
                clk => clk,
                enable => '1',
                load_in => decoded_dst_sel(10),
                write_out => decoded_src_sel(10),
                force_in => mdr_force_in,
                data_in => data_1,
                data_out => data_2,
                data_in_f => mdr_data_in,
                data_out_f => mdr_data_out
            );
        
        flags_reg : entity processor.bi_reg
        generic map (N => N)
        port map (
            clk => clk,
            enable => '1',
            load_in => decoded_dst_sel(11),
            write_out => decoded_src_sel(11),
            force_in => flags_force_in,
            data_in => data_1,
            data_out => data_2,
            data_in_f => flags_data_in,
            data_out_f => flags_data_out
        );

        tmp1_reg : entity processor.bi_reg
        generic map (N => N)
        port map (
            clk => clk,
            enable => '1',
            load_in => decoded_dst_sel(12),
            write_out => decoded_src_sel(12),
            force_in => '0',
            data_in => data_1,
            data_out => data_2,
            data_in_f => (others => 'Z'),
            data_out_f => tmp1_data_out
        );

        tmp2_reg : entity processor.bi_reg
        generic map (N => N)
        port map (
            clk => clk,
            enable => '1',
            load_in => decoded_dst_sel(13),
            write_out => decoded_src_sel(13),
            force_in => '0',
            data_in => data_1,
            data_out => data_2,
            data_in_f => (others => 'Z'),
            data_out_f => tmp2_data_out
        );
end structural;