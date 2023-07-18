library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity led_8x8_dice is
    port(
        clk : in std_logic;
        rst : in std_logic;
        btn : in std_logic;
        GPIO_0 : out std_logic_vector(21 downto 9);
        GPIO_1 : out std_logic_vector(21 downto 9)
    );
end entity;

architecture arch of led_8x8_dice is
    type led_col_type is array (1 to 8) of std_logic_vector(1 to 8);
    constant divisor   : integer := 50000;
    signal counter     : integer range 0 to 50000 := 0;
    signal clk_1hz     : std_logic;
    signal rand        : std_logic_vector(2 downto 0);
    signal scan_line   : integer range 0 to 7;
    signal row, col    : std_logic_vector(1 to 8);
    signal led_8x8_map : led_col_type;
begin
    -- Clock divider -> 1 Hz
    process(clk)
	begin
		if rising_edge(clk) then
			if counter <  divisor / 2 then
				counter <= counter + 1;
			else
				counter <= 0;
				clk_1hz <= not clk_1hz;
			end if;
		end if;
	end process;
    
    -- LFSR random number generator
    process(clk_1hz)
        variable feedback : std_logic;
    begin
        if rst = '0' then
            rand <= "100";
        elsif rising_edge(clk_1hz) then
            feedback := rand(0) xor rand(1);
            rand <= feedback & rand(2 downto 1);
        end if;
    end process;
    
    -- Led matrix line scanner
    process(clk_1hz, rst)
	begin
		if rst = '0' then
			scan_line <= 0;
		elsif rising_edge(clk_1hz) then
			if scan_line = 7 then 
				scan_line <= 0;
			else
				scan_line <= scan_line + 1;
			end if;
		end if;
	end process;
    
    process(btn, rst)
    begin
        if rst = '0' then
            led_8x8_map(1) <= "00000000";
            led_8x8_map(2) <= "00000000";
            led_8x8_map(3) <= "00000000";
            led_8x8_map(4) <= "00000000";
            led_8x8_map(5) <= "00000000";
            led_8x8_map(6) <= "00000000";
            led_8x8_map(7) <= "00000000";
            led_8x8_map(8) <= "00000000";
        elsif falling_edge(btn) then
            case to_integer(unsigned(rand) mod 6) is
                when 0 =>
                    led_8x8_map(1) <= "00000000";
                    led_8x8_map(2) <= "00000000";
                    led_8x8_map(3) <= "00000000";
                    led_8x8_map(4) <= "00011000";
                    led_8x8_map(5) <= "00011000";
                    led_8x8_map(6) <= "00000000";
                    led_8x8_map(7) <= "00000000";
                    led_8x8_map(8) <= "00000000";
                when 1 =>
                    led_8x8_map(1) <= "00000000";
                    led_8x8_map(2) <= "01100000";
                    led_8x8_map(3) <= "01100000";
                    led_8x8_map(4) <= "00000000";
                    led_8x8_map(5) <= "00000000";
                    led_8x8_map(6) <= "00000110";
                    led_8x8_map(7) <= "00000110";
                    led_8x8_map(8) <= "00000000";
                when 2 =>
                    led_8x8_map(1) <= "00000000";
                    led_8x8_map(2) <= "01100000";
                    led_8x8_map(3) <= "01100000";
                    led_8x8_map(4) <= "00011000";
                    led_8x8_map(5) <= "00011000";
                    led_8x8_map(6) <= "00000110";
                    led_8x8_map(7) <= "00000110";
                    led_8x8_map(8) <= "00000000";
                when 3 =>
                    led_8x8_map(1) <= "01100110";
                    led_8x8_map(2) <= "01100110";
                    led_8x8_map(3) <= "00000000";
                    led_8x8_map(4) <= "00000000";
                    led_8x8_map(5) <= "00000000";
                    led_8x8_map(6) <= "00000000";
                    led_8x8_map(7) <= "01100110";
                    led_8x8_map(8) <= "01100110";
                when 4 =>
                    led_8x8_map(1) <= "01100110";
                    led_8x8_map(2) <= "01100110";
                    led_8x8_map(3) <= "00000000";
                    led_8x8_map(4) <= "00011000";
                    led_8x8_map(5) <= "00011000";
                    led_8x8_map(6) <= "00000000";
                    led_8x8_map(7) <= "01100110";
                    led_8x8_map(8) <= "01100110";
                when 5 =>
                    led_8x8_map(1) <= "01100110";
                    led_8x8_map(2) <= "01100110";
                    led_8x8_map(3) <= "00000000";
                    led_8x8_map(4) <= "01100110";
                    led_8x8_map(5) <= "01100110";
                    led_8x8_map(6) <= "00000000";
                    led_8x8_map(7) <= "01100110";
                    led_8x8_map(8) <= "01100110";
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
        end if;
    end process;
    
    -- Display
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
               
    -- GPIO Back-side
	GPIO_0(21) <= col(8);  GPIO_0(19) <= col(7);	GPIO_0(17) <= row(2); GPIO_0(15) <= col(1);
	GPIO_0(14) <= row(4);  GPIO_0(13) <= col(6);	GPIO_0(11) <= col(4); GPIO_0(9)  <= row(1);
 
    -- GPIO Front-side	
	GPIO_1(21) <= row(5);  GPIO_1(19) <= row(7);	GPIO_1(17) <= col(2); GPIO_1(15) <= col(3);
	GPIO_1(14) <= row(8);  GPIO_1(13) <= col(5);	GPIO_1(11) <= row(6); GPIO_1(9)  <= row(3);

end architecture;