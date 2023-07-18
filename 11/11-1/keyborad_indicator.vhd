library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity keyborad_indicator is
    port(
        clk : in std_logic;
        rst : in std_logic;
        ps2_clk : in std_logic;
        ps2_data : in std_logic;
        leds : out std_logic_vector(9 downto 0);
        seg_0, seg_1 : out std_logic_vector(6 downto 0) -- seg_0: high / seg_1: low digit
    );
end entity;

architecture arch of keyborad_indicator is
    component ps2_keyboard_to_ascii is
        port(
            clk : in std_logic; -- System clock input
            ps2_clk : in std_logic; -- Clock signal from PS2 keyboard
            ps2_data : in std_logic; -- Data signal from PS2 keyboard
            ascii_new : out std_logic; -- Output flag indicating new ASCII value
            ascii_code : out std_logic_vector(6 downto 0) -- ASCII value
        );
    end component;
    
    component bcd7seg is
        port (
            bcd: in std_logic_vector(4 downto 0);
            display: out std_logic_vector(6 downto 0)
        );
    end component;
    
    signal ascii_new : std_logic;
    signal ascii_code : std_logic_vector(6 downto 0);
    signal bcd_0, bcd_1 : std_logic_vector(4 downto 0);
begin
    keyboard : ps2_keyboard_to_ascii
        port map(clk => clk, ps2_clk => ps2_clk, ps2_data => ps2_data, ascii_new => ascii_new, ascii_code => ascii_code);
    bcd7seg_0 : bcd7seg port map(bcd => bcd_0, display => seg_0);
    bcd7seg_1 : bcd7seg port map(bcd => bcd_1, display => seg_1);
    
    process(ascii_new)
        variable ascii_10 : integer;
    begin
        if rst = '0' then
            bcd_0 <= "11111";
            bcd_1 <= "11111";
            leds  <= "0000000000";
        elsif rising_edge(ascii_new) then
            ascii_10 := to_integer(unsigned(ascii_code));
            bcd_0 <= std_logic_vector(to_unsigned(ascii_10 / 16, bcd_0'length));
            bcd_1 <= std_logic_vector(to_unsigned(ascii_10 mod 16, bcd_1'length));
            case ascii_10 - 48 is
                when 0 => leds <= "0000000001";
                when 1 => leds <= "0000000010";
                when 2 => leds <= "0000000100";
                when 3 => leds <= "0000001000";
                when 4 => leds <= "0000010000";
                when 5 => leds <= "0000100000";
                when 6 => leds <= "0001000000";
                when 7 => leds <= "0010000000";
                when 8 => leds <= "0100000000";
                when 9 => leds <= "1000000000";
                when others => leds <= "0000000000";
            end case;
        end if;
    end process;
end architecture;