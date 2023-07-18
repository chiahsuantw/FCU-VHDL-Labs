library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test is
    port (
        clk     : in  std_logic;
        reset   : in  std_logic;
        btn     : in  std_logic;
        leds : out std_logic_vector(2 downto 0)
    );
end entity;

architecture arch of test is
    signal seq : std_logic_vector(2 downto 0);
begin
    process (clk, reset)
        variable feedback : std_logic;
    begin
        if reset = '0' then
            seq <= "100";
        elsif rising_edge(clk) then
            feedback := seq(0) xor seq(1);
            seq <= feedback & seq(2 downto 1);
        end if;
    end process;
    
    process(btn)
    begin
        if falling_edge(btn) then
            leds <= std_logic_vector(unsigned(seq) mod 6);
        end if;
    end process;
end architecture;
