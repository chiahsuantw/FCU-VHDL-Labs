library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bcd_counter is
    port(
        clk : in std_logic;
        rst : in std_logic;
--        bcd_h_val, bcd_l_val : out std_logic_vector(3 downto 0);
        seg1, seg0 : out std_logic_vector(6 downto 0)
    );
end bcd_counter;

architecture arch of bcd_counter is
    component CLK_DIV
        port (
            clock_50Mhz : in std_logic;
            clock_1KHz : out std_logic;
            clock_100Hz : out std_logic;
            clock_10Hz : out std_logic;
            clock_1Hz : out std_logic
        );
    end component;

    component bcd7seg
        port (
            bcd : in std_logic_vector(3 downto 0);
            display : out std_logic_vector(6 downto 0)
        );
    end component;
    
    signal count_5hz : integer range 0 to 25000 := 0;
    signal clk_5hz : std_logic;
    signal bcd_h, bcd_l : std_logic_vector(3 downto 0);
    signal clk_1khz, clk_100hz, clk_10hz, clk_1hz : std_logic;
begin
    clk_div_0 : CLK_DIV port map(clk, clk_1khz, clk_100hz, clk_10hz, clk_1hz);
    
    process(clk) -- Divide 50MHz clock by 10M => 5Hz
	begin
		if clk'event and clk = '1' then
			if count_5hz < 5000000 then
				count_5hz <= count_5hz + 1;
			else
				count_5hz <= 0;
				clk_5hz <= not clk_5hz;
			end if;
		end if;
	end process;
    
    process(clk_10hz, rst) -- Count value from 0 to 99
        variable count : integer range 0 to 100;
        variable count_v : std_logic_vector(7 downto 0);
    begin
        if rst = '0' then
            count := 0;
        elsif clk_10hz'event and clk_10hz = '1' then
            count := count + 1;
            if count = 100 then
                count := 0;
            end if;
        end if;
        count_v := std_logic_vector(to_unsigned(count, 8));
        bcd_h <= std_logic_vector(resize(unsigned(count_v) / 10, 4));
        bcd_l <= std_logic_vector(resize(unsigned(count_v) mod 10, 4)); 
        
--        bcd_h_val <= bcd_h;
--        bcd_l_val <= bcd_l;
    end process;
    
    d1 : bcd7seg port map (bcd_h, seg1);
    d0 : bcd7seg port map (bcd_l, seg0);
end arch;