library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library processor;
use processor.p_constants.all;

entity ctrl_master is 
    port (
        clk, Zero, Cout, HW_ITR	 : in std_logic;
        MDR_data    : in std_logic_vector(15 downto 0); -- Maybe there's a better way than this?
        IR_data_in		: in std_logic_vector(15 downto 0);
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
    signal load_HWITR : std_logic := 'Z';
    signal new_HWITR, old_HWITR  : std_logic_vector(0 downto 0) := (others => '0');
    signal IR_data            : std_logic_vector(15 downto 0) := (others => 'Z');
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
    
        reg_inst : entity processor.reg
            generic map ( N => 1 )
            port map (
                clk => clk,
                enable => '1',
                load => load_HWITR,
                data_in => new_HWITR,
                data_out => old_HWITR
            );
    used_reg_decoder_inst : entity processor.decoder
                generic map( Nsel =>3, Nout =>8 )
                port map( enable => '1', A => used_reg, F => used_reg_decoded );

    interrupt_decoded : process(HW_ITR)
    begin
        if rising_edge(HW_ITR) then
            load_HWITR <= '1';
            new_HWITR(0) <= '1';
        else 
            load_HWITR <= 'Z';
            new_HWITR(0) <= 'Z';
        end if;
    end process;
                
    ir_choice : process(old_HWITR, IR_data_in, count, current_state)
    begin
        IR_data <= (15 downto 11 => "00111", others => '0') when (current_state = "100") else IR_data_in;
    end process;

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
        addr_mode <= IR_data(11 downto 9) when current_state = "010" else IR_data(5 downto 3);
        used_reg <=  IR_data(8 downto 6) when current_state = "010" else IR_data(2 downto 0);
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

    comb : process(count, current_state, used_reg, used_reg_decoded, addr_mode)
    variable fetch_cycle    : std_logic_vector(2 downto 0);
    variable Riin,Riout     : std_logic_vector(31 downto 0);
    variable sub_addr_mode  : std_logic_vector(1 downto 0);
    variable mem_out		: boolean;
    variable Ri_out_preinc, Rp1	: std_logic_vector(3 downto 0);
    variable Dst_in         : std_logic_vector(31 downto 0);
    variable valid_branch   : std_logic := '0';
    
    begin
        fetch_cycle := addr_mode(2) & count(1 downto 0);
        Riin := (31 downto 21 => '0') & used_reg_decoded & (12 downto 0 => '0'); -- destination
        Ri_out_preinc := '0' & used_reg; -- 4-bt indicator of used registers
        Rp1 := std_logic_vector(to_unsigned(to_integer(unsigned( Ri_out_preinc )) + 1, 4));
        Riout := Rp1 & (27 downto 0 => '0'); -- source
        Dst_in := Riin when addr_mode = "000" else (MDRin or WT); 
        sub_addr_mode := addr_mode(1 downto 0); 
        if current_state = "000" then  -- Fetch Code Line
            load_HWITR <= 'Z';
            new_HWITR(0) <= 'Z';
            if count = "000" then        -- PCout, F=A, MARin, TMP1in, Rd
                counter_rst <= '0';
                control_word <= PCout or MARin1 or F_Ap1 or PCin or RD;
                next_state <= "000";
            elsif count = "010" then     -- F=A+1, PCin, WMFC
                control_word <= TMP1out or F_Ap1 or PCin or RD;
                next_state <= "000";
            elsif count = "001" then     -- MDRout, F=A, IRin
                control_word <= MDRout or F_A or IRin;
                -- Next State is Fetching if needed, otherwise execution right away!
                next_state <= "011" when ((MDR_data(15 downto 14) = "00") or (MDR_data(15 downto 13) = "010")) else 
                            "001" when (MDR_data(15 downto 12) = "0110") else
                            "010";
                counter_rst <= '1';
            else -- Error state: we should never be here!
                next_state <= "000";
                counter_rst <= '1';
            end if;
        elsif current_state = "001" or current_state = "010" then -- Fetch Op
            if count = "000" then
                counter_rst <= '0';
            end if;
            if sub_addr_mode = "00" then  -- register
                if  fetch_cycle= "000" then --direct --if add_mode(2)='0' and count(1 downto 0)="00" then
                    if current_state = "010" then--src
                        control_word <=  (Riout or F_A or TMP2in);
                        next_state <= "001"; --to fetch dst
                    elsif current_state = "001" then --dst
                        control_word <=  (Riout or F_A or TMP1in);
                        next_state <= "011";
                    end if;
                    counter_rst <= '1';
                elsif  fetch_cycle = "100" then --indirect register --if add_mode(2)='1' and count(1 downto 0)="00" then
                    control_word <= (Riout or F_A or MARin or Rd);
                    next_state <= current_state;
                elsif  fetch_cycle = "101" then --if add_mode(2)='1' and count(1 downto 0)="01" then
                    mem_out := true;
                end if;
            elsif sub_addr_mode ="01" then -- auto_increment
                if  fetch_cycle = "000" or fetch_cycle = "100" then
                    control_word <= (Riout or MARin1 or RD or F_Ap1 or Riin);
                    next_state <= current_state;
                elsif  fetch_cycle = "101" then 
                    control_word <= (MDRout or F_A or MARin or Rd);
                    next_state <= current_state;
                elsif  fetch_cycle = "001" or fetch_cycle = "110" then 
                    mem_out := true;        
                end if;
            elsif sub_addr_mode = "10" then -- auto_decrement
                if  fetch_cycle = "000" or fetch_cycle = "100" then 
                    control_word <= Riout or F_Am1 or MARin or Rd or Riin;
                    next_state <= current_state;
                elsif  fetch_cycle = "101" then 
                    control_word <= MDRout or MARin1 or Rd or F_HI;
                    next_state <= current_state;
                elsif  fetch_cycle = "001" or fetch_cycle = "110" then 
                    mem_out := true;       
                end if;
            
            elsif sub_addr_mode = "11" then -- indexed
                if  fetch_cycle = "000" or fetch_cycle = "100" then 
                    control_word <= PCout or MARin1 or RD or F_Ap1 or PCin or TMP1in;
                    next_state <= current_state;
                elsif  fetch_cycle = "001" or fetch_cycle = "101" then 
                    control_word <= MDRout or F_ApB or MARin or Rd;
                    next_state <= current_state;
                elsif  fetch_cycle = "110" then 
                    control_word <= MDRout or MARin1 or Rd or F_HI;
                    next_state <= current_state;
                elsif  fetch_cycle = "010" or fetch_cycle = "111" then
                    mem_out := true;       
                end if;
            end if;
            
            if (mem_out) then
                if current_state = "010" then--src
                        control_word <= MDRout or F_A or TMP2in;
                        next_state <= "001";
                    else --dst
                        control_word <= MDRout or F_A or TMP1in;
                        next_state <= "011";
                    end if;
                    counter_rst <= '1';
                    mem_out := false;
            end if;    
        elsif current_state = "011" then -- Execution
            if count = "000" then
                counter_rst <= '0';
            end if;
            -- Various Execution Phases
            if instruction_category = two_op then
                if (count = "000") then
                    if instruction_two_op = "1111" then -- MOV
                        control_word <= TMP2out or F_A or Dst_in or ForceFlag;
                    elsif (instruction_two_op = x"E") then  -- ADD
                        control_word <= TMP2out or F_ApB or Dst_in or ForceFlag;
                    elsif (instruction_two_op = x"D") then -- ADC
                        control_word <= TMP2out or F_ApB or Dst_in or ForceFlag;
                    elsif (instruction_two_op = x"C") then -- SUB
                        control_word <= TMP2out or F_AmB or Dst_in or ForceFlag;
                    elsif (instruction_two_op = x"B") then -- SBC
                        control_word <= TMP2out or F_AmBm1 or Dst_in or ForceFlag;
                    elsif (instruction_two_op = x"A") then -- AND
                        control_word <= TMP2out or F_AandB or Dst_in or ForceFlag;
                    elsif (instruction_two_op = x"9") then -- OR
                        control_word <= TMP2out or F_AorB or Dst_in or ForceFlag;
                    elsif (instruction_two_op = x"8") then -- XNOR
                        control_word <= TMP2out or F_ApB or Dst_in or ForceFlag;
                    elsif (instruction_two_op = x"7") then -- Compare
                        control_word <= TMP2out or F_AmB or ForceFlag;
                    end if;
                    counter_rst <= '1';
                    next_state <= "000" when (old_HWITR(0) = '0') else "100";
                end if;
            elsif instruction_category = one_op then
                if (count = "000") then  
                    if instruction_one_op = "0000" then -- INC
                        control_word <= TMP1out or F_Ap1 or Dst_in or ForceFlag;
                    elsif instruction_one_op = "0001" then -- DEC
                        control_word <= TMP1out or F_Am1 or Dst_in or ForceFlag;
                    elsif instruction_one_op = "0010" then -- CLR
                        control_word <= TMP1out or F_Zero or Dst_in or ForceFlag;
                    elsif instruction_one_op = "0011" then -- INV
                        control_word <= TMP1out or F_notA or Dst_in or ForceFlag;
                    elsif instruction_one_op = "0100" then -- LSR
                        control_word <= TMP1out or F_LSR or Dst_in or ForceFlag;
                    elsif instruction_one_op = "0101" then -- ROR
                        control_word <= TMP1out or F_ROR or Dst_in or ForceFlag;
                    elsif instruction_one_op = "0110" then -- RRC
                        control_word <= TMP1out or F_RRC or Dst_in or ForceFlag;
                    elsif instruction_one_op = "0111" then -- ASR
                        control_word <= TMP1out or F_ASR or Dst_in or ForceFlag;
                    elsif instruction_one_op = "1000" then -- LSL
                        control_word <= TMP1out or F_LSL or Dst_in or ForceFlag;
                    elsif instruction_one_op = "1001" then -- ROL
                        control_word <= TMP1out or F_ROL or Dst_in or ForceFlag;
                    elsif instruction_one_op = "1010" then -- RLC
                        control_word <= TMP1out or F_RLC or Dst_in or ForceFlag;
                    end if;
                    counter_rst <= '1';
                    next_state <= "000" when (old_HWITR(0) = '0') else "100";
                end if;
            elsif instruction_category = branch then
                if (instruction_branch = "000") then --BR
                    valid_branch := '1';
                elsif (instruction_branch = "001" and Zero = '1') then --BEQ
                    valid_branch := '1';
                elsif (instruction_branch = "010" and Zero = '0') then --BNE
                    valid_branch := '1';
                elsif (instruction_branch = "011" and Cout = '0') then --BLO
                    valid_branch := '1';
                elsif (instruction_branch = "100" and (Cout = '0' or Zero = '1')) then --BLS
                    valid_branch := '1';
                elsif (instruction_branch = "101" and Cout = '1') then --BHI
                    valid_branch := '1';
                elsif (instruction_branch = "110" and (Cout = '1' or Zero = '1')) then --BHS
                    valid_branch := '1';
                else
                    valid_branch := '0';
                    control_word <= F_Hi;
                    next_state <= "000" when (old_HWITR(0) = '0') else "100";
                    counter_rst <= '1';
                end if;

                if (valid_branch = '1') then
                    if (count = "000") then
                        control_word <= PCout or F_A or TMP1in;
                        next_state <= current_state;
                    elsif (count = "001") then
                        control_word <= BrIRout or F_ApB or PCin;
                        valid_branch := '0';
                        counter_rst <= '1';
                        next_state <= "000" when (old_HWITR(0) = '0') else "100";
                    end if;
                end if;
            elsif instruction_category = misc then
                if (instruction_misc= "0100") then -- JSR
                    if (count = "000") then
                        control_word <=  (JmpIROut or F_A or TMP2in);
                    elsif (count = "001") then
                        control_word <=  (SPout or F_Am1 or TMP1in or SPin or MARin);
                    elsif (count = "010") then
                        control_word <=  (PCout or F_Ap1 or MDRin or WT);
                    elsif (count = "011") then
                        control_word <=  (TMP2out or F_A or PCin);
                        next_state <= "000" when (old_HWITR(0) = '0') else "100";
                        counter_rst <= '1';
                    end if;
                elsif (instruction_misc = "0011") then
                    if (misc_extra = '0') then -- RET
                        if (count = "000") then
                            control_word <=  SPout or F_A or MARin or TMP1in or RD;
                        elsif (count = "001") then
                            control_word <=  TMP1out or F_Ap1 or SPin;
                        elsif (count = "010") then
                            control_word <=  MDRout or F_A or PCin;
                            next_state <= "000" when (old_HWITR(0) = '0') else "100";
                            counter_rst <= '1';
                        end if;
                    elsif (misc_extra = '1') then -- HITR
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
                            next_state <= "000";
                            counter_rst <= '1';
                        end if;
                elsif (instruction_misc = "0001") then -- HLT
                    if (count = "000") then -- HLT
                        control_word <=  PCout or F_Am1 or PCin;
                        next_state <= "000" when (old_HWITR(0) = '0') else "100";
                        counter_rst <= '1';
                    end if;
                elsif (instruction_misc = "0000") then -- NoOp
                    if (count = "000") then 
                        control_word <=  NoOP or F_HI;
                        next_state <= "000" when (old_HWITR(0) = '0') else "100";
                        counter_rst <= '1';
                    end if;
                end if;
            end if;
        elsif current_state = "100" then
            if count = "000" then
                counter_rst <= '0';
            end if;
            if (count = "000" or count = "010") then
                control_word <=  SPout or F_Am1 or SPin or MARin;
                next_state <= current_state;
            elsif (count = "001") then
                control_word <=  FLAGout or F_A or MDRin or WT;
                next_state <= current_state;
            elsif (count = "011") then
                control_word <=  PCout or F_A or MDRin or WT;
                next_state <= current_state;
            elsif (count = "100") then
                control_word <=  HITROut or F_A or PCin;
                next_state <= "000";
                counter_rst <= '1';
                load_HWITR <= '1';
                new_HWITR(0) <= '0';
            end if;
        end if;
    end process;
    
    sync_ps : process(clk)
    begin
        if falling_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
end mixed;