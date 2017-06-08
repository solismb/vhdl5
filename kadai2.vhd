library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity kadai2 is
	port (
		clk : in std_logic;
		add, sub : in std_logic;
		--sw_in : in std_logic_vector(3 downto 0);
		seg_out : out std_logic_vector(6 downto 0));
end kadai2;

architecture rtl of kadai2 is
signal pushing1, pushed1 : std_logic;
signal pushing2, pushed2 : std_logic;
signal sw_in : std_logic_vector(3 downto 0);
component seg7
	port (
		data_in : in std_logic_vector(3 downto 0);
		led_out : out std_logic_vector(6 downto 0));
end component;

begin
	seg: seg7 port map(data_in => sw_in, led_out => seg_out);
	
	process (clk)
	begin
		if rising_edge(clk) then
			pushing1 <= not add;
			if pushing1 = '1' and pushed1 = '0' then
				sw_in <= sw_in + 1;
				pushed1 <= '1';
			elsif pushing1 = '0' and pushed1 = '1' then
				pushed1 <= '0';
			end if;
		end if;
		
		if rising_edge(clk) then
			pushing2 <= not sub;
			if pushing2 = '1' and pushed2 = '0' then
				sw_in <= sw_in - 1;
				pushed2 <= '1';
			elsif pushing2 = '0' and pushed2 = '1' then
				pushed2 <= '0';
			end if;
		end if;
	end process;
end rtl;