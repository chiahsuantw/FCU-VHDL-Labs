library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sequence_detector is
    port(
        clk : in std_logic;
        rst : in std_logic;
        x : in std_logic;
        op : out std_logic;
        state : out std_logic_vector(2 downto 0)
    );
end entity;

architecture arch of sequence_detector is
    type state_type is (s0, s1, s2, s3, s4);
    signal current_state, next_state : state_type;
begin
    process(x, current_state)
    begin
        case current_state is
            when s0 =>
                if x = '1' then
                    next_state <= s1;
                else 
                    next_state <= s0;
                end if;
            when s1 =>
                if x = '1' then
                    next_state <= s1;
                else 
                    next_state <= s2;
                end if;
            when s2 =>
                if x = '1' then
                    next_state <= s3;
                else 
                    next_state <= s0;
                end if;
            when s3 =>
                if x = '1' then
                    next_state <= s4;
                else 
                    next_state <= s2;
                end if;
            when s4 =>
                if x = '1' then
                    next_state <= s1;
                else 
                    next_state <= s2;
                end if;
            when others =>
                next_state <= s0;
        end case;
    end process;

    process(clk, rst)
    begin
        if rst = '0' then
            current_state <= s0;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
    
    process(current_state)
    begin
        case current_state is
            when s0 => state <= "000"; op <= '0';
            when s1 => state <= "001"; op <= '0';
            when s2 => state <= "010"; op <= '0';
            when s3 => state <= "011"; op <= '0';
            when s4 => state <= "100"; op <= '1';
        end case;
    end process;
end architecture;