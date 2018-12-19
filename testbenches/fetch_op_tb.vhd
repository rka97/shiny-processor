library ieee;
use ieee.std_logic_1164.all;
library processor;
use work.p_constants.all;
entity fetch_op_tb is
end fetch_op_tb;

architecture behave of fetch_op_tb is
	constant control_word_width :integer :=32;
    signal clk, rst				: std_logic := '1';
	constant period 			: time := 25 ns;
	--signal Ri,add_mode 			: std_logic_vector(2 downto 0);
	signal out_control_word 	: std_logic_vector(control_word_width-1 downto 0):=(others => 'Z');
	signal count_SM,src_or_dst 	:std_logic_vector(1 downto 0):=(others => 'Z');
	signal IR_data_out 	:std_logic_vector(15 downto 0):=(others => 'Z');
	signal nxt_state: std_logic:='Z';
    begin
        counter_inst : entity processor.fetch_operand
        generic map(
            control_word_width => 32,
			counter_bits => 2
            )
        port map(
			clk =>clk , rst => rst,
            --src_or_dst => src_or_dst,
			counter_SM => count_SM,
			IR_data_out => IR_data_out,
            --Ri => Ri,
            --add_mode => add_mode,
			nxt_state => nxt_state,
            control_word => out_control_word
            );
		
        process is
        begin
 			rst <= '1';
            wait for period;
            rst <= '0';

            
            -- Test Case 1 direct reg
            --Ri <= "000";
            --add_mode <= "000";
			IR_data_out <= "1111000000000000";
			count_SM <="00";
            wait for period;
            assert( out_control_word = (R0out or F_A or TMP2in)) report  "TC:1 error dst, R0, direct register &count =00 is wrong";
            wait for period;

			 -- Test Case 2 indirect auto inc
            --Ri <= "001";
            --add_mode <= "101";
            IR_data_out <= "1111101001000000";
			count_SM <="01";
            wait for period;
            assert( out_control_word = (MDRout or F_HI or MARin1 or Rd)) report  "TC:2 error: indirect auto inc &count =01 is wrong";
            wait for period;
           
			-- Test Case 3 direct auto dec      
            --Ri <= "010";
            --add_mode <= "010";
            IR_data_out <= "1111010010000000";
			count_SM <="00";
            wait for period;
            assert( out_control_word = (R2out or F_Am1 or MARin or Rd or R2in)) report  "TC:3 error direct auto dec &count =00 is wrong";
            wait for period;
			            
			-- Test Case 4 auto inc     
            --Ri <= "111";
            --add_mode <= "001";
            IR_data_out <= "1111001111000000";
			count_SM <="00";
            wait for period;
            assert( out_control_word = (R7out or MARin1 or RD or F_Ap1 or R7in)) report  "TC:4 error auto inc &count =00 is wrong";
            wait for period;

            -- Test Case 5 indirect reg           
            --Ri <= "100";
            --add_mode <= "100";
            IR_data_out <= "1111100100000000";
			count_SM <="00";
            wait for period;
            assert( out_control_word = (R4out or MARin1 or Rd or F_HI)) report  "TC:5 error  indirect register &count =00 is wrong";
            wait for period;

             -- Test Case 6 dir indx     
             --Ri <= "101";
             --add_mode <= "011";
             IR_data_out <= "1111011101000000";
             count_SM <="01";
             wait for period;
             assert( out_control_word = (MDRout or F_ApB or MARin or Rd)) report  "TC:6 error dir indx &count =01 is wrong";
             wait for period;

			 -- Test Case 7 indirect indexed           
             --Ri <= "101";
             --add_mode <= "111";
             IR_data_out <= "1111111101000000";
             count_SM <="01";
             wait for period;
             assert( out_control_word = (MDRout or F_ApB or MARin or Rd)) report  "TC:7 error  indirect indexed &count =01 is wrong";
             wait for period;

			-- Test Case 8 indir auto dec         
             --Ri <= "101";
             --add_mode <= "111";
             IR_data_out <= "1111110101000000";
             count_SM <="10";
             wait for period;
             assert( out_control_word = (MDRout or F_A or TMP2in)) report  "TC:8 error dst, R5, indirect indexed &count =11 is wrong";
             wait for period;

			--for dst

            -- Test Case 11 direct reg
            --Ri <= "000";
            --add_mode <= "000";
			IR_data_out <= "0110000000000000";
			count_SM <="00";
            wait for period;
            assert( out_control_word = (R0out or F_A or TMP1in)) report  "TC:11 error dst, R0, direct register &count =00 is wrong";
            wait for period;

			-- Test Case 12  
            --Ri <= "001";
            --add_mode <= "101";
            IR_data_out <= "0110000000101001";
			count_SM <="01";
            wait for period;
            assert( out_control_word = (MDRout or F_HI or MARin1 or Rd)) report  "TC:12 error dst, R1, auto inc &count =01 is wrong";
            wait for period;
           
			-- Test Case 13
            --Ri <= "010";
            --add_mode <= "010";
            IR_data_out <= "0110000000010010";
			count_SM <="00";
            wait for period;
            assert( out_control_word = (R2out or F_Am1 or MARin or Rd or R2in)) report  "TC:13 error dst, R2 and auto_dec &count =00 is wrong";
            wait for period;
			            
			-- Test Case 14 auto inc
            --Ri <= "111";
            --add_mode <= "001";
            IR_data_out <= "0110000000001111";
			count_SM <="00";
            wait for period;
            assert( out_control_word = (R7out or MARin1 or RD or F_Ap1 or R7in)) report  "TC:14 error auto inc &count =00 is wrong";
            wait for period;

            -- Test Case 15
            --Ri <= "100";
            --add_mode <= "100";
            IR_data_out <= "0110000000100100";
			count_SM <="00";
            wait for period;
            assert( out_control_word = (R4out or MARin1 or Rd or F_HI)) report  "TC:15 error src, R4, indirect register &count =00 is wrong";
            wait for period;

             -- Test Case 16 dir indx
             --Ri <= "101";
             --add_mode <= "011";
             IR_data_out <= "0110000000011101";
             count_SM <="01";
             wait for period;
             assert( out_control_word = (MDRout or F_ApB or MARin or Rd)) report  "TC:16 error dir indx &count =01 is wrong";
             wait for period;
           
            -- Test Case 17 
             --Ri <= "101";
             --add_mode <= "111";
             IR_data_out <= "0110000000111101";
             count_SM <="01";
             wait for period;
             assert( out_control_word = (MDRout or F_ApB or MARin or Rd)) report  "TC:17 error src, R5, indirect indexed &count =01 is wrong";
             wait for period;

			-- Test Case 18 indir auto dec 
             --Ri <= "101";
             --add_mode <= "110";
             IR_data_out <= "0110000000110101";
             count_SM <="10";
             wait for period;
             assert( out_control_word = (MDRout or F_A or TMP1in)) report  "TC:18 error indirect indexed &count =11 is wrong";
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
