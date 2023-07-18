library IEEE;
use IEEE.std_logic_1164.all;

entity prime_number_detector is
  port (
    sw : in std_logic_vector(3 downto 0);
    hex0 : out std_logic_vector(6 downto 0);
    ledg : out std_logic
  );
end prime_number_detector;

architecture arch of prime_number_detector is
begin
    process(sw)
    begin
        case sw is
            when "0000" =>
                hex0 <= "0000001"; -- 0
            when "0001" =>
                hex0 <= "1001111"; -- 1
            when "0010" =>
                hex0 <= "0010010"; -- 2
            when "0011" =>
                hex0 <= "0000110"; -- 3
            when "0100" =>
                hex0 <= "1001100"; -- 4
            when "0101" =>
                hex0 <= "0100100"; -- 5
            when "0110" =>
                hex0 <= "0100000"; -- 6
            when "0111" =>
                hex0 <= "0001111"; -- 7
            when "1000" =>
                hex0 <= "0000000"; -- 8
            when "1001" =>
                hex0 <= "0000100"; -- 9
            when "1010" =>
                hex0 <= "0001000"; -- A
            when "1011" =>
                hex0 <= "1100000"; -- B
            when "1100" =>
                hex0 <= "0110001"; -- C
            when "1101" =>
                hex0 <= "1000010"; -- D
            when "1110" =>
                hex0 <= "0110000"; -- E
            when "1111" =>
                hex0 <= "0111000"; -- F
            when others =>
                hex0 <= "1111111"; -- turn off all segments
        end case;
		  
		-- (~a~bc)+(~bcd)+(b~cd)+(~acd)
		  
        ledg <= (not sw(3) and not sw(2) and sw(1)) or (not sw(2) and sw(1) and sw(0)) or 
                (sw(2) and not sw(1) and sw(0)) or (not sw(3) and sw(1) and sw(0));
    end process;
end arch;