library ieee;
use ieee.std_logic_1164.all;
library processor;
use processor.p_constants.all;

entity cw_decoder_tb is
end cw_decoder_tb;

architecture behave of cw_decoder_tb is
    signal control_word : std_logic_vector(31 downto 0) := (others => 'Z');
    signal src_sel, dst_sel : std_logic_vector(13 downto 0) := (others => 'Z');
    signal alsu_sel : std_logic_vector(3 downto 0) := (others => 'Z');
    signal br_offset_only, mar_force_in, mem_rd, mem_wr, halt, nop, force_flag, src_en, dst_en : std_logic := 'Z';
    constant period : time := 1 ns;
begin
    cw_decoder_inst : entity processor.cw_decoder
        port map (
            control_word => control_word,
            src_sel => src_sel,
            dst_sel => dst_sel,
            alsu_sel => alsu_sel,
            br_offset_only => br_offset_only,
            mar_force_in => mar_force_in,
            mem_rd => mem_rd,
            mem_wr => mem_wr,
            halt => halt,
            nop => nop,
            force_flag => force_flag,
            src_en => src_en,
            dst_en => dst_en
        );
    
    process is
    begin
        control_word <= R0out or F_ApB or RD or WT or ForceFlag;
        wait for period;
        assert(src_sel(0) = '1') report "R0 was not selected!";
        assert(src_en = '1') report "Source Enable was not detected!";
        assert(alsu_sel = "0001") report "ALU selection was not done correctly!";
        assert(br_offset_only = '0') report "BR offset is needlessly high!";
        assert(mar_force_in = '0') report "MAR is forced without reason!";
        assert(mem_rd = '1') report "Memory Read bit isn't high!";
        assert(mem_wr = '1') report "Memory write bit isn't high!";
        assert(force_flag = '1') report "Flags force bit isn't high!";
        assert(dst_en = '0') report "Destination enable isn't low!";
        control_word <= R0in or BrIRout;
        wait for period;
        assert(br_offset_only = '1') report "Choosing address part of BR does not work.";
        assert(dst_sel(0) = '1') report "Destination is not correctly detected!";
        control_word <= NoOP or IRin;
        wait for period;
        assert(nop = '1') report "NOP wasn't detected!";
        assert(src_en = '0') report "Source Disable wasn't detected!";
        assert(dst_en = '1') report "Destination Enable wasn't detected!";
        wait for period;
    end process;
end behave;