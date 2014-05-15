library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use ieee.numeric_std.all;

entity color is
  Port (
		  pclk       : in  std_logic;  -- 25 MHz cloc
		  
		  cursor_x  : in integer;
		  cursor_y  : in integer;
		  
        hc,vc		: in  std_logic_vector(10 downto 0);
		  
        Red : out std_logic_vector(9 downto 0);
        Green : out std_logic_vector(9 downto 0);
        Blue : out std_logic_vector(9 downto 0));
end color;

architecture Behavioral of color is

signal product: std_logic_vector(21 downto 0);
signal abs_x, p_minus_x, n_minus_x : std_logic_vector(10 downto 0);
signal abs_y, p_minus_y, n_minus_y : std_logic_vector(10 downto 0);

signal center_x, center_y : std_logic_vector( 10 downto 0);

signal position_x, position_y : integer;

signal square_color : std_logic_vector(2 downto 0);

type d2_array is array(0 to 6, 0 to 6) of std_logic;
signal mem7x7 : d2_array := (
    ('0','0','0','1','0','0','0'),
	 ('0','0','1','0','1','0','0'),
    ('0','0','0','1','0','0','0'),
    ('0','1','0','0','0','0','0'),
    ('0','0','0','1','0','0','0'),
    ('0','0','1','0','1','0','0'),
    ('0','0','0','1','0','0','0')
    
    );
constant target_x : integer := 5;
constant target_y : integer := 3;

constant current_x : integer := 1;
constant current_y : integer := 1;

constant live : integer := 0;

------------------calculate product, abs_x, abs_y-------------------------------
begin
product <= (hc-center_x)*(hc-center_x)+(vc-center_y)*(vc-center_y);
p_minus_x <= hc - center_x;
n_minus_x <= center_x - hc;
abs_x <= p_minus_x when (hc > center_x) else n_minus_x;
p_minus_y <= vc - center_y;
n_minus_y <= center_y - vc;
abs_y <= p_minus_y when (vc > center_y) else n_minus_y;

---------------end calculate product abs_x abs_y------------------------------------
----------------------------------Draw chess table and chess-------------------------------
Draw_Chess_table : process (pclk)
begin
	if rising_edge(pclk) then
		 if( hc <="01011101001" and hc >="00010110110" and vc <= "00111100101" and vc >= "00000111110" ) then
				--------- begin grid ---------------------------------------
				if((vc <= "00001000001" and vc >="00000111110" )		--62--65--
				or (vc <= "00001111101" and vc >="00001111010" )		--122--125--
				or (vc <= "00010111001" and vc >="00010110110" )		--182--185--
				or (vc <= "00011110101" and vc >="00011110010" )		--242--245--
				or (vc <= "00100110001" and vc >="00100101110" )		--302--305--
				or (vc <= "00101101101" and vc >="00101101010" )		--362--365--
				or (vc <= "00110101001" and vc >="00110100110" )		--422--425--
				or (vc <= "00111100101" and vc >="00111100010" )		--482--485--
				
			  
				or (hc <= "00010111001" and hc >="00010110110" )		--182--185--
				or (hc <= "00100001001" and hc >="00100000110" )		--262--265--
				or (hc <= "00101011001" and hc >="00101010110" )		--342--345--
				or (hc <= "00110101001" and hc >="00110100110" )		--422--425--
				or (hc <= "00111111001" and hc >="00111110110" )		--502--505--
				or (hc <= "01001001001" and hc >="01001000110" )		--582--585--
				or (hc <= "01010011001" and hc >="01010010110" )		--662--665--
				or (hc <= "01011101001" and hc >="01011100110" )		--742--745--
				)then
					
					square_color <= "010";--line(brown)
				----------------------end grid----------------------------------------------
				elsif( mem7x7(position_y, position_x)= '1' and product <= "00000000000001001110001") then  --chess_size := 25*25
					square_color <= "010";--draw other chess----
				elsif(current_x = position_x and current_y = position_y and live = 1 and product <= "00000000000001001110001" )then
					square_color <= "110";--draw current chess---
				elsif(current_x = position_x and current_y = position_y and live = 0 and product >= "0000000000001000000001" and product <= "0000000000001001110001")then
					square_color <= "110";--draw dead chess : an empty circle----
				elsif( (target_x = position_x) and (target_y = position_y) and (abs_x <= "00000010100") and (abs_y <= "00000010100")) then -- target
					square_color <= "001"; ----draw target place : red---
				elsif( (cursor_x = position_x) and (cursor_y = position_y) and ((abs_x >= "00000100000") or(abs_y >= "00000010110"))) then--x:32--y:22
					square_color <= "001";---draw cursor : red------
				else
					square_color <= "111";---draw board color : blue-----
				end if;
			
			else
					square_color <= "000";---draw background : white----
			end if;
	end if;	  
	
end process Draw_Chess_table;

----------------------position_x center_x--------------------------------------------------
PositionX_proc: process(pclk)
begin
	if rising_edge(pclk) then
		if(hc<= "00100000110" and hc>= "00010111001") then	--x--185--262----
			position_x <= 0;--"0000";	---x--0--
			center_x <= "00011011111";	---mid : 223------
		elsif(hc<= "00101010110" and hc >= "00100001001")then --x--265--342---
			position_x <= 1; --"0001";	---x--1--
			center_x <= "00100101111";	---mid : 303------
		elsif(hc<= "00110100110" and hc>= "00101011001")then --x--345--422---
			position_x <= 2;--"0010";	---x--2--
			center_x <= "00101111111";	---mid : 383------
		elsif(hc<= "00111110110" and hc>= "00110101001")then --x--425--502---
			position_x <= 3; ---"0011";	---x--3--
			center_x <= "00111001111";	---mid : 463------
		elsif(hc<= "01001000110" and hc>= "00111111001")then --x--505--582---
			position_x <= 4; --"0100";	---x--4--
			center_x <= "01000011111";	---mid : 543------
		elsif(hc<= "01010010110" and hc>= "01001001001")then --x--585--662---
			position_x <= 5; --"0101";	---x--5--
			center_x <= "01001101111";	---mid : 623------
		elsif(hc<= "01011100110" and hc>= "01010011001")then --x--665--742---
			position_x <= 6; --"0110";	---x--6--
			center_x <= "01010111111";	---mid : 703------
		end if;
	end if;
end process PositionX_proc;
-------------------------------------------------------------------------------------
----------------------position_y center_y--------------------------------------------------
PositionY_proc: process(pclk)
begin
	if rising_edge(pclk) then
		if(vc <= "00001111010" and vc >="00000111110") then	--y--65--122---
			position_y <= 0; --"0000";	---y--0--
			center_y <= "00001011101"; ---mid : 93---
		elsif(vc <= "00010110110" and vc >="00001111101")then --y--125--182---
			position_y <= 1; --"0001";	---y--1--
			center_y <= "00010011001"; ---mid : 153---
		elsif(vc <= "00011110010" and vc >="00010111001")then --y--185--242---
			position_y <= 2; --"0010";	---y--2--
			center_y <= "00011010101"; ---mid : 213---
		elsif(vc<= "00100101110" and vc >= "00011110101")then --y--245--302---
			position_y <= 3; --"0011";	---y--3--
			center_y <= "00100010001"; ---mid : 273---
		elsif(vc<= "00101101010" and vc >= "00100110001")then --y--305--362---
			position_y <= 4; --"0100";	---y--4--
			center_y <= "00101001101"; ---mid : 333---
		elsif(vc<= "00110100110" and vc >= "00101101101")then --y--365--422---
			position_y <= 5; --"0101";	---y--5--
			center_y <= "00110001001"; ---mid : 393---
		elsif(vc<= "00111100010" and vc >= "00110101001")then --y--425--482---
			position_y <= 6; --"0110";	---y--6--
			center_y <= "00111000101"; ---mid : 453---
		end if;
	end if;
end process PositionY_proc;



-------------------color display--------------------------------------------------			
RGB_Display : process (pclk) -- color define
  begin
	if rising_edge(pclk) then
		if (square_color = "000") then -- white
			Red   <= "0000000000";
			Green <= "0000000000";
			Blue  <= "0000000000";
		elsif (square_color = "001") then -- Red
			Red   <= "1111111111";
			Green <= "0000000000";
			Blue  <= "0000000000";
		elsif (square_color = "010") then -- Blue
			Red   <= "0000000000";
			Green <= "0000000000";
			Blue  <= "1111111111";
		elsif (square_color = "011") then -- green
			Red   <= "0000000000";
			Green <= "1111111111";
			Blue  <= "0000000000";
		elsif (square_color = "100") then -- oringe
			Red   <= "1111111111";
			Green <= "1111111111";
			Blue  <= "0000000000";
		elsif (square_color = "101") then -- purple
			Red   <= "1100011111";
			Green <= "0000011111";
			Blue  <= "1100011111";
		elsif (square_color = "110") then -- brown
			Red   <= "1111111111";
			Green <= "1100001111";
			Blue  <= "0000011111";
		elsif (square_color = "111") then -- black
			Red   <= "1111111111";
			Green <= "1111111111";
			Blue  <= "1111111111";
		else
			Red   <= "1111111111";
			Green <= "1111111111";
			Blue  <= "1111111111";
		end if;
	end if;
  end process RGB_Display;


	

end Behavioral;