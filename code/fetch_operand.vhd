library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.p_constants.all;
library processor;

entity fetch_operand is
	generic (
		counter_bits : integer := 2;
		control_word_width : integer := 32
    );
	port (
		clk, rst : in std_logic;
		counter_rst, counter_enable : inout std_logic; -- one counter for the whole SM
		src_or_dst : in std_logic;
		Ri : in std_logic_vector(2 downto 0);
		add_mode : in std_logic_vector(2 downto 0);
		control_word : out std_logic_vector(control_word_width-1 downto 0)
    );
end fetch_operand;

architecture behavioral of fetch_operand is
	
	type state_type is (fetch_op_state, execute_state);
	signal current_state,next_state,inital_state : state_type;
	
	type fetct_op_state is (mem_out_op, prepare_op);
	signal cur_state,nxt_state,init_state : fetct_op_state;
	signal count : std_logic_vector(counter_bits-1 downto 0);
	signal address_mode : std_logic_vector(1 downto 0);
	signal Ri_in : std_logic_vector(7 downto 0);

	begin
		fetch_op_seq : process(clk,rst)
			begin
				if(rst='1') then
					cur_state<=init_state;
				elsif(rising_edge(clk) and clk='1')then
					cur_state<=nxt_state;
				end if;
			end process;
		address_mode <= add_mode(1 downto 0);

		fetch_op_comb : process(add_mode, Ri, count)

            variable fetch_cycle : std_logic_vector(2 downto 0);
            variable Riout,Riin : std_logic_vector(31 downto 0);

            begin

				fetch_cycle := add_mode(2) & count;
                Riout := '0' & Ri & (27 downto 0 => '0');
				Riin := (31 downto 22 => '0') & Ri_in & (13 downto 0 => '0');

                case cur_state is
                    when prepare_op =>      
                        if address_mode = "00" then  -- register
                            if  fetch_cycle= "000" then --direct
                                if src_or_dst='0' then
                                    control_word <=  Riout or F_A or TMP2in;
                                    next_state <= current_state; --to fetch dst
                                else 
                                    control_word <=  Riout or F_A or TMP1in;
                                    next_state <= execute_state;
                                end if;
                                counter_rst <= '1';
                            elsif  fetch_cycle = "100" then --indirect register
                                control_word <= Riout or MARin1 or Rd;
                            elsif  fetch_cycle = "101" then 
                                nxt_state <= mem_out_op;
                                
                            end if;
                        elsif address_mode ="01" then -- auto_increment
                            if  fetch_cycle = "000" or fetch_cycle = "100" then
                                control_word <= Riout or MARin1 or RD or F_Ap1 or Riin; --F=B+1
                            elsif  fetch_cycle = "101" then 
                                control_word <= MDRout2 or MARin2 or Rd;
                            elsif  fetch_cycle = "001" or fetch_cycle = "101" then 
                            nxt_state <= mem_out_op;
                            end if;

                        elsif address_mode = "10" then -- auto_decrement
                            if  fetch_cycle = "000" or fetch_cycle = "100" then 
                                control_word <= Riout or F_Am1 or MARin2 or Rd or Riin;
                            elsif  fetch_cycle = "101" then 
                                control_word <= MDRout2 or MARin2 or Rd;
                            elsif  fetch_cycle = "001" or fetch_cycle = "110" then 
                                nxt_state <= mem_out_op;
                            end if;

                        elsif address_mode = "11"then -- indexed
                            if  fetch_cycle = "000" or fetch_cycle = "100" then 
                                control_word <= PCout or MARin1 or RD or F_Ap1 or PCin;
                            elsif  fetch_cycle = "001" or fetch_cycle = "101" then 
                                control_word <= MDRout1 or F_ApB or MARin2 or Rd;
                            elsif  fetch_cycle = "110" then 
                                control_word <= MDRout2 or MARin2 or Rd;
                            elsif  fetch_cycle = "010" or fetch_cycle = "111" then
                                nxt_state <= mem_out_op;
                            end if;
                        end if;
                    when mem_out_op => 
                        if src_or_dst='0' then
                            control_word <= MDRout2 or TMP1in;
                            next_state <= current_state; --to fetch dst
                        else 
                            control_word <= MDRout2 or TMP2in;
                            next_state <= execute_state;
                        end if;
                        counter_rst <= '1';       
                    end case;
	        end process;

	Riin_decoder : entity processor.decoder
    				generic map( Nsel =>3,Nout =>8 )
    				port map( enable => '1', A => Ri, F => Ri_in );
    counter1 : entity processor.counter 
					generic map (n =>counter_bits) 
					port map (clk => clk, rst => counter_rst,enable =>counter_enable, count =>count);
		
end architecture;
