library ieee;
use ieee.std_logic_1164.all;
library processor;
use processor.p_constants.all;

entity ctrl_master is 
    constant state_size : integer := 2;
    constant max_count_bits : integer := 3;
    port (
        clk,enable	: in std_logic; --enable can be ='1' we klas
        state		: out std_logic_vector(state_size-1 downto 0);
        IR_data		: in std_logic_vector(15 downto 0);
        control_word: out std_logic_vector(31 downto 0) 
    );
end ctrl_master;

architecture mixed of ctrl_master is
    type state_type is (fetch_decode_st, fetch_op_st, execute_st, branch_st, jmp_st);
    signal counter_enable, counter_rst : std_logic := '0';
    signal count : std_logic_vector(max_count_bits-1 downto 0);
    signal current_state : std_logic_vector(state_size-1 downto 0) := (others =>'0');
    signal next_state : std_logic_vector(state_size-1 downto 0) := (others =>'0');
    signal initial_state : state_type := fetch_op_st;
    signal Ri_decoded : std_logic_vector(7 downto 0);
begin
    counter_inst : entity processor.counter
        generic map (
            max_nbits => max_count_bits
        )
        port map (
            clk => clk,
            rst => counter_rst,
            enable => enable,
            count => count
        ); 

    comb : process(clk)
    begin
        if current_state = "00" then  -- Fetch and Decode
            if count = "00" then        -- PCout, F=A, MARin, TMP1in, Rd
                ctrl_rst <= '0';
                control_word <= PCout or F_A or MARin or TMP1in or RD;
                next_state <= "00";
            elsif count = "01" then     -- F=A+1, PCin, WMFC
                control_word <= F_Ap1 or PCin;
                next_state <= "00";
            elsif count = "10" then     -- MDRout, F=A, IRin
                control_word <= MDRout or F_A or IRin;
                next_state <= "01";
                rst <= '1';
            end if;
        elsif current_state = "01" then -- Fetch Op
            -- Fetch Op here
            if address_mode = "00" then  -- register
                if  fetch_cycle= "000" then --direct
                    if src_or_dst='0' then
                        control_word <=  (Riout or F_A or TMP2in);
                        next_st <= fetch_op_st; --to fetch dst
                    else 
                        control_word <=  (Riout or F_A or TMP1in);
                        next_st <= execute_st;
                    end if;
                    rst <= '1';
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
                    control_word <= MDRout or F_A or MARin2 or Rd;--can me => MDRout or MARin1 or Rd "TB"
                elsif  fetch_cycle = "010" or fetch_cycle = "111" then
                    mem_out := true;       
                end if;
            end if;
            if (mem_out) then
                if src_or_dst ='0' then
                        control_word <= MDRout or F_A or TMP2in;
                        next_st <= fetch_op_st;
                    else 
                        control_word <= MDRout or F_A or TMP1in;
                        next_st <= execute_st;
                    end if;
                    rst <= '1';
                    mem_out := false;
            end if;    
        elsif current_state = "10" then -- Execution
            -- Various Execution Phases
        end if;
    end process;
    
    sync_ps : process(clk)
    begin
        if rising_edge(clk) then
            current_state <= next_state;
            state <= current_state;
        end if;
    end process;
end mixed;