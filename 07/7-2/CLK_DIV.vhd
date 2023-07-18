--
-- Generate 1kHz, 100Hz, 10Hz, and 1Hz clock signals
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity CLK_DIV is
	port (
		clock_50Mhz : in std_logic;
		clock_1KHz : out std_logic;
		clock_100Hz : out std_logic;
		clock_10Hz : out std_logic;
		clock_1Hz : out std_logic
	);
end CLK_DIV;

architecture arch of CLK_DIV is
	constant divisor : integer := 50000;
	signal count_1khz : integer range 0 to 25000 := 0;
	signal count_100hz, count_10hz, count_1hz : std_logic_vector(2 downto 0);
	signal CLK_1khz, CLK_100hz, CLK_10hz, CLK_1hz : std_logic;
begin
	clock_1KHz <= CLK_1khz;
	clock_100Hz <= CLK_100hz;
	clock_10Hz <= CLK_10hz;
	clock_1Hz <= CLK_1hz;

	-- Divide 50Mhz clock by 50000 => 1kHz
	process (clock_50Mhz)
	begin
		if clock_50Mhz'EVENT and clock_50Mhz = '1' then
			if count_1khz < divisor/2 then
				count_1khz <= count_1khz + 1;
			else
				count_1khz <= 0;
				CLK_1khz <= not CLK_1khz;
			end if;
		end if;
	end process;

	-- Divide by 10
	process (CLK_1khz)
	begin
		if CLK_1khz'EVENT and CLK_1khz = '1' then
			if count_100hz < 5 then
				count_100hz <= count_100hz + 1;
			else
				count_100hz <= "000";
				CLK_100hz <= not CLK_100hz;
			end if;
		end if;
	end process;

	-- Divide by 10
	process (CLK_100hz)
	begin
		if CLK_100hz'EVENT and CLK_100hz = '1' then
			if count_10hz < 5 then
				count_10hz <= count_10hz + 1;
			else
				count_10hz <= "000";
				CLK_10hz <= not CLK_10hz;
			end if;
		end if;
	end process;

	-- Divide by 10
	process (CLK_10hz)
	begin
		if CLK_10hz'EVENT and CLK_10hz = '1' then
			if count_1hz < 5 then
				count_1hz <= count_1hz + 1;
			else
				count_1hz <= "000";
				CLK_1hz <= not CLK_1hz;
			end if;
		end if;
	end process;
end arch;