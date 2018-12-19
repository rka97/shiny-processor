library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.p_constants.all;
library processor;

entity fetch_operand is
	generic(
		control_word_width  :integer:=32;
		counter_bits		:integer:=2
		);
	port(
		clk, rst 	: in std_logic :='1';
		src_or_dst 	: in std_logic;
		Ri 			: in std_logic_vector(2 downto 0);
        add_mode 	: in std_logic_vector(2 downto 0);
        counter_SM 	: in std_logic_vector(counter_bits-1 downto 0);
		control_word: out std_logic_vector(control_word_width-1 downto 0)
		);
end fetch_operand;

architecture behavioral of fetch_operand is
	
	type state_type is (fetch_op_state, execute_state);
	signal current_state,next_state : state_type;
	signal initial_state : state_type := fetch_op_state;
	signal Ri_decoded : std_logic_vector(7 downto 0);
	
	begin
		fetch_op_seq : process(clk,rst)
			begin
				if(rst='1') then
					current_state <= initial_state;
				elsif(rising_edge(clk) and clk='1')then
					current_state <= next_state;
				end if;
			end process;

		fetch_op_comb : process(Ri, add_mode, counter_SM)
  			variable fetch_cycle    : std_logic_vector(2 downto 0);
            variable Riin,Riout     : std_logic_vector(31 downto 0);
            variable address_mode   : std_logic_vector(1 downto 0);
        	variable mem_out		: boolean;

            begin
                fetch_cycle := add_mode(2) & counter_SM(1 downto 0);
                Riin := (31 downto 22 => '0') & Ri_decoded & (13 downto 0 => '0');
                Riout := '0' & Ri & (27 downto 0 => '0');
                address_mode := add_mode(1 downto 0); 
                
              	if address_mode = "00" then  -- register
                    if  fetch_cycle= "000" then --direct
                        if src_or_dst='0' then
                            control_word <=  (Riout or F_A or TMP2in);
                            next_state <= fetch_op_state; --to fetch dst
                        else 
                            control_word <=  (Riout or F_A or TMP1in);
                            next_state <= execute_state;
                        end if;
                        --counter_rst <= '1';
                    elsif  fetch_cycle = "100" then --indirect register
                        control_word <= (Riout or MARin1 or Rd);
                    elsif  fetch_cycle = "101" then 
                        mem_out := true;
                    end if;
                elsif address_mode ="01" then -- auto_increment
                    if  fetch_cycle = "000" or fetch_cycle = "100" then
                        control_word <= (Riout or MARin1 or RD or F_Ap1 or Riin);
                    elsif  fetch_cycle = "101" then 
                        control_word <= (MDRout or F_A or MARin2 or Rd);
                    elsif  fetch_cycle = "001" or fetch_cycle = "101" then 
                        mem_out := true;        
                    end if;

                elsif address_mode = "10" then -- auto_decrement
                    if  fetch_cycle = "000" or fetch_cycle = "100" then 
                        control_word <= Riout or F_Am1 or MARin2 or Rd or Riin;
                    elsif  fetch_cycle = "101" then 
                        control_word <= MDRout or F_A or MARin2 or Rd;
                    elsif  fetch_cycle = "001" or fetch_cycle = "110" then 
                        mem_out := true;       
                    end if;

                elsif address_mode = "11"then -- indexed
                    if  fetch_cycle = "000" or fetch_cycle = "100" then 
                        control_word <= PCout or MARin1 or RD or F_Ap1 or PCin;
                    elsif  fetch_cycle = "001" or fetch_cycle = "101" then 
                        control_word <= MDRout or F_ApB or MARin2 or Rd;
                    elsif  fetch_cycle = "110" then 
                        control_word <= MDRout or F_A or MARin2 or Rd;
                    elsif  fetch_cycle = "010" or fetch_cycle = "111" then
                        mem_out := true;       
                    end if;
                end if;
        		if (mem_out) then
					 if src_or_dst ='0' then
                            control_word <= MDRout or F_A or TMP2in;
                            next_state <= fetch_op_state;
                        else 
                            control_word <= MDRout or F_A or TMP1in;
                            next_state <= execute_state;
                        end if;
                        --counter_rst <= '1';
                        mem_out := false;
				end if;    
	        end process;

	Riin_decoder : entity processor.decoder
    				generic map( Nsel =>3,Nout =>8 )
    				port map( enable => '1', A => Ri, F => Ri_decoded );
  
end architecture;
