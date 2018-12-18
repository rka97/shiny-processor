library ieee;
use ieee.std_logic_1164.all;
library processor;
use processor.p_constants.all;

entity ctrl_master is 
    port (
        clk	        : in std_logic;
        IR_data		: in std_logic_vector(15 downto 0);
        control_word: out std_logic_vector(31 downto 0) 
    );
end ctrl_master;

architecture mixed of ctrl_master is
    type state_type is (fetch_decode_st, fetch_op_st, execute_st, branch_st, jmp_st);
    signal counter_enable : std_logic := '1';
    signal counter_rst : std_logic := '0';
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
            enable => '1',
            count => count
        ); 

    comb : process(count, current_state)
    begin
        if current_state = "00" then  -- Fetch and Decode
            if count = "000" then        -- PCout, F=A, MARin, TMP1in, Rd
                counter_rst <= '0';
                control_word <= PCout or F_A or MARin or TMP1in or RD;
                next_state <= "00";
            elsif count = "001" then     -- F=A+1, PCin, WMFC
                control_word <= TMP1out or F_Ap1 or PCin;
                next_state <= "00";
            elsif count = "010" then     -- MDRout, F=A, IRin
                control_word <= MDRout or F_A or IRin;
                next_state <= "00";
                counter_rst <= '1';
            else
                next_state <= "00";
                counter_rst <= '1';
            end if;
        elsif current_state = "01" then -- Fetch Op
        elsif current_state = "10" then -- Execution
            -- Various Execution Phases
        end if;
    end process;
    
    sync_ps : process(clk)
    begin
        if rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
end mixed;