library ieee;
use ieee.std_logic_1164.all;
library processor;
use processor.p_constants.all;

entity ctrl_master is 
    port (
        clk	        : in std_logic;
        MDR_data    : in std_logic_vector(15 downto 0); -- Maybe there's a better way than this?
        IR_data		: in std_logic_vector(15 downto 0);
        control_word: out std_logic_vector(31 downto 0) 
    );
end ctrl_master;

architecture mixed of ctrl_master is
    signal counter_enable : std_logic := '1';
    signal counter_rst : std_logic := '0';
    signal count : std_logic_vector(max_count_bits-1 downto 0);
    signal current_state : std_logic_vector(state_size-1 downto 0) := (others =>'0');
    signal next_state : std_logic_vector(state_size-1 downto 0) := (others =>'0');
    signal Ri_decoded : std_logic_vector(7 downto 0);
    
    type instr_cat is (two_op, one_op, branch, misc);
    signal instruction_category : instr_cat;
    signal instruction_two_op : std_logic_vector(3 downto 0) := (others => 'Z');
    signal src_addr_mode, dst_addr_mode, src_reg, dst_reg : std_logic_vector(2 downto 0) := (others => 'Z');
    signal instruction_one_op : std_logic_vector(3 downto 0) := (others => 'Z');
    signal instruction_branch : std_logic_vector(2 downto 0) := (others => 'Z');
    signal branching_offset   : std_logic_vector(15 downto 0) := (others => '0');
    signal instruction_misc   : std_logic_vector(3 downto 0) := (others => 'Z');
    signal misc_extra         : std_logic := 'Z';
    signal misc_jump_addr     : std_logic_vector(15 downto 0) := (others => '0');
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

    comb_IR_decoder : process(IR_data)
    begin
        instruction_category <= two_op when (IR_data(15 downto 12) > "0110") else
                                one_op when (IR_data(15 downto 12) = "0110") else
                                branch when (IR_data(15 downto 12) = "0101") else
                                misc;
        -- two-operand decoded instructions
        instruction_two_op <= IR_data(15 downto 12);
        src_addr_mode <= IR_data(11 downto 9);
        src_reg <= IR_data(8 downto 6);
        dst_addr_mode <= IR_data(5 downto 3);
        dst_reg <= IR_data(2 downto 0);
        -- one-operand decoded instructions
        instruction_one_op <= IR_data(11 downto 8);
        -- branching decoded instructions
        instruction_branch <= IR_data(11 downto 9);
        branching_offset(8 downto 0) <= IR_data(8 downto 0);  
        -- Misc decoded instructions
        instruction_misc <= IR_data(15 downto 12);
        misc_extra <= IR_data(11);
        misc_jump_addr(10 downto 0) <= IR_data(10 downto 0);
    end process;

    comb : process(count, current_state)
    begin
        if current_state = "00" then  -- Fetch Code Line
            if count = "000" then        -- PCout, F=A, MARin, TMP1in, Rd
                counter_rst <= '0';
                control_word <= PCout or F_A or MARin or TMP1in or RD;
                next_state <= "00";
            elsif count = "001" then     -- F=A+1, PCin, WMFC
                control_word <= TMP1out or F_Ap1 or PCin;
                next_state <= "00";
            elsif count = "010" then     -- MDRout, F=A, IRin
                control_word <= MDRout or F_A or IRin;
                -- Next State is Fetching if needed, otherwise execution right away!
                next_state <= "11" when ((MDR_data(15 downto 14) = "00") or (MDR_data(15 downto 13) = "010")) else "01";
                counter_rst <= '1';
            else -- Error state: we should never be here!
                next_state <= "00";
                counter_rst <= '1';
            end if;
        elsif current_state = "01" then -- Fetch Destination

        elsif current_state = "10" then -- Fetch Source

        elsif current_state = "11" then -- Execution
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