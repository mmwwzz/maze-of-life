library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.numeric_std.all;

entity VGA_control is
  Port (reset     : in  std_logic;  -- reset signal
		  clk       : in  std_logic;  -- 50 MHz cloc
		  
		  pclk		: out std_logic;  --25 MHz
		  
		  hc, vc    : out std_logic_vector(10 downto 0);
        
		  hs        : out std_logic;  -- Horizontal sync pulse.  Active low
        vs        : out std_logic;  -- Vertical sync pulse.  Active low
        pixel_clk : out std_logic;  -- 25 MHz pixel clock
        blank     : out std_logic;  -- Blanking interval indicator.  Active low.
        sync      : out std_logic  -- Composite Sync signal.  Active low.  We don't use it in this lab,
                                     --   but the video DAC on the DE2 board requires an input for it.
       );
end VGA_control;

architecture Behavioral of VGA_control is
 --800 horizontal pixels indexed 0 to 799
  --525 vertical pixels indexed 0 to 524
constant hpixels : std_logic_vector(10 downto 0) := "01100011001";
constant vlines  : std_logic_vector(10 downto 0) := "01000001100";



signal hc_tmp: std_logic_vector(10 downto 0);
signal vc_tmp: std_logic_vector(10 downto 0);
signal pclk_tmp: std_logic;
signal hs_tmp: std_logic;




begin

	sync <= '0';  --- disable signal sync----
---------------clock divide----------
pix_clk:	process(clk, reset)
	begin
		if (reset = '1') then
			pclk_tmp <= '0';
		elsif (rising_edge(clk)) then
				pclk_tmp <= not pclk_tmp;
		end if;
	end process;

pclk <= pclk_tmp;
pixel_clk <= pclk_tmp;
-------------end clock divide---------------
-------------h counter-----------------
hc_proc: process(pclk_tmp, reset)
	begin
		if (reset = '1') then
			hc_tmp <= "00000000000";
		elsif (rising_edge(pclk_tmp)) then
			if (hc_tmp = hpixels) then
				hc_tmp <= "00000000000";
			else
				hc_tmp <= hc_tmp + '1';
			end if;
		end if;
		
	end process;
hc <= hc_tmp;
	
hs_proc: process(pclk_tmp, reset)
	 begin
		if rising_edge(pclk_tmp) then
			if (reset = '1') then
				hs_tmp <= '0';
			elsif ( hc_tmp>= "00000000000" and hc_tmp <= "00001011111") then
				hs_tmp <= '0';
			else 
				hs_tmp <= '1';
			end if;
		end if;
	 end process;

hs <= hs_tmp;  ----------------output hs
----------------------- v counter---------------------
vc_proc: process(hs_tmp, reset)
	 begin
			if (reset = '1') then
				vc_tmp <= "00000000000";
			elsif (falling_edge(hs_tmp)) then
			
				if (vc_tmp = vlines) then
					vc_tmp <= "00000000000";
				else
					vc_tmp <= vc_tmp + '1';
				end if;
			end if;
	 end process;
vc <= vc_tmp;

vs_proc: process(pclk_tmp, reset)
	 begin
		if rising_edge(pclk_tmp) then
			if (reset = '1') then
				vs <= '0';
			elsif (vc_tmp = "00000000000" or vc_tmp = "00000000001") then
				vs <= '0';
			else
				vs <= '1';
			end if;
		end if;
	 end process;

---------------------------------------------------------------------------------------------------------
blank_proc: process(pclk_tmp)
begin
	if rising_edge(pclk_tmp) then
		if ((vc_tmp >= "00000000000" and vc_tmp <= "00000000001") or (hc_tmp >= "00000000000" and hc_tmp <= "00001011111")) then
			blank <= '0';
		else
			blank <= '1';
		end if;
	end if;
end process;


end Behavioral;