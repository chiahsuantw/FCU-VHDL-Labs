library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ac is
    port(
        A, B : in std_logic_vector(3 downto 0);
        btn : in std_logic_vector(2 downto 0);
        seg0, seg1 : out std_logic_vector(6 downto 0);
        output : out std_logic_vector(7 downto 0);
        bcd_1, bcd_0 : out std_logic_vector(3 downto 0);
        neg : out std_logic
    );
end ac;

architecture Behavior of ac is
    component bcd7seg
        port (
            bcd : in std_logic_vector(3 downto 0);
            display : out std_logic_vector(6 downto 0)
        );
    end component;
    
    signal add : std_logic_vector(7 downto 0);
    signal sub : std_logic_vector(7 downto 0);
    signal mult : std_logic_vector(7 downto 0);
    signal bcd_h, bcd_l : std_logic_vector(3 downto 0);
begin
    process(A, B, btn)
    begin
        add <= std_logic_vector(resize(signed(A), 8) + resize(signed(B), 8));
        sub <= std_logic_vector(resize(signed(A), 8) - resize(signed(B), 8));
        mult <= std_logic_vector(signed(A) * signed(B));
        
        -- Clear display
        bcd_h <= "1111";
        bcd_l <= "1111";
        neg <= '0';
        
        case btn is
            when "110" =>
                output <= add;
                bcd_h <= std_logic_vector(resize(unsigned(abs(signed(add))) / 10, 4));
                bcd_l <= std_logic_vector(resize(unsigned(abs(signed(add))) mod 10, 4));
                if signed(add) < 0 then
                    neg <= '1';
                end if;
            when "101" =>
                output <= sub;
                bcd_h <= std_logic_vector(resize(unsigned(abs(signed(sub))) / 10, 4));
                bcd_l <= std_logic_vector(resize(unsigned(abs(signed(sub))) mod 10, 4));
                if signed(sub) < 0 then
                    neg <= '1';
                end if;
            when "011" =>
                output <= mult;
                bcd_h <= std_logic_vector(resize(unsigned(abs(signed(mult))) / 10, 4));
                bcd_l <= std_logic_vector(resize(unsigned(abs(signed(mult))) mod 10, 4));
                if signed(mult) < 0 then
                    neg <= '1';
                end if;
            when others =>
                -- Reset all values
                output <= "00000000";
                bcd_h <= "1111";
                bcd_l <= "1111";
                neg <= '0';
        end case;
        
        bcd_1 <= bcd_h;
        bcd_0 <= bcd_l;
    
    end process;
    
    digit1: bcd7seg port map (bcd_h, seg1);
    digit0: bcd7seg port map (bcd_l, seg0);

end Behavior;