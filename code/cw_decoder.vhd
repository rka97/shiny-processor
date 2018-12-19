-- A control word decoder
library ieee;
use ieee.std_logic_1164.all;
library processor;

entity cw_decoder is
    port (
        control_word    : in  std_logic_vector(31 downto 0);
        src_sel         : out std_logic_vector(13 downto 0);
        dst_sel         : out std_logic_vector(13 downto 0);
        alsu_sel        : out std_logic_vector(3 downto 0);
        cin_force       : out std_logic;
        br_offset_only  : out std_logic;
        mar_force_in    : out std_logic;
        mem_rd, mem_wr  : out std_logic;
        halt, nop       : out std_logic;
        force_flag      : out std_logic;
        src_en, dst_en  : out std_logic
    );
end cw_decoder;

architecture mixed of cw_decoder is
    signal decoded_src_sel : std_logic_vector(15 downto 0) := (others => 'Z');
begin
    decoder_inst_tb : entity processor.decoder
        generic map (
            Nsel => 4,
            Nout => 16
        )
        port map (
            enable => '1',
            A => control_word(31 downto 28),
            F => decoded_src_sel
        );
    src_sel <= decoded_src_sel(14 downto 1);
    src_en <= or control_word(31 downto 28);
    br_offset_only <= and control_word(31 downto 28);
    mar_force_in <= control_word(27);
    dst_sel <= control_word(26 downto 13);
    dst_en <= or control_word(26 downto 13);
    alsu_sel <= control_word(12 downto 9);
    cin_force <= control_word(8);
    mem_rd <= control_word(6);
    mem_wr <= control_word(5);
    halt <= control_word(4);
    nop <= control_word(3);
    force_flag <= control_word(2);
end mixed;