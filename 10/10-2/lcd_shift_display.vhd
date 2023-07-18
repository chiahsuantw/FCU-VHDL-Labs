library ieee;
use ieee.std_logic_1164.all;

entity lcd_shift_display is
    port(
        clk, show, rst : in std_logic;
        GPIO_0, GPIO_1 : out std_logic_vector(21 downto 9)
    );
end entity;

architecture arch of lcd_shift_display is
    signal clk_cnt_1k, clk_cnt_500, clk_cnt_1 : integer := 0;
    signal clk_1khz, clk_500hz, clk_1hz : std_logic;

    type DDRAM is array(0 to 15) of std_logic_vector(7 downto 0);
    signal LINE_1 : DDRAM := (0  => "01000100", -- Init values
                              1  => "00110001",
                              2  => "00110000",
                              3  => "00110001",
                              4  => "00110100",
                              5  => "00111001",
                              6  => "00111001",
                              7  => "00110011",
                              8  => "00100000",
                              9  => "00100000",
                              10 => "00100000",
                              11 => "00100000",
                              12 => "00100000",
                              13 => "00100000",
                              14 => "00100000",
                              15 => "00100000");
    signal LINE_2 : DDRAM;
    signal LCM_RS, LCM_RW, LCM_EN : std_logic;
    signal LCM_DB, TEMP : std_logic_vector(7 downto 0);
    -- ANI_CNT: Shift counter (0~7: shift right / 8~15: shift left / >15: reset to zero)
    signal COUNTER, ANI_CNT : integer range 0 to 41;
begin
    -- Clock dividers
    process(clk) -- 50MHz -> 1kHz
    begin
		if rising_edge(clk) then
			if clk_cnt_1k <  50000 / 2 then
				clk_cnt_1k <= clk_cnt_1k + 1;
			else
				clk_cnt_1k <= 0;
				clk_1khz <= not clk_1khz;
			end if;
		end if;
    end process;
     
    process(clk) -- 50MHz -> 500Hz
    begin
		if rising_edge(clk) then
			if clk_cnt_500 <  100000 / 2 then
				clk_cnt_500 <= clk_cnt_500 + 1;
			else
				clk_cnt_500 <= 0;
				clk_500hz <= not clk_500hz;
			end if;
		end if;
    end process;
    
    process(clk) -- 50MHz -> 1Hz
    begin
		if rising_edge(clk) then
			if clk_cnt_1 <  50000000 / 2 then
				clk_cnt_1 <= clk_cnt_1 + 1;
			else
				clk_cnt_1 <= 0;
				clk_1hz <= not clk_1hz;
			end if;
		end if;
    end process;
    
    LCM_EN <= clk_500hz;
    
    -- Shift contents
    process(clk_1hz, rst)
    begin
        if rst = '0' then -- Clear
            for i in 0 to 15 loop
                LINE_1(i) <= "00100000";
                LINE_2(i) <= "00100000";
            end loop;
        elsif show = '0' then
            LINE_1(0)  <= "01000100"; -- D
            LINE_1(1)  <= "00110001"; -- 1
            LINE_1(2)  <= "00110000"; -- 0
            LINE_1(3)  <= "00110001"; -- 1
            LINE_1(4)  <= "00110100"; -- 4
            LINE_1(5)  <= "00111001"; -- 9
            LINE_1(6)  <= "00111001"; -- 9
            LINE_1(7)  <= "00110011"; -- 3
            LINE_1(8)  <= "00100000"; --
            LINE_1(9)  <= "00100000"; --
            LINE_1(10) <= "00100000"; --
            LINE_1(11) <= "00100000"; --
            LINE_1(12) <= "00100000"; --
            LINE_1(13) <= "00100000"; --
            LINE_1(14) <= "00100000"; --
            LINE_1(15) <= "00100000"; --
			ANI_CNT <= 0;
        elsif rising_edge(clk_1hz) then
            if ANI_CNT < 8  then -- Shift right
                TEMP <= LINE_1(15);
                for i in 14 downto 0 loop
                    LINE_1(i + 1) <= LINE_1(i);
                end loop;
                LINE_1(0) <= TEMP;
            elsif ANI_CNT < 16 then -- Shift left
                TEMP <= LINE_1(0);
                for i in 14 downto 0 loop
                    LINE_1(i) <= LINE_1(i + 1);
                end loop;
                LINE_1(15) <= TEMP;
            else
                ANI_CNT <= 0;
            end if;
			
            ANI_CNT <= ANI_CNT + 1;
            
            if ANI_CNT >= 16 then 
                ANI_CNT <= 0;
            end if;		
        end if;
    end process;
    
    -- Line scanner
    process(clk_500hz, rst)
    begin
        if rst = '0' then
            COUNTER <= 0;
        elsif rising_edge(clk_500hz) then
            if COUNTER >= 41 then
                COUNTER <= 8;
            else
                COUNTER <= COUNTER + 1;
            end if;
        end if;
    end process;
    
    -- Display circuit
    process (clk_500hz, rst)
    begin
        if rising_edge(clk_500hz) then
            case COUNTER is
                when 0 to 3 =>
                    LCM_RS <= '0';
                    LCM_RW <= '0';
                    LCM_DB <= "00111000"; -- Function set
                when 4 =>
                    LCM_DB <= "00001000"; -- Screen off
                when 5 =>
                    LCM_DB <= "00000001"; -- Clear screen
                when 6 =>
                    LCM_DB <= "00001100"; -- Screen on
                when 7 =>
                    LCM_DB <= "00000110"; -- Entry mode set
                when 8 =>
                    LCM_RS <= '0';
                    LCM_DB <= "10000000"; -- Set position for LINE 1
                when 9 =>
                    LCM_RS <= '1';
                    LCM_DB <= LINE_1(0);
                when 10 =>
                    LCM_DB <= LINE_1(1);
                when 11 =>
                    LCM_DB <= LINE_1(2);
                when 12 =>
                    LCM_DB <= LINE_1(3);
                when 13 =>
                    LCM_DB <= LINE_1(4);
                when 14 =>
                    LCM_DB <= LINE_1(5);
                when 15 =>
                    LCM_DB <= LINE_1(6);
                when 16 =>
                    LCM_DB <= LINE_1(7);
                when 17 =>
                    LCM_DB <= LINE_1(8);
                when 18 =>
                    LCM_DB <= LINE_1(9);
                when 19 =>
                    LCM_DB <= LINE_1(10);
                when 20 =>
                    LCM_DB <= LINE_1(11);
                when 21 =>
                    LCM_DB <= LINE_1(12);
                when 22 =>
                    LCM_DB <= LINE_1(13);
                when 23 =>
                    LCM_DB <= LINE_1(14);
                when 24 =>
                    LCM_DB <= LINE_1(15);
                when 25 =>
                    LCM_RS <= '0';
                    LCM_DB <= "11000000"; -- Set position fpr LINE 2
                when 26 =>
                    LCM_RS <= '1';
                    LCM_DB <= LINE_2(0);
                when 27 =>
                    LCM_DB <= LINE_2(1);
                when 28 =>
                    LCM_DB <= LINE_2(2);
                when 29 =>
                    LCM_DB <= LINE_2(3);
                when 30 =>
                    LCM_DB <= LINE_2(4);
                when 31 =>
                    LCM_DB <= LINE_2(5);
                when 32 =>
                    LCM_DB <= LINE_2(6);
                when 33 =>
                    LCM_DB <= LINE_2(7);
                when 34 =>
                    LCM_DB <= LINE_2(8);
                when 35 =>
                    LCM_DB <= LINE_2(9);
                when 36 =>
                    LCM_DB <= LINE_2(10);
                when 37 =>
                    LCM_DB <= LINE_2(11);
                when 38 =>
                    LCM_DB <= LINE_2(12);
                when 39 =>
                    LCM_DB <= LINE_2(13);
                when 40 =>
                    LCM_DB <= LINE_2(14);
                when 41 =>
                    LCM_DB <= LINE_2(15);
            end case;
        end if;
    end process;
        
    -- LCD PIN 3 to 6
    GPIO_0(13) <= '0';
    GPIO_0(14) <= LCM_RS;
    GPIO_0(15) <= LCM_RW;
    GPIO_0(17) <= LCM_EN;
    -- LCD PIN 7 to 14 (DB0 ~ DB7)
    GPIO_0(19) <= LCM_DB(0);
    GPIO_0(21) <= LCM_DB(1);
    GPIO_1(9)  <= LCM_DB(2);
    GPIO_1(11) <= LCM_DB(3);
    GPIO_1(13) <= LCM_DB(4);
    GPIO_1(14) <= LCM_DB(5);
    GPIO_1(15) <= LCM_DB(6);
    GPIO_1(17) <= LCM_DB(7);
    -- LCD PIN 15 to 16
    GPIO_1(19) <= '1';
    GPIO_1(21) <= '0'; -- Turn on backlight
end architecture;