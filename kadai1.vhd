library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity kadai1 is
	port (
		clk : in std_logic;
		led_out : out std_logic_vector(2 downto 0));
end kadai1;

architecture rtl of kadai1 is
constant interval : integer := 24;
signal counter : std_logic_vector(interval downto 0);
signal div_clk : std_logic;
signal light : std_logic_vector(2 downto 0);

begin
	div_clk <= counter(interval);

	process (clk)
	begin
		if rising_edge(clk) then
			counter <= counter + 1;
		end if;
	end process;

	process (div_clk)
	begin
		if rising_edge(div_clk) then
			light <= light + 1;
			led_out <= light;
			if (light = "111") then
				light <= "000";
			end if;
		end if;
	end process;
end rtl;