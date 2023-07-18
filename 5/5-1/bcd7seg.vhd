library ieee;
use ieee.std_logic_1164.all;

entity bcd7seg is
    port (
        bcd: in std_logic_vector(3 downto 0);
        display: out std_logic_vector(6 downto 0)
    );
end bcd7seg;

architecture Behavior of bcd7seg is
begin
    process(bcd)
    begin
        case bcd is
            when "0000" => display <= "0000001";
            when "0001" => display <= "1001111";
            when "0010" => display <= "0010010";
            when "0011" => display <= "0000110";
            when "0100" => display <= "1001100";
            when "0101" => display <= "0100100";
            when "0110" => display <= "0100000";
            when "0111" => display <= "0001111";
            when "1000" => display <= "0000000";
            when "1001" => display <= "0000100";
            when others => display <= "1111111";
        end case;
    end process;
end Behavior;