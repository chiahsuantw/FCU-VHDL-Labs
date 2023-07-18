library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sequence_detector_2 is
    port(
        clk : in std_logic;
        rst : in std_logic;
        w : in std_logic;
        state : out std_logic_vector(3 downto 0);
        z : out std_logic
    );
end entity;

architecture arch of sequence_detector_2 is
    type state_type is (A, B, C, D, E, F, G, H, I);
    signal current_state, next_state : state_type;
begin
    -- State table
    process(w, current_state)
    begin
        case current_state is
            when A =>
                if w = '1' then
                    next_state <= F;
                else 
                    next_state <= B;
                end if;
            when B =>
                if w = '1' then
                    next_state <= F;
                else 
                    next_state <= C;
                end if;
            when C =>
                if w = '1' then
                    next_state <= F;
                else 
                    next_state <= D;
                end if;
            when D =>
                if w = '1' then
                    next_state <= F;
                else 
                    next_state <= E;
                end if;
            when E =>
                if w = '1' then
                    next_state <= F;
                else 
                    next_state <= E;
                end if;
            when F =>
                if w = '1' then
                    next_state <= G;
                else 
                    next_state <= B;
                end if;
            when G =>
                if w = '1' then
                    next_state <= H;
                else 
                    next_state <= B;
                end if;
            when H =>
                if w = '1' then
                    next_state <= I;
                else 
                    next_state <= B;
                end if;
            when I =>
                if w = '1' then
                    next_state <= I;
                else 
                    next_state <= B;
                end if;
            when others =>
                next_state <= A;
        end case;
    end process;

    process(clk, rst)
    begin
        if rst = '0' then
            current_state <= A;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
    
    process(current_state)
    begin
        case current_state is
            when A => state <= "0000"; z <= '0';
            when B => state <= "0001"; z <= '0';
            when C => state <= "0010"; z <= '0';
            when D => state <= "0011"; z <= '0';
            when E => state <= "0100"; z <= '1';
            when F => state <= "0101"; z <= '0';
            when G => state <= "0110"; z <= '0';
            when H => state <= "0111"; z <= '0';
            when I => state <= "1000"; z <= '1';
        end case;
    end process;
end architecture;