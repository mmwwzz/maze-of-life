library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.numeric_std.all;

entity General_top is
  Port (reset     : in  std_logic;  -- reset signal
		  clk       : in  std_logic;  -- 50 MHz cloc
		  
		  ps2_clk      : in  std_logic;  --clock signal from PS/2 keyboard
		  ps2_data     : in  std_logic;  --data signal from PS/2 keyboard
        
		  hs        : out std_logic;  -- Horizontal sync pulse.  Active low
        vs        : out std_logic;  -- Vertical sync pulse.  Active low
        pixel_clk : out std_logic;  -- 25 MHz pixel clock
        blank     : out std_logic;  -- Blanking interval indicator.  Active low.
        sync      : out std_logic;  -- Composite Sync signal.  Active low.  We don't use it in this lab,
                                     --   but the video DAC on the DE2 board requires an input for it.
        Red : out std_logic_vector(9 downto 0);
        Green : out std_logic_vector(9 downto 0);
        Blue : out std_logic_vector(9 downto 0));
end General_top;

architecture Behavioral of General_top is

signal cursor_x : integer;
signal cursor_y : integer; 
component keyboard_top is
	Port (reset		  : in  std_logic;
		 clk          : in  std_logic;                     --system clock
		 ps2_clk      : in  std_logic;                     --clock signal from PS/2 keyboard
		 ps2_data     : in  std_logic;                     --data signal from PS/2 keyboard
		 cursor_x     : out integer;
		 cursor_y     : out integer );
end component keyboard_top;

component VGA_top is
	Port (
		  reset     : in  std_logic;  -- reset signal
		  clk       : in  std_logic;  -- 50 MHz cloc
        
		  cursor_x  : in integer;
		  cursor_y  : in integer;
		  
		  hs        : out std_logic;  -- Horizontal sync pulse.  Active low
        vs        : out std_logic;  -- Vertical sync pulse.  Active low
        pixel_clk : out std_logic;  -- 25 MHz pixel clock
        blank     : out std_logic;  -- Blanking interval indicator.  Active low.
        sync      : out std_logic;  -- Composite Sync signal.  Active low.  We don't use it in this lab,
                                     --   but the video DAC on the DE2 board requires an input for it.
        Red : out std_logic_vector(9 downto 0);
        Green : out std_logic_vector(9 downto 0);
        Blue : out std_logic_vector(9 downto 0));
end component VGA_top;


begin

keyboard : keyboard_top port map (reset => reset, clk => clk,
	ps2_clk => ps2_clk, ps2_data => ps2_data, cursor_x => cursor_x, cursor_y => cursor_y); 

VGA : VGA_top port map(  reset => reset, clk => clk, cursor_x => cursor_x,
	cursor_y => cursor_y, hs => hs, vs => vs, pixel_clk => pixel_clk, blank => blank, sync => sync,
	Red => Red, Green => Green, Blue => Blue); 

end Behavioral;
