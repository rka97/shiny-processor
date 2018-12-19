library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
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
    
    type instr_cat is (two_op, one_op, branch, misc);
    signal instruction_category : instr_cat;
    signal instruction_two_op : std_logic_vector(3 downto 0) := (others => 'Z');
    signal addr_mode, used_reg : std_logic_vector(2 downto 0) := (others => 'Z');
    signal used_reg_decoded    : std_logic_vector(7 downto 0);
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
    
    used_reg_decoder_inst : entity processor.decoder
                generic map( Nsel =>3, Nout =>8 )
                port map( enable => '1', A => used_reg, F => used_reg_decoded );

    comb_IR_decoder : process(IR_data, current_state)
    begin
        instruction_category <= two_op when (IR_data(15 downto 12) > "0110") else
                                one_op when (IR_data(15 downto 12) = "0110") else
                                branch when (IR_data(15 downto 12) = "0101") else
                                misc;
        -- two-operand decoded instructions
        instruction_two_op <= IR_data(15 downto 12);
        -- src_addr_mode <= IR_data(11 downto 9);
        -- src_reg <= IR_data(8 downto 6);
        -- dst_addr_mode <= IR_data(5 downto 3);
        -- dst_reg <= IR_data(2 downto 0);
        addr_mode <= IR_data(11 downto 9) when current_state = "10" else IR_data(5 downto 3);
        used_reg <=  IR_data(8 downto 6) when current_state = "10" else IR_data(2 downto 0);
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
    variable fetch_cycle    : std_logic_vector(2 downto 0);
    variable Riin,Riout     : std_logic_vector(31 downto 0);
    variable sub_addr_mode  : std_logic_vector(1 downto 0);
    variable mem_out		: boolean;
    variable Ri_out_preinc, Rp1	: std_logic_vector(3 downto 0);
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
                next_state <= "11" when ((MDR_data(15 downto 14) = "00") or (MDR_data(15 downto 13) = "010")) else 
                              "01" when (MDR_data(15 downto 12) = "0110") else
                              "10";
                counter_rst <= '1';
            else -- Error state: we should never be here!
                next_state <= "00";
                counter_rst <= '1';
            end if;
        elsif current_state = "01" or current_state = "10" then -- Fetch Op
            fetch_cycle := addr_mode(2) & count(1 downto 0);
            Riin := (31 downto 21 => '0') & used_reg_decoded & (12 downto 0 => '0'); -- destination
            Ri_out_preinc := '0' & used_reg; -- 4-bt indicator of used registers
            Rp1 := std_logic_vector(to_unsigned(to_integer(unsigned( Ri_out_preinc )) + 1, 4));
            Riout := Rp1 & (27 downto 0 => '0'); -- source
            sub_addr_mode := addr_mode(1 downto 0); 
            if count = "000" then
                counter_rst <= '0';
            end if;
            if sub_addr_mode = "00" then  -- register
                if  fetch_cycle= "000" then --direct --if add_mode(2)='0' and count(1 downto 0)="00" then
                    if current_state="10" then--src
                        control_word <=  (Riout or F_A or TMP2in);
                        next_state <= "01"; --to fetch dst
                    elsif current_state="01" then --dst
                        control_word <=  (Riout or F_A or TMP1in);
                        next_state <= "11";
                    end if;
                    counter_rst <= '1';
                elsif  fetch_cycle = "100" then --indirect register --if add_mode(2)='1' and count(1 downto 0)="00" then
                    control_word <= (Riout or MARin1 or Rd or F_HI);
                elsif  fetch_cycle = "101" then --if add_mode(2)='1' and count(1 downto 0)="01" then
                    mem_out := true;
                end if;
            elsif sub_addr_mode ="01" then -- auto_increment
                if  fetch_cycle = "000" or fetch_cycle = "100" then --if (add_mode(2)='0' and count(1 downto 0)="00") or (add_mode(2)='1' and count(1 downto 0)="00") then
                    control_word <= (Riout or MARin1 or RD or F_Ap1 or Riin);
                elsif  fetch_cycle = "101" then 
                    control_word <= (MDRout or MARin1 or Rd or F_HI);
                elsif  fetch_cycle = "001" or fetch_cycle = "110" then 
                    mem_out := true;        
                end if;
            
            elsif sub_addr_mode = "10" then -- auto_decrement
                if  fetch_cycle = "000" or fetch_cycle = "100" then 
                    control_word <= Riout or F_Am1 or MARin or Rd or Riin;
                elsif  fetch_cycle = "101" then 
                    control_word <= MDRout or MARin1 or Rd or F_HI;
                elsif  fetch_cycle = "001" or fetch_cycle = "110" then 
                    mem_out := true;       
                end if;
            
            elsif sub_addr_mode = "11"then -- indexed
                if  fetch_cycle = "000" or fetch_cycle = "100" then 
                    control_word <= PCout or MARin1 or RD or F_Ap1 or PCin or TMP1in;
                elsif  fetch_cycle = "001" or fetch_cycle = "101" then 
                    control_word <= MDRout or F_ApB or MARin or Rd;
                elsif  fetch_cycle = "110" then 
                    control_word <= MDRout or MARin1 or Rd or F_HI;
                elsif  fetch_cycle = "010" or fetch_cycle = "111" then
                    mem_out := true;       
                end if;
            end if;
            
            if (mem_out) then
                 if current_state ="10" then--src
                        control_word <= MDRout or F_A or TMP2in;
                        next_state <= "01";
                    else --dst
                        control_word <= MDRout or F_A or TMP1in;
                        next_state <= "11";
                    end if;
                    counter_rst <= '1';
                    mem_out := false;
            end if;    
        elsif current_state = "11" then -- Execution
            if count = "000" then
                counter_rst <= '0';
            end if;
            -- Various Execution Phases
            if instruction_category = two_op then
            elsif instruction_category = one_op then
            elsif instruction_category = branch then
            elsif instruction_category = misc then
                if (instruction_misc= "0100") then -- JMP
                    if (count = "000") then
                        control_word <=  (JmpIROut or F_A or TMP2in);
                    elsif (count = "001") then
                        control_word <=  (SPout or F_Am1 or TMP1in or SPin or MARin2);
                    elsif (count = "010") then
                        control_word <=  (PCout or F_Ap1 or MDRin or WT);
                    elsif (count = "011") then
                        control_word <=  (TMP2out or F_A or PCin);
                        counter_rst <= '1';
                    end if;
                elsif (instruction_misc = "0011") then
                    if (misc_extra = '0') then -- RET
                        if (count = "000") then
                            control_word <=  SPout or F_A or MARin2 or TMP1in or RD;
                        elsif (count = "001") then
                            control_word <=  F_Ap1 or SPin;
                        elsif (count = "010") then
                            control_word <=  MDRout or F_A or PCin;
                            counter_rst <= '1';
                        end if;
                    elsif (misc_extra = '1') then -- HITR
                        if (count = "000" or count = "010") then
                            control_word <=  SPout or F_Am1 or SPin or MARin2;
                        elsif (count = "001") then
                            control_word <=  FLAGout or F_A or MDRin or WT;
                        elsif (count = "011") then
                            control_word <=  PCout or F_A or MDRin or WT;
                        elsif (count = "100") then
                            control_word <=  JmpIROut or F_A or PCin;
                            counter_rst <= '1';
                        end if;
                    end if;
                elsif (instruction_misc = "0010") then -- IRET
                        if (count = "000" or count = "011") then
                            control_word <=  SPout or MARin1 or RD or F_HI;
                        elsif (count = "001" or count = "100") then
                            control_word <=  SPout or F_Ap1 or SPin;
                        elsif (count = "010") then
                            control_word <=  MDRout or F_A or PCin;
                        elsif (count = "101") then
                            control_word <=  MDRout or F_A or FLAGin;
                            counter_rst <= '1';
                        end if;
                elsif (instruction_misc = "0001") then -- HLT
                    if (count = "000") then -- HLT
                        control_word <=  HLT or F_HI;
                        counter_rst <= '1';
                    end if;
                elsif (instruction_misc = "0000") then -- NoOp
                    if (count = "000") then 
                        control_word <=  NoOP or F_HI;
                        counter_rst <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    sync_ps : process(clk)
    begin
        if rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
end mixed;