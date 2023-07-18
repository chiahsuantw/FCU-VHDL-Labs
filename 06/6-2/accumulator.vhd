library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity accumulator is
    port(
        clk, rst: std_logic;
        A: in std_logic_vector(7 downto 0);
        S: out std_logic_vector(7 downto 0);
        overflow: out std_logic
    );
end accumulator;

architecture behavior of accumulator is
    signal acc: std_logic_vector(7 downto 0);
    signal temp_ovfl: std_logic;
begin
    process(clk, rst)
    variable temp_acc: std_logic_vector(7 downto 0);
    variable temp_a: std_logic_vector(7 downto 0);
    variable temp_sum: std_logic_vector(7 downto 0);
    begin
        if rst = '0' then
            acc <= "00000000";
            S <= "00000000";
        elsif clk'event and clk = '1' then
            temp_acc := acc;
            temp_a   := a;
            temp_sum := std_logic_vector(signed(temp_acc) + signed(temp_a));
            
            if temp_acc(7) = temp_a(7) and temp_sum(7) /= temp_a(7) then
                temp_ovfl <= '1';
            else
                temp_ovfl <= '0';
            end if;
            
            acc <= temp_sum;
            S <= acc;
            overflow <= temp_ovfl;
        end if;
    end process;
end behavior;