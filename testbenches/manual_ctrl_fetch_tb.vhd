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
    signal alsu_sel, count : std_logic_vector(3 downto 0) := (others => 'Z');
    signal clk, br_offset_only, mar_in1, mem_rd, mem_wr, halt, nop, cin_force, force_flag, src_en, dst_en, c_in, enable, rst : std_logic := 'Z';
    signal data_1, flags_data_current, flags_data_next : std_logic_vector(15 downto 0) := (others => '0');
    signal data_2, mar_data_out, mdr_data_in, mdr_data_out, tmp1_data_out, tmp2_data_out, IR_data_out : std_logic_vector(15 downto 0) := (others => 'Z');
    signal src_or_dst : std_logic_vector(1 downto 0) := (others => 'Z');
	signal add_mode, Ri : std_logic_vector(2 downto 0) := (others => 'Z');
	constant period : time := 1 ns;
    constant max_nbits : integer :=4;
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
	fetch_op_state : entity processor.fetch_operand
	generic map(
		control_word_width => 32,
		counter_bits => max_nbits
		)
	port map(
		clk => Clk,
        rst => rst,
        IR_data_out => IR_data_out,
        counter_SM => count,
		control_word => control_word
		);
	
		
    process is
        begin
            -- Test Case 1 direct reg
            rst <= '1';
             wait for period;       
             rst <= '0';
             wait for period;
            IR_data_out <= "1111000000000000";
            enable<='1';
            wait for period;
            assert( control_word = (R0out or F_A or TMP2in)) report  "TC:1 error dst, R0, direct register &count =00 is wrong";
            wait for period;

            -- Test Case 2 indirect auto inc
            rst <= '1';
            wait for period;     
            rst <= '0';
            wait for period;
            IR_data_out <= "1111101001000000";
			enable<='1';  
            wait for period;
            assert( control_word = (R1out or MARin1 or RD or F_Ap1 or R1in)) report  "TC:20 error: indirect auto inc &count =01 is wrong";
            wait for period;
  
            assert( control_word = (MDRout or F_HI or MARin1 or Rd)) report  "TC:21 error: indirect auto inc &count =01 is wrong";
            wait for period;

            assert( control_word =  (MDRout or F_A or TMP2in)) report  "TC:22 error: indirect auto inc &count =01 is wrong";
            wait for period;
           
			-- Test Case 3 direct auto dec      
            rst <= '1';
             wait for period; 
             rst <= '0';
             wait for period;
            IR_data_out <= "1111010010000000";
			enable<='1';      
            wait for period;
            assert( control_word = (R2out or F_Am1 or MARin or Rd or R2in)) report  "TC:30 error direct auto dec &count =00 is wrong";
            wait for period;
           
            assert( control_word = (MDRout or F_A or TMP2in)) report  "TC:31 error direct auto dec &count =00 is wrong";
            wait for period;

            -- Test Case 4 auto inc 
            rst <= '1';
            wait for period;      
             rst <= '0';
             wait for period;    
            IR_data_out <= "1111001111000000";
			enable<='1'; 
            wait for period;
            assert( control_word = (R7out or MARin1 or RD or F_Ap1 or R7in)) report  "TC:40 error auto inc &count =00 is wrong";
            wait for period;

            assert( control_word = (MDRout or F_A or TMP2in)) report  "TC:41 error auto inc &count =00 is wrong";
            wait for period;

            -- Test Case 5 indirect reg           
            rst <= '1';
             wait for period;       
             rst <= '0';
             wait for period;
            IR_data_out <= "1111100100000000";
			enable<='1';
            wait for period;
            assert( control_word = (R4out or MARin1 or Rd or F_HI)) report  "TC:50 error  indirect register &count =00 is wrong";
            wait for period;

            assert( control_word = (MDRout or F_A or TMP2in)) report  "TC:51 error  indirect register &count =00 is wrong";
            wait for period;

             -- Test Case 6 dir indx 
             rst <= '1';
             wait for period;      
             rst <= '0';
             wait for period;    
             IR_data_out <= "1111011101000000";
             enable<='1'; 
             wait for period;
             assert( control_word = (PCout or MARin1 or RD or F_Ap1 or PCin)) report  "TC:60 error dir indx &count =01 is wrong";
             wait for period;

             assert( control_word = (MDRout or F_ApB or MARin or Rd)) report  "TC:61 error dir indx &count =01 is wrong";
             wait for period;

             assert( control_word = (MDRout or F_A or TMP2in)) report  "TC:62 error dir indx &count =01 is wrong";
             wait for period;

			 -- Test Case 7 indirect indexed           
             rst <= '1';
             wait for period;       
             rst <= '0';
             wait for period;
             IR_data_out <= "1111111101000000";
             enable<='1';
             wait for period;
             assert( control_word = (PCout or MARin1 or RD or F_Ap1 or PCin)) report  "TC:70 error  indirect indexed &count =01 is wrong";
             wait for period;
             
             assert( control_word = (MDRout or F_ApB or MARin or Rd)) report  "TC:71 error  indirect indexed &count =01 is wrong";
             wait for period;

             --wait for period;
             assert( control_word = (MDRout or MARin1 or Rd or F_HI)) report  "TC:72 error  indirect indexed &count =01 is wrong";
             wait for period;

             --wait for period;
             assert( control_word = (MDRout or F_A or TMP2in)) report  "TC:73 error  indirect indexed &count =01 is wrong";
             wait for period;

            -- Test Case 8 indir auto dec  
             rst <= '1';
             wait for period;    
             rst <= '0';
             wait for period;
             IR_data_out <= "1111110101000000";
             enable<='1';   
             wait for period;
             assert( control_word = (R5out or F_Am1 or MARin or Rd or R5in)) report  "TC:80 error dst, R5, indirect indexed &count =11 is wrong";
             wait for period;

             assert( control_word = (MDRout or MARin1 or Rd or F_HI)) report  "TC:81 error dst, R5, indirect indexed &count =11 is wrong";
             wait for period;

             assert( control_word = (MDRout or F_A or TMP2in)) report  "TC:82 error dst, R5, indirect indexed &count =11 is wrong";
             wait for period;


        end process;

    process is
        begin
            clk <= '0';
            wait for period / 2;
            clk <= '1';
            wait for period / 2;
        end process;
end behave;