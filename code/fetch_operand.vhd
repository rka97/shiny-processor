library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.p_constants.all;
library processor;

entity fetch_operand is
	generic(
		control_word_width  :integer:=32;
		counter_bits		:integer:=2
		);
	port(
		clk, rst 	: in std_logic :='1';
		--src_or_dst 	: in std_logic_vector(1 downto 0);
		--Ri 			: in std_logic_vector(2 downto 0);
        --add_mode 	: in std_logic_vector(2 downto 0);
		IR_data_out : in std_logic_vector(15 downto 0);
        counter_SM 	: in std_logic_vector(counter_bits-1 downto 0);
		control_word: out std_logic_vector(control_word_width-1 downto 0):=(others => 'Z');
		nxt_state :out std_logic := 'Z'
		);
end fetch_operand;

architecture behavioral of fetch_operand is
	
	type state_type is (fetch_op_state, execute_state);
	signal current_state,next_state : state_type;
	signal initial_state : state_type := fetch_op_state;
	signal Ri_decoded : std_logic_vector(7 downto 0);
	signal Ri_out, Rp1: std_logic_vector(3 downto 0);
	signal Ri, add_mode: std_logic_vector(2 downto 0);
	signal src_or_dst: std_logic_vector(1 downto 0);
	begin
		fetch_op_seq : process(clk,rst)
			begin
				if(rst='1') then
					current_state <= initial_state;
				elsif(rising_edge(clk) and clk='1')then
					current_state <= next_state;
				end if;
			end process;
		Riin_decoder : entity processor.decoder
    				generic map( Nsel =>3,Nout =>8 )
    				port map( enable => '1', A => Ri, F => Ri_decoded );

		fetch_op_comb : process(Ri, add_mode, counter_SM,Ri_decoded,IR_data_out)
  			variable fetch_cycle    : std_logic_vector(2 downto 0);
            variable Riin,Riout     : std_logic_vector(31 downto 0);
            variable address_mode   : std_logic_vector(1 downto 0);
        	variable mem_out		: boolean;
			variable Ri_out, Rp1	: std_logic_vector(3 downto 0);
			--variable Ri_decoded : std_logic_vector(7 downto 0);

            begin
				if( IR_data_out(15 downto 12)= "0110") then--one op, dst
					src_or_dst <= "01" ;
					add_mode <= IR_data_out(5 downto 3);
					Ri <= IR_data_out(2 downto 0);
				else --src --condition!
					src_or_dst <= "10"; --2op, src
					add_mode <= IR_data_out(11 downto 9);
					Ri <= IR_data_out(8 downto 6);
				end if;
                fetch_cycle := add_mode(2) & counter_SM(1 downto 0);
                Riin := (31 downto 21 => '0') & Ri_decoded & (12 downto 0 => '0');
				Ri_out := '0' & Ri;
				Rp1 := std_logic_vector(to_unsigned(to_integer(unsigned( Ri_out )) + 1, 4));
                Riout := Rp1 & (27 downto 0 => '0');
                address_mode := add_mode(1 downto 0); 
                
              	if address_mode = "00" then  -- register
                    if  fetch_cycle= "000" then --direct
                        if src_or_dst="10" then--src
                            control_word <=  (Riout or F_A or TMP2in);
                            next_state <= fetch_op_state; --to fetch dst
                        elsif src_or_dst="01" then --dst
                            control_word <=  (Riout or F_A or TMP1in);
                            next_state <= execute_state;
                        end if;
                        --counter_rst <= '1';
                    elsif  fetch_cycle = "100" then --indirect register
                        control_word <= (Riout or MARin1 or Rd or F_HI);
                    elsif  fetch_cycle = "101" then 
                        mem_out := true;
                    end if;
                elsif address_mode ="01" then -- auto_increment
                    if  fetch_cycle = "000" or fetch_cycle = "100" then
                        control_word <= (Riout or MARin1 or RD or F_Ap1 or Riin);
                    elsif  fetch_cycle = "101" then 
                        control_word <= (MDRout or MARin1 or Rd or F_HI);
                    elsif  fetch_cycle = "001" or fetch_cycle = "110" then 
                        mem_out := true;        
                    end if;

                elsif address_mode = "10" then -- auto_decrement
                    if  fetch_cycle = "000" or fetch_cycle = "100" then 
                        control_word <= Riout or F_Am1 or MARin or Rd or Riin;
                    elsif  fetch_cycle = "101" then 
                        control_word <= MDRout or MARin1 or Rd or F_HI;
                    elsif  fetch_cycle = "001" or fetch_cycle = "110" then 
                        mem_out := true;       
                    end if;

                elsif address_mode = "11"then -- indexed
                    if  fetch_cycle = "000" or fetch_cycle = "100" then 
                        control_word <= PCout or MARin1 or RD or F_Ap1 or PCin;
                    elsif  fetch_cycle = "001" or fetch_cycle = "101" then 
                        control_word <= MDRout or F_ApB or MARin or Rd;
                    elsif  fetch_cycle = "110" then 
                        control_word <= MDRout or MARin1 or Rd or F_HI;
                    elsif  fetch_cycle = "010" or fetch_cycle = "111" then
                        mem_out := true;       
                    end if;
                end if;
        		if (mem_out) then
					 if src_or_dst ="10" then--src
							nxt_state <= '0';
                            control_word <= MDRout or F_A or TMP2in;
                            next_state <= fetch_op_state;
                        else --dst
							nxt_state <= '1';
                            control_word <= MDRout or F_A or TMP1in;
                            next_state <= execute_state;
                        end if;
                        --counter_rst <= '1';
                        mem_out := false;
				end if;    
	        end process;

	
  
end architecture;
