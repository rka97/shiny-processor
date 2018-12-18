library ieee;
use ieee.std_logic_1164.all;
library processor;
use processor.p_constants.all;

entity ctrl_master is 
    constant state_size : integer := 2;
    constant max_count_bits : integer := 3;
    port (
        clk          : in std_logic;
        state        : out std_logic_vector(state_size-1 downto 0);
        IR_data      : in std_logic_vector(31 downto 0);
        control_word : out std_logic_vector(31 downto 0) 
    );
end ctrl_master;

architecture mixed of ctrl_master is
    signal counter_enable, counter_rst : std_logic := '0';
    signal count : std_logic_vector(max_count_bits-1 downto 0);
    signal current_state : std_logic_vector(state_size-1 downto 0) := '0';
    signal next_state : std_logic_vector(state_size-1 downto 0) := '0';
begin
    counter_inst : entity processor.counter
        generic map (
            max_nbits => max_count_bits
        )
        port map (
            clk => clk,
            rst => rst,
            enable => enable,
            count => count
        );

    comb : process(clk)
    begin
        if current_state = "00" then  -- Fetch and Decode
            if count = "00" then        -- PCout, F=A, MARin, TMP1in, Rd
                rst <= '0';
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