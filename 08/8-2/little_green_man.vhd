library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity little_green_man is
    port(
        clk : in std_logic;
        btn : in std_logic;
        GPIO_0 : out std_logic_vector(21 downto 9);
        GPIO_1 : out std_logic_vector(21 downto 9)
    );
end entity;

architecture arch of little_green_man is
    signal cnt1, cnt2 : integer range 0 to 50000 := 0;
    signal clk_1khz, clk_2hz : std_logic;
    
    type led_col_type is array (1 to 8) of std_logic_vector(1 to 8);
    signal led_8x8_map : led_col_type := (1 => "00111000",
                                          2 => "00110000",
                                          3 => "00011000",
                                          4 => "00011000",
                                          5 => "00011000",
                                          6 => "00001000",
                                          7 => "00010100",
                                          8 => "00010100");
    signal scan_line   : integer range 0 to 7;
    signal row, col    : std_logic_vector(1 to 8);
    signal display     : std_logic := '0'; -- Control if the animation is playing
begin
    -- Clock divider: 50 MHz -> 1 kHz for scanning led
    process(clk)
	begin
		if rising_edge(clk) then
			if cnt1 <  50000 / 2 then
				cnt1 <= cnt1 + 1;
			else
				cnt1 <= 0;
				clk_1khz <= not clk_1khz;
			end if;
		end if;
	end process;
    
    -- Clock divider: 1 kHz -> 2 Hz for updating frames
    process(clk_1khz)
	begin
		if rising_edge(clk_1khz) then
			if cnt2 <  1000 / 2 then
				cnt2 <= cnt2 + 1;
			else
				cnt2 <= 0;
				clk_2hz <= not clk_2hz;
			end if;
		end if;
	end process;
    
    -- Change frames by index
    process(clk_2hz)
        variable index : integer range 0 to 7;
    begin
        if rising_edge(clk_2hz) and display = '1' then
            case index is
                when 0 =>
                    led_8x8_map(1) <= "00111000";
                    led_8x8_map(2) <= "00110000";
                    led_8x8_map(3) <= "00011000";
                    led_8x8_map(4) <= "00011000";
                    led_8x8_map(5) <= "00011000";
                    led_8x8_map(6) <= "00001000";
                    led_8x8_map(7) <= "00010100";
                    led_8x8_map(8) <= "00010100";
                when 1 | 7 =>
                    led_8x8_map(1) <= "00111000";
                    led_8x8_map(2) <= "00110000";
                    led_8x8_map(3) <= "00011000";
                    led_8x8_map(4) <= "00011100";
                    led_8x8_map(5) <= "00111000";
                    led_8x8_map(6) <= "00010100";
                    led_8x8_map(7) <= "00010100";
                    led_8x8_map(8) <= "00100100";
                when 2 | 6 =>
                    led_8x8_map(1) <= "00111000";
                    led_8x8_map(2) <= "00110000";
                    led_8x8_map(3) <= "00011100";
                    led_8x8_map(4) <= "00111010";
                    led_8x8_map(5) <= "00001000";
                    led_8x8_map(6) <= "00010100";
                    led_8x8_map(7) <= "00100100";
                    led_8x8_map(8) <= "00100010";
                when 3 | 5 =>
                    led_8x8_map(1) <= "00111000";
                    led_8x8_map(2) <= "00110000";
                    led_8x8_map(3) <= "00011100";
                    led_8x8_map(4) <= "00111010";
                    led_8x8_map(5) <= "01001001";
                    led_8x8_map(6) <= "00010100";
                    led_8x8_map(7) <= "00100010";
                    led_8x8_map(8) <= "00100010";
                when 4 =>
                    led_8x8_map(1) <= "00111000";
                    led_8x8_map(2) <= "00110000";
                    led_8x8_map(3) <= "00011110";
                    led_8x8_map(4) <= "00111001";
                    led_8x8_map(5) <= "01001000";
                    led_8x8_map(6) <= "00010100";
                    led_8x8_map(7) <= "00100010";
                    led_8x8_map(8) <= "01000010";
                when others =>
                    led_8x8_map(1) <= "00000000";
                    led_8x8_map(2) <= "00000000";
                    led_8x8_map(3) <= "00000000";
                    led_8x8_map(4) <= "00000000";
                    led_8x8_map(5) <= "00000000";
                    led_8x8_map(6) <= "00000000";
                    led_8x8_map(7) <= "00000000";
                    led_8x8_map(8) <= "00000000";
            end case;
            
            -- Increase frame index
            index := index + 1;
            if index > 8 then
                index := 0;
            end if;
        end if;
    end process;
    
    -- Button control behavior: play/pause animation
    process(btn)
    begin
        if rising_edge(btn) then
            display <= not display;
        end if;
    end process;

    -- Led matrix line scanner
    process(clk_1khz)
	begin
        if rising_edge(clk_1khz) then
			if scan_line = 7 then 
				scan_line <= 0;
			else
				scan_line <= scan_line + 1;
			end if;
		end if;
	end process;

    -- Assign value to the led matrix
    with scan_line select
        row <= "01111111" when 0,
               "10111111" when 1,
               "11011111" when 2,
               "11101111" when 3,
               "11110111" when 4,
               "11111011" when 5,
               "11111101" when 6,
               "11111110" when 7,
               "11111111" when others;
    
    with scan_line select
        col <= led_8x8_map(1) when 0,
			   led_8x8_map(2) when 1,
			   led_8x8_map(3) when 2,
			   led_8x8_map(4) when 3,
			   led_8x8_map(5) when 4,
			   led_8x8_map(6) when 5,
			   led_8x8_map(7) when 6,
			   led_8x8_map(8) when 7,
			   "00000000" when others;
               
    -- Assign GPIO back-side
	GPIO_0(21) <= col(8);  GPIO_0(19) <= col(7);	GPIO_0(17) <= row(2); GPIO_0(15) <= col(1);
	GPIO_0(14) <= row(4);  GPIO_0(13) <= col(6);	GPIO_0(11) <= col(4); GPIO_0(9)  <= row(1);
 
    -- Assign GPIO front-side
	GPIO_1(21) <= row(5);  GPIO_1(19) <= row(7);	GPIO_1(17) <= col(2); GPIO_1(15) <= col(3);
	GPIO_1(14) <= row(8);  GPIO_1(13) <= col(5);	GPIO_1(11) <= row(6); GPIO_1(9)  <= row(3);
    
end architecture;