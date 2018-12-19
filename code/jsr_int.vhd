library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library processor;
Use processor.p_constants.ALL;
entity jsr_int is
generic (n: integer := 32);
    port (
	ir: in std_logic_vector (15 downto 0);
	op : out std_logic_vector (n-1 downto 0);
	clk,rst,enable : in std_logic;
	count : in std_logic_vector (3 downto 0)
	);
end entity jsr_int;
architecture mixed of jsr_int is
--type state_type is (a, b,c,d,e,f); --std_logic_vector(n-1 DOWNTO 0);
--signal current_s, next_s: state_type;
--signal count: std_logic_vector (3 downto 0);
begin

--process(clk, rst)
--begin
--        if (rst = '1') then
--            current_s <= (others => '0');
--        elsif (rising_edge(clk)) then
--            current_s <= next_s;
--        end if;
--end process;

process (ir,count)
begin
if (ir(15 downto 12 )= "0100")then
	--when  =>
	--if(IRout(n-1 downto 12) = )  --jsr
		if (count = "0000") then
			op <= (BrIRout or F_A or TMP2in);
		elsif (count = "0001") then
			op <= (SPout or F_Am1 or TMP1in or SPin or MARin2);
		elsif (count = "0010") then
			op <= (PCout or F_Ap1 or MDRin or WT);
		elsif (count = "0011")then
			op <= (TMP2out or F_A or PCin);
			--count <= "0000";
		end if;
elsif (ir(15 downto 12) = "0011")then
	--when "0011" =>
	--if(IRout(n-1 downto 12) = )  --ret or hitr
	if (ir(11) = '0') then
		if (count = "0000") then
			op <= SPout or F_A or MARin2 or TMP1in or RD;
		elsif (count = "0001") then
			op <= F_Ap1 or SPin;
		elsif (count = "0010") then
			op <= MDRout or F_A or PCin;
			--count <= "0000";
		end if;
	elsif (ir(11) = '1') then
		if (count = "0000" or count = "0010") then
			op <= SPout or F_Am1 or SPin or MARin2;
		elsif (count = "0001") then
			op <= FLAGout or F_A or MDRin or WT;
		elsif (count = "0011") then
			op <= PCout or F_A or MDRin or WT;
		elsif (count = "0100") then
			op <= BrIRout or F_A or PCin;
			--count <= "0000";
		end if;
	end if;
elsif (ir(15 downto 12) = "0010")then
	--when "0010" =>
	--if(IRout(n-1 downto 12) = )  --iret
		if (count = "0000" or count = "0011") then
			op <= SPout or MARin1 or RD;
		elsif (count = "0001" or count = "0100") then
			op <= SPout or F_Ap1 or SPin;
		elsif (count = "0010") then
			op <= MDRout or F_A or PCin;
		elsif (count = "0101") then
			op<= MDRout or F_A or FLAGin;
			--count <= "0000";
		end if;
elsif (ir(15 downto 12) = "0001")then
	--when "0001" =>
	--if(IRout(n-1 downto 12) = )  --hlt
		if (count = "0000") then
			op <= HLT;
			--count <= "0000";
		end if;
elsif (ir(15 downto 12) = "0000")then
	--when "0000" =>
	--if(IRout(n-1 downto 12) = )  --nop
		if (count = "0000") then
			op <= NoOP;
			--count <= "0000";
		end if;
end if;
end process;
--counter: entity processor.counter
--generic map(n => 4)
--port map(
--	clk => clk, rst => rst, enable =>enable,
--	count => count);
end mixed;