library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.numeric_std.all;

entity VGA_top is
  Port (reset     : in  std_logic;  -- reset signal
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
end VGA_top;

architecture Behavioral of VGA_top is
 
component VGA_control is
	Port (reset     : in  std_logic;  -- reset signal
		  clk       : in  std_logic;  -- 50 MHz cloc
		  
		  pclk		: out std_logic;  --25 MHz
		  
		  hc, vc    : out std_logic_vector(10 downto 0);
        
		  hs        : out std_logic;  -- Horizontal sync pulse.  Active low
        vs        : out std_logic;  -- Vertical sync pulse.  Active low
        pixel_clk : out std_logic;  -- 25 MHz pixel clock
        blank     : out std_logic;  -- Blanking interval indicator.  Active low.
        sync      : out std_logic  -- Composite Sync signal.  Active low.  We don't use it in this lab,
        );
end component VGA_control;

component color is
	Port (
		  pclk       : in  std_logic;  -- 25 MHz cloc
		  
        hc,vc		: in  std_logic_vector(10 downto 0);
		  cursor_x  : in integer;
		  cursor_y  : in integer;
        Red : out std_logic_vector(9 downto 0);
        Green : out std_logic_vector(9 downto 0);
        Blue : out std_logic_vector(9 downto 0));
end component color;

signal hc: std_logic_vector(10 downto 0);
signal vc: std_logic_vector(10 downto 0);
signal pclk: std_logic;

begin

vga : VGA_control port map (reset => reset, clk => clk,
	pclk => pclk, hc => hc, vc => vc, hs => hs,
	vs => vs, pixel_clk => pixel_clk, blank => blank, sync => sync); 

color_control : color port map(  pclk => pclk, cursor_x => cursor_x,
	cursor_y => cursor_y, hc => hc, vc => vc, 
	Red => Red, Green => Green, Blue => Blue); 

end Behavioral;
