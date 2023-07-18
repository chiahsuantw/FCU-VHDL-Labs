library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_counter is
    port(
        clk : in std_logic;
        rst : in std_logic;
        leds : out std_logic_vector(7 downto 0)
    );
end led_counter;

architecture arch of led_counter is
    component CLK_DIV
        port (
            clock_50Mhz : in std_logic;
            clock_1KHz : out std_logic;
            clock_100Hz : out std_logic;
            clock_10Hz : out std_logic;
            clock_1Hz : out std_logic
        );
    end component;
    
    signal clk_1khz, clk_100hz, clk_10hz, clk_1hz : std_logic;
begin
    clk_div_0 : CLK_DIV port map(clk, clk_1khz, clk_100hz, clk_10hz, clk_1hz);
    
    process(clk_1hz, rst)
        variable leds_local : std_logic_vector(7 downto 0);
    begin
        if rst = '0' then
            leds_local := "00000001";
        elsif clk_1hz'event and clk_1hz='1' then
            -- Shift left 1 bit
            leds_local := std_logic_vector(shift_left(unsigned(leds_local), 1));
            
            if leds_local = "00000000" then
                leds_local := "00000001";
            end if;
        end if;
        leds <= leds_local;
    end process;
end arch;