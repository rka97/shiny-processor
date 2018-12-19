library ieee;
use ieee.std_logic_1164.all;
library processor;
use processor.p_constants.all;

-- Connects the RAM, Register File, ALSU together. Decodes control signals given by user input.
-- Assume that B of ALU is TMP1
entity manual_ctrl_jmp_tb is
end manual_ctrl_jmp_tb;

architecture behave of manual_ctrl_jmp_tb is
    signal control_word : std_logic_vector(31 downto 0) := (others => 'Z');
    signal src_sel, dst_sel : std_logic_vector(13 downto 0) := (others => 'Z');
    signal alsu_sel, count : std_logic_vector(3 downto 0) := (others => 'Z');
    signal clk, br_offset_only, mar_in1, mem_rd, mem_wr, halt, nop, cin_force, force_flag, src_en, dst_en, c_in, enable, rst : std_logic := 'Z';
    signal data_1, flags_data_current, flags_data_next, ir : std_logic_vector(15 downto 0) := (others => '0');
    signal data_2, mar_data_out, mdr_data_in, mdr_data_out, tmp1_data_out, tmp2_data_out, IR_data_out : std_logic_vector(15 downto 0) := (others => 'Z');
    constant period : time := 100 ps;
    
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
    counter_inst : entity processor.counter
        generic map (
            max_nbits => 4
        )
        port map (
            clk => Clk,
            rst => rst,
            enable => enable,
            count => count
        );
    jsr_int_inst: entity processor.jsr_int
        generic map(
            n => 32
        )
        port map (
            ir => ir,
	        op => control_word,
            clk => Clk,
            rst => rst,
            enable =>enable,
	        count => count
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
    process is
        begin
        -- case 1 jsr forcing counter values
        rst <= '1';
        enable <= '1';
		ir <= "0100000000000000";
		wait for period ;
		assert( control_word = (BrIRout or F_A or TMP2in))
		report  " error in jsr count 0"
		severity error;
		rst <= '0';
		wait for period;
		assert( control_word = (SPout or F_Am1 or TMP1in or SPin or MARin2))
		report  " error in jsr count 1"
		severity error;

		wait for period;
		assert( control_word = (PCout or F_Ap1 or MDRin or WT))
		report  " error in jsr count 2"
		severity error;

		wait for period;
		assert( control_word = (TMP2out or F_A or PCin))
		report  " error in jsr count 3"
		severity error;
		wait for period;

        --case 2 ret forcing counter values
        rst <= '1';
        --wait for period;
		ir <= "0011000000000000";
		enable<='1';
		wait for period;
		assert( control_word = (SPout or F_A or MARin2 or TMP1in or RD))
		report  " error in ret count 0"
		severity error;
		  rst <= '0';
		wait for period;
		assert( control_word = ( F_Ap1 or SPin))
		report  " error in ret count 1"
		severity error;
		wait for period;
		assert( control_word = (MDRout or F_A or PCin))
		report  " error in ret count 2"
		severity error;
		wait for period;
		
        --case 3 hitr forcing counter values
        rst <= '1';
        --wait for period;
		ir <= "0011100000000000";
		enable<='1';
		wait for period;
		assert( control_word = (SPout or F_Am1 or SPin or MARin2))
		report  " error in hitr count 0"
		severity error;
		 rst <= '0';
		wait for period;
		assert( control_word = ( FLAGout or F_A or MDRin or WT))
		report  " error in hitr count 1"
		severity error;
		
		wait for period;
		assert( control_word = (SPout or F_Am1 or SPin or MARin2))
		report  " error in hitr count 2"
		severity error;
		
		wait for period;
		assert( control_word = ( PCout or F_A or MDRin or WT))
		report  " error in hitr count 3"
		severity error;
	
		wait for period;
		assert( control_word = ( BrIRout or F_A or PCin))
		report  " error in hitr count 5"
		severity error;
		wait for period;

		--case 4 iret forcing counter values
		ir <= "0010000000000000";
		rst <= '1';
		enable<='1';
		wait for period;
		assert( control_word = (SPout or MARin1 or RD))
		report  " error in iret count 0"
		severity error;
		rst <= '0';
		wait for period;
		assert( control_word = ( SPout or F_Ap1 or SPin))
		report  " error in iret count 1"
		severity error;
		
		wait for period;
		assert( control_word = (MDRout or F_A or PCin))
		report  " error in iret count 2"
		severity error;
		
		wait for period;
		assert( control_word = ( SPout or MARin1 or RD))
		report  " error in iret count 3"
		severity error;
		
		wait for period;
		assert( control_word = (SPout or F_Ap1 or SPin))
		report  " error in iret count 4"
		severity error;
		wait for period;
		
		assert( control_word = ( MDRout or F_A or FLAGin))
		report  " error in iret count 5"
		severity error;
		wait for period;

		--case 5 HLT forcing counter values
		rst <= '1';
		ir <= "0001000000000000";
		enable<='1';
		wait for period;
		assert( control_word = (HLT))
		report  " error in HLT"
		severity error;
		wait for period;

		--case 6 NOP forcing counter values
		ir <= "0000000000000000";
		enable<='1';
		wait for period;
		assert( control_word = (NoOP))
		report  " error in NOP"
		severity error;
		wait for period;
        end process;

    process is
        begin
            clk <= '0';
            wait for period/2;
            clk <= '1';
            wait for period/2;
        end process;
end behave;