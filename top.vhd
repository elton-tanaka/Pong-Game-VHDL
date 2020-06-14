LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY top IS 
port (
      clk: in std_logic;
	  rst: in std_logic
	  --enter: in std_logic;  -- switch (6)
	  --dado: in std_logic_vector(3 downto 0); --switch(3:0)
);
END top;

architecture arch_top of top is
-- componentes
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

component vga
port(
	clk : in  STD_LOGIC;
    rst : in  STD_LOGIC;
	red_out : out STD_LOGIC;
	green_out : out STD_LOGIC;
	blue_out : out STD_LOGIC;
	hs_out : out STD_LOGIC;
	vs_out : out STD_LOGIC
);
END component;

--sinais
 signal sdout: std_logic_vector(7 downto 0);
 signal srw:   std_logic;
 signal	saddr: std_logic_vector(7 downto 0);
 signal	sdin:  std_logic_vector(7 downto 0);

signal cont: integer range 0 to 100000001;
signal clk_retardo: std_logic;

begin

-- implementao em FPGA.
--hc05_lite:hc05 port map (clk_retardo,rst,sdout,enter,dado,srw,saddr,sdin,led);
--ram1:ram port map(clk_retardo,rst,srw,saddr,sdin,sdout);

-- simulao
hc05_lite:hc05 port map (clk_retardo,rst,sdout,srw,saddr,sdin);
ram1:ram port map(clk_retardo,rst,srw,saddr,sdin,sdout);

-- divisor de clock (1Hz)
process (clk,rst)
begin
     if rst='1' then
	     cont <= 0;
	 elsif clk'event and clk='1' then
	     cont <= cont +1;
	     if cont <= 50000000 then --0,5s
		     clk_retardo <= '0';
		 else
		     clk_retardo <= '1';   -- 1s
		 end if;
		 if cont = 100000000 then
		     cont <= 0;
		 end if;
	 end if;
	 
end process;


end arch_top;