library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga is
    Port (    clk : in  STD_LOGIC;
              rst : in  STD_LOGIC;
				  up : in STD_LOGIC;
				  down : in STD_LOGIC;
				  left : in STD_LOGIC;
				  right : in STD_LOGIC;
			  red_out : out STD_LOGIC;
			  green_out : out STD_LOGIC;
			  blue_out : out STD_LOGIC;
			  hs_out : out STD_LOGIC;
			  vs_out : out STD_LOGIC
			);
end vga;

architecture Behavioral of vga is

component hc05
port (
	clk: in std_logic;
	rst: in std_logic;
	dout: in std_logic_vector(7 downto 0);
	rw: out std_logic;
	addr: out std_logic_vector(7 downto 0);
	din: out std_logic_vector(7 downto 0);
	start : out std_logic
);
END component;

component ram  
port (
      clk: in std_logic;
	  rst: in std_logic;
	  rw: in std_logic;
	  addr: in std_logic_vector(7 downto 0);
	  din: in std_logic_vector(7 downto 0);
	  dout: out std_logic_vector(7 downto 0) 
);
END component;

signal clk50, clk25 		: STD_LOGIC;
signal horizontal_counter   : STD_LOGIC_VECTOR (9 downto 0);
signal vertical_counter     : STD_LOGIC_VECTOR (9 downto 0);
signal count 		 		: INTEGER range 0 to 100001;
signal countButton 		: INTEGER range 0 to 100001;
signal v : INTEGER range 0 to 1;
signal h : INTEGER range 0 to 1;
signal screenSize_horizontalA  : STD_LOGIC_VECTOR (9 downto 0);
signal ScreenSize_horizontalB  : STD_LOGIC_VECTOR (9 downto 0);
signal ScreenSize_verticalA : STD_LOGIC_VECTOR (9 downto 0);
signal ScreenSize_verticalB : STD_LOGIC_VECTOR (9 downto 0);
		
signal ScreenBoard_horizontalA: STD_LOGIC_VECTOR (9 downto 0);
signal ScreenBoard_horizontalB: STD_LOGIC_VECTOR (9 downto 0);
signal ScreenBoard_verticalA : STD_LOGIC_VECTOR (9 downto 0);
signal ScreenBoard_verticalB : STD_LOGIC_VECTOR (9 downto 0);

signal ballPosition_XA       : STD_LOGIC_VECTOR (9 downto 0);
signal ballPosition_XB     : STD_LOGIC_VECTOR (9 downto 0);
signal ballPosition_YA : STD_LOGIC_VECTOR (9 downto 0);
signal ballPosition_YB 	: STD_LOGIC_VECTOR (9 downto 0);

signal playerPosition_XA       : STD_LOGIC_VECTOR (9 downto 0);
signal playerPosition_XB     : STD_LOGIC_VECTOR (9 downto 0);
signal playerPosition_YA : STD_LOGIC_VECTOR (9 downto 0);
signal playerPosition_YB 	: STD_LOGIC_VECTOR (9 downto 0);

signal playerTwoPosition_XA : STD_LOGIC_VECTOR (9 downto 0);
signal playerTwoPosition_XB : STD_LOGIC_VECTOR (9 downto 0);
signal playerTwoPosition_YA : STD_LOGIC_VECTOR (9 downto 0);
signal playerTwoPosition_YB : STD_LOGIC_VECTOR (9 downto 0);

signal line_XA : STD_LOGIC_VECTOR (9 downto 0);
signal line_XB : STD_LOGIC_VECTOR (9 downto 0);
signal line_YA : STD_LOGIC_VECTOR (9 downto 0);
signal line_YB : STD_LOGIC_VECTOR (9 downto 0);

signal valueIncrementDrecrement : STD_LOGIC_VECTOR (9 downto 0);

signal sdout: std_logic_vector(7 downto 0);
signal srw:   std_logic;
signal saddr: std_logic_vector(7 downto 0);
signal sdin:  std_logic_vector(7 downto 0);
signal start:  std_logic;


begin

	hc05_lite:hc05 port map (clk,rst,sdout,srw,saddr,sdin,start);
	ram1:ram port map(clk,rst,srw,saddr,sdin,sdout);
--Processos clk e clk50 utilizados somente para diminuio da frequencia do clock
process (clk)
begin		
	if CLK'EVENT and CLK = '1' then
		if (start = '1') then
			if (clk50 = '0') then
				clk50 <= '1';
			else
				clk50 <= '0';
			end if;		
		end if;		
	end if;
end process;

process (clk50)
begin
	if clk50'event and clk50='1' then
		if (clk25 = '0') then
			clk25 <= '1';
		else
			clk25 <= '0';
		end if;
	end if;
end process;

process (clk25,rst)
variable printa: integer range 0 to 10; --Define a cor a ser usada
begin
	if rst = '1' then
	
	-- Sizes of Screen
		screenSize_horizontalA <= "0000000000"; -- 0 
		ScreenSize_horizontalB <= "1100001100"; -- 780 
		ScreenSize_verticalA <= "0000000000"; -- 0
		ScreenSize_verticalB <= "1000001000"; -- 520
		
		ScreenBoard_horizontalA <= "0010011011"; -- 155 --
		ScreenBoard_horizontalB <= "1011101110"; -- 750
		ScreenBoard_verticalA <= "0000010100"; -- 20 --
		ScreenBoard_verticalB <= "0111111110"; -- 510

	-- Initial Position  of the Ball
		ballPosition_XA <= "0010011100";  -- 156       
		ballPosition_XB <= "0010100110";  -- 166       
		ballPosition_YA <= "0000101000";  -- 40 
		ballPosition_YB <= "0000110010";  -- 50 	
	
	-- Initial Position of the player 
		playerPosition_XA <= "0010100101";  -- 165       
		playerPosition_XB <= "0010110100";  -- 180
		playerPosition_YA <= "0011011100";  -- 220       
		playerPosition_YB <= "0100001110";  -- 270       
		
		playerTwoPosition_XA <= "1011010101";  -- 725       
		playerTwoPosition_XB <= "1011100100";  -- 740
		playerTwoPosition_YA <= "0011011100";  -- 220       
		playerTwoPosition_YB <= "0100001110";  -- 270  
	
	-- Line of Game
		line_XA <= "0110111101";  -- 445
		line_XB <= "0111000111";  -- 455
		line_YA <= "0000010100";  -- 20
		line_YB <= "0111111110";  -- 510
		
	-- Value of Increment/Decrement
		valueIncrementDrecrement <= "0000000001";
		
		countButton <= 0; 
		count <= 0;
		v <= 0;
		h <= 0;		
		
	elsif clk25'event and clk25 = '1' then
		
		if (horizontal_counter >= screenSize_horizontalA ) and (horizontal_counter < ScreenSize_horizontalB ) and 
		   (vertical_counter >= ScreenSize_verticalA ) and (vertical_counter < ScreenSize_verticalB ) then 
				printa := 0;
			
			-- Board			
			if (horizontal_counter >= ScreenBoard_horizontalA) and (horizontal_counter < ScreenBoard_horizontalB) and
					(vertical_counter >= ScreenBoard_verticalA) and (vertical_counter < ScreenBoard_verticalB) then
						printa := 5; 
			end if;
			
			-- Line 
			if (horizontal_counter >= line_XA) and (horizontal_counter < line_XB) and
					(vertical_counter >= line_YA) and (vertical_counter < line_YB) then
						printa := 3; 
			end if;
			
			-- Player
			if (horizontal_counter >= playerPosition_XA) and (horizontal_counter < playerPosition_XB) and
					(vertical_counter >= playerPosition_YA) and (vertical_counter < playerPosition_YB) then
						printa := 3; 
			end if;
			
			if (horizontal_counter >= playerTwoPosition_XA) and (horizontal_counter < playerTwoPosition_XB) and
					(vertical_counter >= playerTwoPosition_YA) and (vertical_counter < playerTwoPosition_YB) then
						printa := 3; 
			end if;
			
			-- Ball
			if (horizontal_counter >= ballPosition_XA) and (horizontal_counter < ballPosition_XB) and
					(vertical_counter >= ballPosition_YA) and (vertical_counter < ballPosition_YB) then
						printa := 0; 
			end if;
			
			-- Colors of the Screen
			if printa = 0 then -- Black
				red_out <= '0';
				green_out <= '0';
				blue_out <= '0';
				
			elsif printa = 1 then -- Green
				red_out <= '0';
				green_out <= '1';
				blue_out <= '0';

			elsif printa = 2 then -- Yellow
				red_out <= '1';
				green_out <= '1';
				blue_out <= '0';

			elsif printa = 3 then -- Red
				red_out <= '1';
				green_out <= '0';
				blue_out <= '0';

			elsif printa = 4 then -- Blue
				red_out <= '0';
				green_out <= '0';
				blue_out <= '1';

			else  -- White
				red_out <= '1';
				green_out <= '1';
				blue_out <= '1';
			end if;
		end if;
		
		if (countButton = 100000) then
			if (up = '1') and (playerPosition_YA - valueIncrementDrecrement > ScreenBoard_verticalA) then
				playerPosition_YA <= playerPosition_YA - valueIncrementDrecrement;
				playerPosition_YB <= playerPosition_YB - valueIncrementDrecrement;
			end if;
			
			if (left = '1') and (playerPosition_YB + valueIncrementDrecrement < ScreenBoard_verticalB) then
				playerPosition_YA <= playerPosition_YA + valueIncrementDrecrement;
				playerPosition_YB <= playerPosition_YB + valueIncrementDrecrement;
			end if;
			
			if (right = '1') and (playerTwoPosition_YA - valueIncrementDrecrement > ScreenBoard_verticalA) then
				playerTwoPosition_YA <= playerTwoPosition_YA - valueIncrementDrecrement;
				playerTwoPosition_YB <= playerTwoPosition_YB - valueIncrementDrecrement;
			end if;
			
			if (down = '1') and (playerTwoPosition_YB + valueIncrementDrecrement < ScreenBoard_verticalB) then
				playerTwoPosition_YA <= playerTwoPosition_YA + valueIncrementDrecrement;
				playerTwoPosition_YB <= playerTwoPosition_YB + valueIncrementDrecrement;
			end if;
			
			countButton <= 0;
		end if;
		
		if (count = 100000) then

			if (v = 0) then
				 ballPosition_YA <= ballPosition_YA + valueIncrementDrecrement;
				 ballPosition_YB <= ballPosition_YB + valueIncrementDrecrement;
			else
				 ballPosition_YA <= ballPosition_YA - valueIncrementDrecrement;
				 ballPosition_YB <= ballPosition_YB - valueIncrementDrecrement;
			end if;

			if (h = 1) then
				 ballPosition_XA <= ballPosition_XA - valueIncrementDrecrement;
				 ballPosition_XB <= ballPosition_XB - valueIncrementDrecrement;
			else
				 ballPosition_XA <= ballPosition_XA + valueIncrementDrecrement;
				 ballPosition_XB <= ballPosition_XB + valueIncrementDrecrement;
			end if;
			count <= 0;
		end if;	
		
		count <= count + 1;
		countButton <= countButton + 1;
		
		if (ballPosition_YA - valueIncrementDrecrement < ScreenBoard_verticalA) and (v = 1) then
			v <= 0;
		end if;
		
		if (ballPosition_XA - valueIncrementDrecrement = ScreenBoard_horizontalA) and (h = 1) then
			ballPosition_XA <= "0110111101";       
			ballPosition_XB <= "0111000111";       
			ballPosition_YA <= "0011011100";
			ballPosition_YB <= "0011100110";
		end if;
		
		if (ballPosition_YB + valueIncrementDrecrement > ScreenBoard_verticalB) and (v = 0) then
			v <= 1;
		end if;

		if (ballPosition_YA - valueIncrementDrecrement <= playerPosition_YB) and (ballPosition_YA - valueIncrementDrecrement >= playerPosition_YA) and
		(ballPosition_XA - valueIncrementDrecrement <= playerPosition_XB) and (h = 1) then
			h <= 0;
		end if;
			
		if (ballPosition_YA - valueIncrementDrecrement <= playerTwoPosition_YB) and (ballPosition_YA - valueIncrementDrecrement >= playerTwoPosition_YA) and
		(ballPosition_XB - valueIncrementDrecrement >= playerTwoPosition_XA) and (h = 0) then
			h <= 1;
		end if;
		
		if (ballPosition_XB + valueIncrementDrecrement > ScreenBoard_horizontalB) and (h = 0) then			
			ballPosition_XA <= "0110111101";       
			ballPosition_XB <= "0111000111";       
			ballPosition_YA <= "0011011100";
			ballPosition_YB <= "0011100110";
		end if;
		

       -- Trecho de cdigo abaixo para varredura de tela // DONT CHANGE!!

		if (horizontal_counter > "0000000000")	and (horizontal_counter < "0001100001") then --96+1
			hs_out <= '0';
		else
			hs_out <= '1';
		end if;
		
		if (vertical_counter > "0000000000" )and (vertical_counter < "0000000011" ) then -- 2+1
			vs_out <= '0';
		else
			vs_out <= '1';
		end if;

		horizontal_counter <= horizontal_counter+"0000000001";
	
		if (horizontal_counter="1100001011") then
			vertical_counter <= vertical_counter+"0000000001";
			horizontal_counter <= "0000000000";
		end if;
		
		if (vertical_counter="1000000111") then
			vertical_counter <= "0000000000";
		end if;
	end if;
	
end process;

end Behavioral;

