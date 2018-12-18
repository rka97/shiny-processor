library ieee;
use ieee.std_logic_1164.all;
library processor;
use processor.p_constants.all;

-- Connects the RAM, Register File, ALSU together. Decodes control signals given by user input.
-- Assume that B of ALU is TMP1
entity manual_ctrl_tb is
end manual_ctrl_tb;

architecture behave of manual_ctrl_tb is
    signal control_word : std_logic_vector(31 downto 0) := (others => 'Z');
    signal src_sel, dst_sel : std_logic_vector(13 downto 0) := (others => 'Z');
    signal alsu_sel : std_logic_vector(3 downto 0) := (others => 'Z');
    signal clk, br_offset_only, mar_in1, mem_rd, mem_wr, halt, nop, force_flag, src_en, dst_en, c_in : std_logic := 'Z';
    signal data_1, flags_data_current, flags_data_next : std_logic_vector(15 downto 0) := (others => '0');
    signal data_2, mar_data_out, mdr_data_in, mdr_data_out, tmp1_data_out, tmp2_data_out, IR_data_out : std_logic_vector(15 downto 0) := (others => 'Z');
    constant period : time := 1 ns;
    
begin
    c_in <= flags_data_current(0) when not (flags_data_current(0) = 'Z') else '0';
    cw_decoder_inst : entity processor.cw_decoder
        port map (
            control_word => control_word,
            src_sel => src_sel,
            dst_sel => dst_sel,
            alsu_sel => alsu_sel,
            br_offset_only => br_offset_only,
            mar_force_in => mar_in1,
            mem_rd => mem_rd,
            mem_wr => mem_wr,
            halt => halt,
            nop => nop,
            force_flag => force_flag,
            src_en => src_en,
            dst_en => dst_en
        );
    
    reg_file_inst : entity processor.reg_file
        generic map ( 
            N => 16,
            num_reg => 14
        )
        port map (
            clk => clk, src_en => src_en, dst_en => dst_en, src_sel => src_sel, dst_sel => dst_sel,
            data_1 => data_1,
            data_2 => data_2,
            mar_in1 => mar_in1,
            mdr_force_in => mem_rd,
            flags_force_in => force_flag,
            mdr_data_in => mdr_data_in,
            flags_data_in => flags_data_next, -- for now
            mar_data_out => mar_data_out,
            mdr_data_out => mdr_data_out,
            flags_data_out => flags_data_current,
            tmp1_data_out => tmp1_data_out,
            tmp2_data_out => tmp2_data_out,
            IR_data_out => IR_data_out
        );
    
    ram_inst : entity processor.ram
        generic map (
            N => 16,
            addr_size => 16
        )
        port map (
            clk => clk, read_in => mem_wr, write_out => mem_rd,
            address => mar_data_out,
            data_in => mdr_data_out,
            data_out => mdr_data_in
        );
    
    alsu_inst : entity processor.alsu
        generic map (N => 16)
        port map (
            Sel => alsu_sel,
            A => data_2,
            B => tmp1_data_out,
            Cin => c_in,
            F => data_1,
            Cout => flags_data_next(0)
        );
    process is
        begin
            data_1 <= x"CC00";
            control_word <= MDRin or F_HI;
            wait for period;
            -- write "AA00" to R0, R1, R2, TMP1, MAR
            -- write to memory too
            data_1 <= x"AA00";
            control_word <= R0in or R1in or R2in or TMP1in or MARin2 or WT or F_HI;
            wait for period;
            -- query data in R1
            -- read from memory to MDR
            data_1 <= (others => 'Z');
            control_word <= R1out or F_HI or RD;
            wait for period;
            assert (data_2 = x"AA00") report "Did not properly out to R1!";
            assert (mdr_data_out = x"CC00") report "Memory did not read/write properly!";
            -- now write 00BB to R3
            control_word <= R3in or F_HI;
            data_1 <= x"00BB";
            wait for period;
            data_1 <= (others => 'Z');
            control_word <= R3out or F_ApB or R1in;
            wait for period;
            control_word <= R1out or F_HI;
            wait for period;
            assert (data_2 = x"AABB") report "Did not properly add data!";
            control_word <= F_HI;
        end process;

    process is
        begin
            clk <= '0';
            wait for period / 2;
            clk <= '1';
            wait for period / 2;
        end process;
end behave;