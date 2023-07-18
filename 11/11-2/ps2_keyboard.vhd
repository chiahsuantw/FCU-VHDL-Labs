--------------------------------------------------------------------------------
--
-- FileName: ps2_keyboard.vhd
-- Dependencies: debounce.vhd
-- Design Software: Quartus II 32-bit Version 12.1 Build 177 SJ Full Version
--
-- HDL CODE IS PROVIDED "AS IS." DIGI-KEY EXPRESSLY DISCLAIMS ANY
-- WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
-- LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
-- PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
-- BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
-- DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
-- PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
-- BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
-- ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
-- Version History
-- Version 1.0 11/25/2013 Scott Larson
-- Initial Public Release
-- 
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity ps2_keyboard is
	generic (
		clk_freq : integer := 50_000_000; --system clock frequency in Hz
        debounce_counter_size : integer := 8); --set such that (2^size)/clk_freq = 5us (size = 8 for 50MHz)
	port (
		clk : in STD_LOGIC; --system clock
		ps2_clk : in STD_LOGIC; --clock signal from PS/2 keyboard
		ps2_data : in STD_LOGIC; --data signal from PS/2 keyboard
		ps2_code_new : out STD_LOGIC; --flag that new PS/2 code is available on ps2_code bus
        ps2_code : out STD_LOGIC_VECTOR(7 downto 0)); --code received from PS/2
end ps2_keyboard;

architecture logic of ps2_keyboard is
	signal sync_ffs : STD_LOGIC_VECTOR(1 downto 0); --synchronizer flip-flops for PS/2 signals
	signal ps2_clk_int : STD_LOGIC; --debounced clock signal from PS/2 keyboard
	signal ps2_data_int : STD_LOGIC; --debounced data signal from PS/2 keyboard
	signal ps2_word : STD_LOGIC_VECTOR(10 downto 0); --stores the ps2 data word
	signal error : STD_LOGIC; --validate parity, start, and stop bits
	signal count_idle : integer range 0 to clk_freq/18_000; --counter to determine PS/2 is idle
 
	--declare debounce component for debouncing PS2 input signals
	component debounce is
		generic (
            counter_size : integer); --debounce period (in seconds) = 2^counter_size/(clk freq in Hz)
		port (
			clk : in STD_LOGIC; --input clock
			button : in STD_LOGIC; --input signal to be debounced
            result : out STD_LOGIC); --debounced signal
	end component;
begin
	--synchronizer flip-flops
	process (clk)
	begin
		if (clk'EVENT and clk = '1') then --rising edge of system clock
			sync_ffs(0) <= ps2_clk; --synchronize PS/2 clock signal
			sync_ffs(1) <= ps2_data; --synchronize PS/2 data signal
		end if;
	end process;

	--debounce PS2 input signals
	debounce_ps2_clk : debounce
		generic map(counter_size => debounce_counter_size)
		port map(clk => clk, button => sync_ffs(0), result => ps2_clk_int);
	debounce_ps2_data : debounce
		generic map(counter_size => debounce_counter_size)
        port map(clk => clk, button => sync_ffs(1), result => ps2_data_int);

	--input PS2 data
	process (ps2_clk_int)
	begin
		if (ps2_clk_int'EVENT and ps2_clk_int = '0') then --falling edge of PS2 clock
			ps2_word <= ps2_data_int & ps2_word(10 downto 1); --shift in PS2 data bit
		end if;
	end process;
 
	--verify that parity, start, and stop bits are all correct
	error <= not (not ps2_word(0) and ps2_word(10) and (ps2_word(9) xor ps2_word(8) xor
		ps2_word(7) xor ps2_word(6) xor ps2_word(5) xor ps2_word(4) xor ps2_word(3) xor
		ps2_word(2) xor ps2_word(1))); 

    --determine if PS2 port is idle (i.e. last transaction is finished) and output result
    process (clk)
    begin
        if (clk'EVENT and clk = '1') then --rising edge of system clock
            if (ps2_clk_int = '0') then --low PS2 clock, PS/2 is active
                count_idle <= 0; --reset idle counter
            elsif (count_idle /= clk_freq/18_000) then --PS2 clock has been high less than a half clock period (<55us)
                count_idle <= count_idle + 1; --continue counting
            end if;

            if (count_idle = clk_freq/18_000 and error = '0') then --idle threshold reached and no errors detected
                ps2_code_new <= '1'; --set flag that new PS/2 code is available
                ps2_code <= ps2_word(8 downto 1); --output new PS/2 code
            else --PS/2 port active or error detected
                ps2_code_new <= '0'; --set flag that PS/2 transaction is in progress
            end if;
        end if;
    end process;
end logic;