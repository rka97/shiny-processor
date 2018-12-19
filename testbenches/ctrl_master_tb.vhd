library ieee;
use ieee.std_logic_1164.all;
library processor;
use processor.p_constants.all;

-- Connects the RAM, Register File, ALSU together. Decodes control signals given by user input.
-- Assume that B of ALU is TMP1
entity ctrl_master_tb is
end ctrl_master_tb;

architecture behave of ctrl_master_tb is
    signal control_word : std_logic_vector(31 downto 0) := (others => 'Z');
    signal src_sel, dst_sel : std_logic_vector(13 downto 0) := (others => 'Z');
    signal alsu_sel : std_logic_vector(3 downto 0) := (others => 'Z');
    signal clk, br_offset_only, mar_in1, mem_rd, mem_wr, halt, nop, cin_force, force_flag, src_en, dst_en, c_in : std_logic := 'Z';
    signal data_1, flags_data_current, flags_data_next : std_logic_vector(15 downto 0) := (others => '0');
    signal data_2, mar_data_out, mdr_data_in, mdr_data_out, tmp1_data_out, tmp2_data_out, IR_data_out : std_logic_vector(15 downto 0) := (others => 'Z');
    constant period : time := 1 ns;
    
begin
    c_in <= '1' when (cin_force = '1') else flags_data_current(0) when not (flags_data_current(0) = 'Z') else '0';
    cw_decoder_inst : entity processor.cw_decoder
        port map (
            control_word => control_word,
            src_sel => src_sel,
            dst_sel => dst_sel,
            alsu_sel => alsu_sel,
            cin_force => cin_force,
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
            Cout => flags_data_next(0),
            Zero => flags_data_next(1),
            Negative => flags_data_next(2),
            Parity => flags_data_next(3),
            Overflow => flags_data_next(4)
        );

    ctrl_master_inst : entity processor.ctrl_master
        port map (
            clk => clk,
            MDR_data => mdr_data_out,
            IR_data => IR_data_out,
            control_word => control_word
        );
    
    process (control_word, IR_data_out)
        begin
            -- data_2 <= SPECIFIC-GREAT-ADDRESS when (control_word(1) = '1') else (others => 'Z');
            data_2 <= (9 downto 0 => IR_data_out(10 downto 1), others => '0') when (control_word(7) = '1') else (others => 'Z');
            -- data_2 <= (9 downto 1 => IR_data_out(8 downto 0), others => '0') when (control_word(31 downto 28) = "1111") else (others => 'Z');
        end process;

    process is
        begin
            wait for period;
            assert (control_word = (PCout or F_A or MARin or TMP1in or RD)) report "F&D: T0 is wrong!";
            wait for period;
            assert (control_word = (TMP1out or F_Ap1 or PCin)) report "F&D: T1 is wrong!";
            wait for period;
            assert (control_word = (MDRout or F_A or IRin)) report "F&D: T2 is wrong!";
            wait for period;
            assert (IR_data_out = X"6000") report "IR data is wrong!";
        end process;

    process is
        begin
            clk <= '0';
            wait for period / 2;
            clk <= '1';
            wait for period / 2;
        end process;
end behave;