library IEEE;
use IEEE.std_logic_1164.all;

entity b2d_converter is
  port (
    sw : in std_logic_vector(3 downto 0);
    hex0 : out std_logic_vector(6 downto 0);
    hex1 : out std_logic_vector(6 downto 0)
   
  );
end b2d_converter;

architecture arch of b2d_converter is
begin
    process(sw)
    begin
        hex1 <= "0000001"; -- 0

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
                hex0 <= "0000001"; 
            when "1011" =>
                hex0 <= "1001111"; 
            when "1100" =>
                hex0 <= "0010010"; 
            when "1101" =>
                hex0 <= "0000110"; 
            when "1110" =>
                hex0 <= "1001100"; 
            when "1111" =>
                hex0 <= "0100100"; 
            when others =>
                hex0 <= "1111111"; -- turn off all segments
        end case;
		  
		if sw > "1001" then
            hex1 <= "1001111";
		end if;
    end process;
end arch;