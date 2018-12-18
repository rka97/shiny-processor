library ieee;
use ieee.std_logic_1164.all;
library processor;
use work.p_constants.all;
entity fetch_op_tb is
end fetch_op_tb;

architecture behave of fetch_op_tb is
	constant control_word_width :integer :=32;
    signal clk, rst, src_or_dst : std_logic := '1';
	constant period 			: time := 25 ns;
	signal Ri,add_mode 			: std_logic_vector(2 downto 0);
	signal out_control_word 	: std_logic_vector(control_word_width-1 downto 0);
	signal count_SM 			:std_logic_vector(1 downto 0);
    begin
        counter_inst : entity processor.fetch_operand
        generic map(
            control_word_width => 32,
			counter_bits => 2
            )
        port map(
			clk =>clk , rst => rst,
            src_or_dst => src_or_dst,
			counter_SM => count_SM,
            Ri => Ri,
            add_mode => add_mode,
            control_word => out_control_word
            );
		
        process is
        begin
 			rst <= '1';
            wait for period;
            rst <= '0';

            -- Test Case 1
            src_or_dst <= '1';
            Ri <= "000";
            add_mode <= "000";
			count_SM <="00";
            wait for period;
            assert( out_control_word = (R0out or F_A or TMP1in)) report  "TC:1 error dst, R0, direct register &count =00 is wrong";
            wait for period;
			
			-- Test Case 2
            src_or_dst <= '1';
            Ri <= "001";
            add_mode <= "101";
			count_SM <="01";
            wait for period;
            assert( out_control_word = (MDRout or F_A or MARin2 or Rd)) report  "TC:2 error dst, R1, auto inc &count =01 is wrong";
            wait for period;
           
			-- Test Case 3
            src_or_dst <= '1';
            Ri <= "010";
            add_mode <= "010";
			count_SM <="00";
            wait for period;
            assert( out_control_word = (R2out or F_Am1 or MARin2 or Rd or R2in)) report  "TC:3 error dst, R2 and auto_dec &count =00 is wrong";
            wait for period;

			-- Test Case 4
            src_or_dst <= '0';
            Ri <= "111";
            add_mode <= "000";
			count_SM <="00";
            wait for period;
            assert( out_control_word = (R7out or F_A or TMP2in)) report  "TC:4 error src, R7, direct register &count =00 is wrong";
            wait for period;

            -- Test Case 5
            src_or_dst <= '0';
            Ri <= "100";
            add_mode <= "100";
			count_SM <="00";
            wait for period;
            assert( out_control_word = (R4out or MARin1 or Rd)) report  "TC:5 error src, R4, indirect register &count =00 is wrong";
            wait for period;

             -- Test Case 6
             src_or_dst <= '0';
             Ri <= "101";
             add_mode <= "100";
             count_SM <="01";
             wait for period;
             assert( out_control_word = (MDRout or F_A or TMP2in)) report  "TC:6 error src, R5, indirect register &count =01 is wrong";
             wait for period;

			 -- Test Case 7
             src_or_dst <= '0';
             Ri <= "101";
             add_mode <= "111";
             count_SM <="01";
             wait for period;
             assert( out_control_word = (MDRout or F_ApB or MARin2 or Rd)) report  "TC:7 error src, R5, indirect indexed &count =01 is wrong";
             wait for period;

			-- Test Case 8
             src_or_dst <= '1';
             Ri <= "101";
             add_mode <= "111";
             count_SM <="11";
             wait for period;
             assert( out_control_word = (MDRout or F_A or TMP1in)) report  "TC:8 error dst, R5, indirect indexed &count =11 is wrong";
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
