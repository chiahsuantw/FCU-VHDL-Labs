library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyborad_led_rotate is
    port(
        clk : in std_logic;
        rst : in std_logic;
        ps2_clk : in std_logic;
        ps2_data : in std_logic;
        leds : out std_logic_vector(7 downto 0)
    );
end entity;

architecture arch of keyborad_led_rotate is
    component ps2_keyboard_to_ascii is
        port(
            clk : in std_logic; -- System clock input
            ps2_clk : in std_logic; -- Clock signal from PS2 keyboard
            ps2_data : in std_logic; -- Data signal from PS2 keyboard
            ascii_new : out std_logic; -- Output flag indicating new ASCII value
            ascii_code : out std_logic_vector(6 downto 0) -- ASCII value
        );
    end component;
    
    signal ascii_new : std_logic;
    signal ascii_code : std_logic_vector(6 downto 0);
begin
    keyboard : ps2_keyboard_to_ascii
        port map(clk => clk, ps2_clk => ps2_clk, ps2_data => ps2_data, ascii_new => ascii_new, ascii_code => ascii_code);
    
    process(ascii_new, rst)
        variable leds_temp : std_logic_vector(7 downto 0) := "10000000";
    begin
        if rst = '0' then
            leds_temp := "00000000";
        elsif rising_edge(ascii_new) then
            case to_integer(unsigned(ascii_code)) - 48 is
                when 0 =>
                    if leds_temp = "00000000" then
                        leds_temp := "00000001";
                    else
                        leds_temp := leds_temp(leds_temp'high - 1 downto 0) & leds_temp(leds_temp'high); -- Rotate left
                    end if;
                when 1 =>
                    if leds_temp = "00000000" then
                        leds_temp := "10000000";
                    else
                        leds_temp := leds_temp(leds_temp'low) & leds_temp(leds_temp'high downto leds_temp'low + 1); -- Rotate right
                    end if;
                when others =>
                    leds_temp := "00000000";
            end case;
        end if;
        leds <= leds_temp;
    end process;
end architecture;