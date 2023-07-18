library ieee;
use ieee.std_logic_1164.all;

entity bcd7seg is
    port (
        bcd: in std_logic_vector(4 downto 0);
        display: out std_logic_vector(6 downto 0)
    );
end bcd7seg;

architecture arch of bcd7seg is
begin
    process(bcd)
    begin
        case bcd is
            when "00000" => display <= "0000001"; -- 0
            when "00001" => display <= "1001111";
            when "00010" => display <= "0010010";
            when "00011" => display <= "0000110";
            when "00100" => display <= "1001100";
            when "00101" => display <= "0100100";
            when "00110" => display <= "0100000";
            when "00111" => display <= "0001111";
            when "01000" => display <= "0000000";
            when "01001" => display <= "0000100"; -- 9
            when "01010" => display <= "0001000"; -- A
            when "01011" => display <= "1100000";
            when "01100" => display <= "0110001";
            when "01101" => display <= "1000010";
            when "01110" => display <= "0110000";
            when "01111" => display <= "0111000"; -- F
            when others  => display <= "1111111"; -- Turn off when "11111"
        end case;
    end process;
end architecture;