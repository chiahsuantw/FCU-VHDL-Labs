library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd7seg is
    port ( 
        input : in  STD_LOGIC_VECTOR(3 downto 0);
        output : out  STD_LOGIC_VECTOR(6 downto 0)
    );
end bcd7seg;

architecture Behavioral of bcd7seg is
begin
    process(input)
    begin
        case input is
            when "0000" =>
                output <= "0000001"; -- 0
            when "0001" =>
                output <= "1001111"; -- 1
            when "0010" =>
                output <= "0010010"; -- 2
            when "0011" =>
                output <= "0000110"; -- 3
            when "0100" =>
                output <= "1001100"; -- 4
            when "0101" =>
                output <= "0100100"; -- 5
            when "0110" =>
                output <= "0100000"; -- 6
            when "0111" =>
                output <= "0001111"; -- 7
            when "1000" =>
                output <= "0000000"; -- 8
            when "1001" =>
                output <= "0000100"; -- 9
            when "1010" =>
                output <= "0001000"; -- A
            when "1011" =>
                output <= "1100000"; -- B
            when "1100" =>
                output <= "0110001"; -- C
            when "1101" =>
                output <= "1000010"; -- D
            when "1110" =>
                output <= "0110000"; -- E
            when "1111" =>
                output <= "0111000"; -- F
            when others =>
                output <= "1111111"; -- turn off all segments
        end case;
    end process;
end Behavioral;