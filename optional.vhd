library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity optional is
	port (
		clk : in std_logic;
		sw1, sw2, sw3, sw_reset : in std_logic;
		led1, led2, led3 : out std_logic_vector(6 downto 0);
		led_out : out std_logic;  -- sorottara led ga hikarimasu
		lcdData : out std_logic_vector(7 downto 0);
		lcdRS : out std_logic;
		lcdRW : out std_logic;
		lcdON : out std_logic;
		lcdEN : out std_logic);
end optional;

architecture rtl of optional is
signal pushing1, pushing2, pushing3, pushing_r : std_logic;
signal pushed1, pushed2, pushed3, pushed_r : std_logic;
signal sw_in1 : std_logic_vector(3 downto 0);
signal sw_in2 : std_logic_vector(3 downto 0) := "0001";
signal sw_in3 : std_logic_vector(3 downto 0) := "0010";
signal interval : integer := 23;
signal counter : std_logic_vector(interval downto 0);
signal div_clk : std_logic;
signal isSpin1, isSpin2, isSpin3 : boolean := True;
signal data : std_logic_vector(319 downto 0);
type CHAR_RAM_TYPE is array(0 to 39) of std_logic_vector(7 downto 0);
shared variable charRAM : CHAR_RAM_TYPE := (others => x"A0");
signal isHit : boolean := False;

component seg7
	port (
		data_in : in std_logic_vector(3 downto 0);
		led_out : out std_logic_vector(6 downto 0));
end component;
component lcdio
	port (
		clk : in std_logic;
		charData : in std_logic_vector(319 downto 0);
		lcdData : out std_logic_vector(7 downto 0);
		lcdRS : out std_logic;
		lcdRW : out std_logic;
		lcdON : out std_logic;
		lcdEN : out std_logic);
end component;

begin
	seg1: seg7 port map(data_in => sw_in1, led_out => led1);
	seg2: seg7 port map(data_in => sw_in2, led_out => led2);
	seg3: seg7 port map(data_in => sw_in3, led_out => led3);
	
	div_clk <= counter(interval);
	
	process (clk)
	begin		
		if rising_edge(clk) then
			counter <= counter + 1;
		end if;
		
		if rising_edge(clk) then
			pushing1 <= not sw1;
			
			if pushing1 = '1' and pushed1 = '0' then
				--isSpin1 <= not isSpin1;
				isSpin1 <= False;
				pushed1 <= '1';
			elsif pushing1 = '0' and pushed1 = '1' then
				pushed1 <= '0';
			end if;
		end if;
		
		if rising_edge(clk) then
			pushing2 <= not sw2;
			
			if pushing2 = '1' and pushed2 = '0' then
				--isSpin2 <= not isSpin2;
				isSpin2 <= False;
				pushed2 <= '1';
			elsif pushing2 = '0' and pushed2 = '1' then
				pushed2 <= '0';
			end if;
		end if;
		
		if rising_edge(clk) then
			pushing3 <= not sw3;
			
			if pushing3 = '1' and pushed3 = '0' then
				--isSpin3 <= not isSpin3;
				isSpin3 <= False;
				pushed3 <= '1';
			elsif pushing3 = '0' and pushed3 = '1' then
				pushed3 <= '0';
			end if;
		end if;
		
		if rising_edge(clk) then
			pushing_r <= not sw_reset;
			
			if pushing_r = '1' and pushed_r = '0' then
				isSpin1 <= True;
				isSpin2 <= True;
				isSpin3 <= True;
				pushed_r <= '1';
			elsif pushing_r = '0' and pushed3 = '1' then
				pushed_r <= '0';
			end if;
			
		end if;
		
		if (isHit) then
			charRAM := (0=>x"B1", 1=>x"C0", 2=>x"D8", others=>x"A0");
		else
			charRAM := (others => x"A0");
		end if;
		
		for I in 0 to 39 loop
				data( (I*8)+7 downto I*8 ) <= charRAM(I);
		end loop;
		
	end process;
		
	process(div_clk)
	begin
		if rising_edge(div_clk) then
			if (isSpin1) then
				sw_in1 <= sw_in1 + 1;
			end if;
			
			if (isSpin2) then
				sw_in2 <= sw_in2 + 1;
			end if;
			
			if (isSpin3) then
				sw_in3 <= sw_in3 + 1;
			end if;
			
			if (sw_in1 = "1111") then
				sw_in1 <= "0000";
			end if;
			if (sw_in2 = "1111") then
				sw_in2 <= "0000";
			end if;
			if (sw_in3 = "1111") then
				sw_in3 <= "0000";
			end if;
			
			if ((sw_in1 = sw_in2) and (sw_in2 = sw_in3)) then
				if (not(isSpin1 or isSpin2 or isSpin3)) then
					led_out <= '1';
					isHit <= True;
				else
					led_out <= '0';
					isHit <= False;
				end if;
			else
				led_out <= '0';
				isHit <= False;
			end if;

		end if;
		
	end process;
	
	LCD : lcdio port map (
		clk => clk, charData => data, lcdData => lcdData,
		lcdRS => lcdRS, lcdRW => lcdRW, lcdON => lcdON, lcdEN => lcdEN);
		
end rtl;