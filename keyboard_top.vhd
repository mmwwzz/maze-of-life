library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity keyboard_top is
  port(
	 reset		  : in  std_logic;
    clk          : in  std_logic;                     --system clock
    ps2_clk      : in  std_logic;                     --clock signal from PS/2 keyboard
    ps2_data     : in  std_logic;                     --data signal from PS/2 keyboard
    cursor_x     : out integer;
	 cursor_y     : out integer );
end keyboard_top;

architecture Behavioral of keyboard_top is
constant  clk_freq              : integer := 50_000_000; --system clock frequency in Hz
constant  debounce_counter_size : integer := 8;         --set such that (2^size)/clk_freq = 5us (size = 8 for 50MHz)

type cntrl_state is (IDLE, PRE, UP, DOWN, LEFT, RIGHT);
signal state, next_state : cntrl_state;
--signal up_p, down_p, left_p, right_p: std_logic;

signal cursor_x_tmp             : integer			:= 0;
signal cursor_y_tmp				  : integer			:=0;

component ps2_keyboard is
    generic(
      clk_freq              : integer; 
		debounce_counter_size : integer);  
    port(
      clk          : in  std_logic;                     --system clock
		ps2_clk      : in  std_logic;                     --clock signal from PS/2 keyboard
		ps2_data     : in  std_logic;                     --data signal from PS/2 keyboard
		ps2_code_new : out std_logic;                     --flag that new PS/2 code is available on ps2_code bus
		ps2_code     : out std_logic_vector(7 downto 0));
end component;

signal	ps2_code_new :  std_logic;                     --flag that new PS/2 code is available on ps2_code bus
signal   ps2_code     :  std_logic_vector(7 downto 0); --code received from PS/2
begin

ps2: ps2_keyboard
    generic map(clk_freq => clk_freq, debounce_counter_size => debounce_counter_size)
    port map(clk => clk, ps2_clk => ps2_clk, ps2_data => ps2_data, 
				 ps2_code_new => ps2_code_new, ps2_code => ps2_code);

-----------------state---------------------------------------------------------------		 
control_state : process(clk, reset)	
begin
	if (reset = '1') then
			 state <= IDLE;
	elsif rising_edge(clk) then
			state <= next_state;
	end if;
end process;		

------------------------next state-------------------------------------------------------
get_next_state : process(clk)
begin
	if ( rising_edge(clk) ) then
		if( ps2_code_new = '1' ) then
			case state is
				when IDLE => 
					if(ps2_code(7 downto 0) = x"E0")then
						next_state <= PRE;
					else
						next_state <= IDLE;
					end if;
				when PRE =>
					if(ps2_code(7 downto 0) = x"F0")then
						next_state <= IDLE;
					elsif(ps2_code(7 downto 0) = x"75") then -- UP
						next_state <= UP;
					elsif(ps2_code(7 downto 0) = x"6B") then -- LEFT
						next_state <= LEFT;
					elsif(ps2_code(7 downto 0) = x"72") then -- DOWN
						next_state <= DOWN;
					elsif(ps2_code(7 downto 0) = x"74") then -- RIGHT
						next_state <= RIGHT;
					else
						next_state <= PRE;
					end if;
				--when UP =>
					--if(ps2_code(7 downto 0) = x"F0")then
						--next_state <= IDLE;
					--else
						--next_state <= UP;
					--end if;
				--when DOWN =>
					--if(ps2_code(7 downto 0) = x"F0")then
						--next_state <= IDLE;
					--else
						--next_state <= DOWN;
					--end if;
				--when LEFT =>
					--if(ps2_code(7 downto 0) = x"F0")then
						--next_state <= IDLE;
					--else
						--next_state <= LEFT;
					--end if;
				--when RIGHT =>
					--if(ps2_code(7 downto 0) = x"F0")then
					--	next_state <= IDLE;
				--	else
					--	next_state <= RIGHT;
					--end if;	  
				when others =>
					next_state <= IDLE;
				end case;
			end if;
		end if;
end process;


--------------------cursor_x-------------------------------
proc_cur_x: process(clk)
begin
		if rising_edge(clk) then
			case state is
				when LEFT =>
					if ( cursor_x_tmp > 0) then
						cursor_x_tmp <= cursor_x_tmp - 1;
					else
						cursor_x_tmp <= 0;
					end if;
				when RIGHT =>
					if ( cursor_x_tmp < 12) then
						cursor_x_tmp <= cursor_x_tmp + 1;
					else
						cursor_x_tmp <= 12;
					end if;
				when others =>
					cursor_x_tmp <= cursor_x_tmp;
			end case;
		end if;
end process;

--------------------cursor_y-------------------------------
proc_cur_y: process(clk)
begin
		if rising_edge(clk) then
			case state is
				when UP =>
					if cursor_y_tmp > 0 then
						cursor_y_tmp <= cursor_y_tmp - 1;
					else
						cursor_y_tmp <= 0;
					end if;
				when DOWN =>
					if ( cursor_y_tmp < 12) then
						cursor_y_tmp <= cursor_y_tmp + 1;
					else
						cursor_y_tmp <= 12;
					end if;
				when others =>
					cursor_y_tmp <= cursor_y_tmp;
			end case;
		end if;
end process;
----------------------------------------------------------------
cursor_x <= cursor_x_tmp/2;
cursor_y <= cursor_y_tmp/2;

end Behavioral;