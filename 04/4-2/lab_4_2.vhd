library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity lab_4_2 is
    port (
        A, B : in std_logic_vector(2 downto 0);
        btn0, btn1 : in std_logic;
        seg0, seg1 : out std_logic_vector(6 downto 0);
        led : out std_logic_vector(3 downto 0)
    );
end lab_4_2;

architecture behavior of lab_4_2 is
    signal sum : std_logic_vector(3 downto 0);
begin
    process(A, B, btn0, btn1)
    begin
        -- 初始狀況，都不顯示
        seg0 <= "1111111"; -- off
        seg1 <= "1111111"; -- off
        led  <= "0000";
        
        sum <= std_logic_vector(unsigned('0' & A) + unsigned('0' & B));
        
        if btn0 = '0' and btn1 = '1' then -- 如果按下 Button0：在七段顯示器上顯示 A + B 數值
            if sum > "1001" then 
                seg1 <= "1001111"; -- 1x
            else
                seg1 <= "0000001"; -- 0x
            end if; 
            
            case sum is
                when "0000" | "1010" =>
                    seg0 <= "0000001"; -- x0
                when "0001" | "1011" =>
                    seg0 <= "1001111"; -- x1
                when "0010" | "1100" =>
                    seg0 <= "0010010"; -- x2
                when "0011" | "1101" =>
                    seg0 <= "0000110"; -- x3
                when "0100" | "1110" =>
                    seg0 <= "1001100"; -- x4
                when "0101" | "1111" =>
                    seg0 <= "0100100"; -- x5
                when "0110" =>
                    seg0 <= "0100000"; -- x6
                when "0111" =>
                    seg0 <= "0001111"; -- x7
                when "1000" =>
                    seg0 <= "0000000"; -- x8
                when "1001" =>
                    seg0 <= "0000100"; -- x9
            end case;
        end if;
        
        if btn0 = '1' and btn1 = '0' then -- 如果按下 Button1：在 LED 上顯示 A + B 數值（二進制）
            led <= sum;
        end if;
    end process;
end behavior;