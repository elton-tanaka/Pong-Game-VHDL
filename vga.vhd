library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vga is
    Port (    clk : in  STD_LOGIC;
              rst : in  STD_LOGIC;
			  red_out : out STD_LOGIC;
			  green_out : out STD_LOGIC;
			  blue_out : out STD_LOGIC;
			  hs_out : out STD_LOGIC;
			  vs_out : out STD_LOGIC
			);
end vga;

component hc05  
port (
      clk: in std_logic;
	  rst: in std_logic;
	  dout: in std_logic_vector(7 downto 0);
	 -- enter: in std_logic;  -- switch (6)
	 -- dado: in std_logic_vector(3 downto 0); --switch(3:0)
	  rw: out std_logic;
	  addr: out std_logic_vector(7 downto 0);
	  din: out std_logic_vector(7 downto 0);
	  led: out std_logic_vector(7 downto 0)
);
END component;

architecture Behavioral of vga is

signal clk50, clk25 		: STD_LOGIC;
signal horizontal_counter   : STD_LOGIC_VECTOR (9 downto 0);
signal vertical_counter     : STD_LOGIC_VECTOR (9 downto 0);

signal Ver_top_A   			: STD_LOGIC_VECTOR (9 downto 0);
signal Ver_top_B   			: STD_LOGIC_VECTOR (9 downto 0);
signal Hor_top_A 			: STD_LOGIC_VECTOR (9 downto 0);
signal Hor_top_B 			: STD_LOGIC_VECTOR (9 downto 0);

signal Ver_esq_A   			: STD_LOGIC_VECTOR (9 downto 0);
signal Ver_esq_B   			: STD_LOGIC_VECTOR (9 downto 0);
signal Hor_esq_A 			: STD_LOGIC_VECTOR (9 downto 0);
signal Hor_esq_B 			: STD_LOGIC_VECTOR (9 downto 0);

signal Ver_dir_A   			: STD_LOGIC_VECTOR (9 downto 0);
signal Ver_dir_B   			: STD_LOGIC_VECTOR (9 downto 0);
signal Hor_dir_A 			: STD_LOGIC_VECTOR (9 downto 0);
signal Hor_dir_B 			: STD_LOGIC_VECTOR (9 downto 0);

signal Ver_bai_A   			: STD_LOGIC_VECTOR (9 downto 0);
signal Ver_bai_B   			: STD_LOGIC_VECTOR (9 downto 0);
signal Hor_bai_A 			: STD_LOGIC_VECTOR (9 downto 0);
signal Hor_bai_B 			: STD_LOGIC_VECTOR (9 downto 0);
signal count 		 		: INTEGER range 0 to 50000001;

signal sdout: std_logic_vector(7 downto 0);
signal srw:   std_logic;
signal saddr: std_logic_vector(7 downto 0);
signal sdin:  std_logic_vector(7 downto 0); 

begin

hc05_lite:hc05 port map (clk50,rst,sdout,srw,saddr,sdin);
--Processos clk e clk50 utilizados somente para diminuio da frequencia do clock

process (clk)
begin		
	if CLK'EVENT and CLK = '1' then
		if (clk50 = '0') then
			clk50 <= '1';
		else
			clk50 <= '0';
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
	  -- Posio da tela onde o quadrado ser pintado
	--Topo
		Ver_top_A <= "0011011100"; --220          
		Ver_top_B <= "0011110000"; -- 240
		Hor_top_A <= "0101111100"; -- 380
		Hor_top_B <= "0110010000"; -- 400	
		
	--Esquerda
		Ver_esq_A <= "0011100110"; --230          
		Ver_esq_B <= "0011111010"; -- 250
		Hor_esq_A <= "0101101000"; -- 360
		Hor_esq_B <= "0101111011"; -- 379	

	--Direita
		Ver_dir_A <= "0011100110"; --230          
		Ver_dir_B <= "0011111010"; -- 250
		Hor_dir_A <= "0110010001"; -- 401
		Hor_dir_B <= "0110100100"; -- 420	

	--Baixo
		Ver_bai_A <= "0011110001"; --241          
		Ver_bai_B <= "0100000100"; -- 260
		Hor_bai_A <= "0101111100"; -- 380
		Hor_bai_B <= "0110010000"; -- 400	
		
		count <= 0;
		
		
	elsif clk25'event and clk25 = '1' and sdin = '1' then
		--Indica a dimenso da tela
		if (horizontal_counter >= "0001111000" ) and (horizontal_counter < "1100001100" ) and -- 120 e 780 
		   (vertical_counter >= "0000101000" ) and (vertical_counter < "1000001000" ) then -- 40 e 520
				printa := 0; --Fundo ser pintado de preto
			
			--Comparaes para determinar que o quadrado deve ser pintado neste local
			if (horizontal_counter >= Hor_top_A) and (horizontal_counter < Hor_top_B) and
					(vertical_counter >= Ver_top_A) and (vertical_counter < Ver_top_B) then
						printa := 1; --Quadrado de verde
			end if; 
			if (horizontal_counter >= Hor_esq_A) and (horizontal_counter < Hor_esq_B) and
					(vertical_counter >= Ver_esq_A) and (vertical_counter < Ver_esq_B) then
						printa := 2; --Quadrado de amarelo
			end if;
			if (horizontal_counter >= Hor_dir_A) and (horizontal_counter < Hor_dir_B) and
					(vertical_counter >= Ver_dir_A) and (vertical_counter < Ver_dir_B) then
						printa := 3; --Quadrado de vermelho
			end if;
			if (horizontal_counter >= Hor_bai_A) and (horizontal_counter < Hor_bai_B) and
					(vertical_counter >= Ver_bai_A) and (vertical_counter < Ver_bai_B) then
						printa := 4; --Quadrado de azul
			end if;
			
			if printa = 0 then
				red_out <= '0';
				green_out <= '0';
				blue_out <= '0';
				
			elsif printa = 1 then
				red_out <= '0';
				green_out <= '1';
				blue_out <= '0';

			elsif printa = 2 then
				red_out <= '1';
				green_out <= '1';
				blue_out <= '0';

			elsif printa = 3 then
				red_out <= '1';
				green_out <= '0';
				blue_out <= '0';

			elsif printa = 4 then
				red_out <= '0';
				green_out <= '0';
				blue_out <= '1';
			else
				red_out <= '1';
				green_out <= '1';
				blue_out <= '1';
			end if;
		end if;
		
--Trecho de codigo abaixo para varredura de tela
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

