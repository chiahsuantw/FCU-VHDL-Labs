library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity counter is
    port(
        clk: in std_logic;
        reset: in std_logic;
        out1, out2: out std_logic_vector(3 downto 0); -- debug
        seg1, seg2: out std_logic_vector(6 downto 0)
    );
end counter;

architecture Bahavior of counter is
    component bcd7seg
        port (
            bcd : in std_logic_vector(3 downto 0);
            display : out std_logic_vector(6 downto 0)
        );
    end component;
    
    signal count1, count2: integer range 0 to 10;
    signal temp1: integer range 0 to 10;
begin
    process(clk, reset)
    begin
        if (clk'event and clk='1') then
            temp1 <= temp1 + 1;
            if (temp1=9) then
                temp1 <= 0;
            end if;
        end if;
        
        if (reset='0') then
            temp1 <= 0;
        end if;
        
        count1 <= temp1;
        out1 <= std_logic_vector(to_unsigned(temp1, 4)); -- debug
    end process;
    
    process(clk, reset)
        variable temp2: integer range 0 to 10;
    begin
        if (clk'event and clk='1') then
            temp2 := temp2 + 1;
            if (temp2=10) then
                temp2 := 0;
            end if;
        end if;
        
        if (reset='0') then
            temp2 := 0;
        end if;
        
        count2 <= temp2;
        out2 <= std_logic_vector(to_unsigned(temp2, 4)); -- debug
    end process;
    
    display1: bcd7seg port map (std_logic_vector(to_unsigned(count1, 4)), seg1);
    display2: bcd7seg port map (std_logic_vector(to_unsigned(count2, 4)), seg2);
end Bahavior;
    