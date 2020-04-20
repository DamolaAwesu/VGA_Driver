library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
--use work.patterns.all;

------------------------- Entity Declaration ----------------------------
Entity Sync_Counter IS
Port(
clk: in std_logic;
reset: in std_logic;
sw: in std_logic_vector(3 downto 0);
hsync, vsync : out std_logic;
--clk_out : out std_logic;
r,g,b : out std_logic_vector(3 downto 0)
);
end Sync_Counter;

------------------- Architecture of Sync Entity -------------------------
Architecture Main of Sync_Counter is
----------------------------------------------------
signal hpos : INTEGER range 0 to 799;
signal vpos : INTEGER range 0 to 524;
signal clk_25 : std_logic := '0';
signal display_en: std_logic := '0';
signal pix_addr: std_logic_vector(9 downto 0) := "0000000000";
signal pix_data: std_logic_vector(11 downto 0);
signal lun_pix_addr: std_logic_vector(9 downto 0) := "0000000000";
signal lun_pix_data: std_logic_vector(11 downto 0);
constant ter_x: INTEGER := 300;
constant ter_y: INTEGER := 240;
constant lun_x: INTEGER := 400;
constant lun_y: INTEGER := 340;

constant HFP: INTEGER := 16;
constant HSP: INTEGER := 96;
constant HBP: INTEGER := 48;
constant HDP: INTEGER := 639;
constant HSBP: INTEGER := 144;
constant HSBDP: INTEGER := 783;

constant VFP: INTEGER := 10;
constant VSP: INTEGER := 2;
constant VBP: INTEGER := 33;
constant VDP: INTEGER := 479;
constant VSBP: INTEGER := 35;
constant VSBDP: INTEGER := 514;
-----------------------------------------------------
Component rom_terre is
Port(
		address		: in std_logic_vector (9 DOWNTO 0);
		clock		: in std_logic  := '1';
		q		: out std_logic_vector (11 DOWNTO 0)
	);
end Component rom_terre;
-------------------------------------------------------
Component rom_lune is
Port(
		address		: in std_logic_vector (9 DOWNTO 0);
		clock		: in std_logic  := '1';
		q		: out std_logic_vector (11 DOWNTO 0)
	);
end Component rom_lune;
-------------------------------------------------------
begin
R1: rom_terre port map(pix_addr, clk_25, pix_data);
R2: rom_lune port map(lun_pix_addr, clk_25, lun_pix_data);
-------------------- 25MHz Clock Generator --------------------
clock_25:process(clk, reset)
begin
	if (reset = '0') then
		clk_25 <= '0';
	elsif(clk'event and clk = '1') then
		clk_25 <= not clk_25;
	end if;
end process;
--clk_out <= clk_25;
-------------- Horizontal and Vertical Sync Signal Process ---------------
counter:process(clk_25)
begin
----------- Position Counter ------------
	if (clk_25'event and clk_25 = '1') then
		if(hpos < 799)then
			hpos <= hpos + 1;
		else
			hpos <= 0;
			if(vpos < 524) then
				vpos <= vpos + 1;
			else
				vpos <= 0;
			end if;
		end if;
---------- Sync Signals Generator ----------		
		if ((hpos >= 0) and (hpos < HSP)) then
			hsync <= '0';
		else
			hsync <= '1';
		end if;
		
		if ((vpos >= 0) and (vpos < VSP)) then
			vsync <= '0';
		else
			vsync <= '1';
		end if;
	end if;	
end process;
-------------------- Enabling Display Function -------------------------
color_out:process(clk_25, hpos, vpos)
begin
	if(clk_25'event and clk_25 = '1') then
		if((hpos >= (HSP + HBP)) and (hpos <= (HSP + HBP + HDP))) then
			if((vpos >= (VSP + VBP)) and (vpos <= (VSP + VBP + VDP))) then
				display_en <= '1';
			else
				display_en <= '0';
			end if;
		else
			display_en <= '0';
		end if;
	end if;
end process;
-----------------------------------------------------------------------
display:process(clk_25, display_en, sw, hpos)
begin
	if(clk_25'event and clk_25 = '1')then
		if(display_en = '1')then
			if(sw(0) = '1')then
				r <= (others => '1');
				g <= (others => '0');
				b <= (others => '0');			
			elsif(sw(1) = '1')then
				if(hpos >= HSBP and hpos < HSBP+160)then
					r <= (others => '1');
					g <= (others => '0');
					b <= (others => '0');
				elsif(hpos >= (HSBP+160) and hpos < (HSBP+320))then
					r <= (others => '0');
					g <= (others => '1');
					b <= (others => '0');
				elsif(hpos >= (HSBP+320) and hpos < (HSBP+480))then
					r <= (others => '0');
					g <= (others => '0');
					b <= (others => '1');
				elsif(hpos >= (HSBP+480) and hpos < HSBDP)then
					r <= (others => '1');
					g <= (others => '1');
					b <= (others => '1');
				else
					r <= (others => '0');
					g <= (others => '0');
					b <= (others => '0');
				end if;
			elsif(sw(2) = '1') then
				if(vpos > ter_y and vpos <= (ter_y+32))then
					if(hpos > ter_x and hpos <= (ter_x+32))then
						pix_addr <= pix_addr + 1;
						r <= pix_data(3 downto 0);
						g <= pix_data(7 downto 4);
						b <= pix_data(11 downto 8);
					else
						--pix_addr <= (others => '0');
						r <= (others => '0');
						g <= (others => '0');
						b <= (others => '0');
					end if;
				elsif(vpos > lun_y and vpos <= (lun_y+32))then
					if(hpos > lun_x and hpos <= (lun_x+32))then
						lun_pix_addr <= lun_pix_addr + 1;
						r <= lun_pix_data(3 downto 0);
						g <= lun_pix_data(7 downto 4);
						b <= lun_pix_data(11 downto 8);
					else
						--lun_pix_addr <= (others => '0');
						r <= (others => '0');
						g <= (others => '0');
						b <= (others => '0');
					end if;
				else
					pix_addr <= (others => '0');
					lun_pix_addr <= (others => '0');
					r <= (others => '0');
					g <= (others => '0');
					b <= (others => '0');
				end if;	
			else
				r <= (others => '0');
				g <= (others => '0');
				b <= (others => '0');
			end if;
		else
			r <= (others => '0');
			g <= (others => '0');
			b <= (others => '0');
		end if;
	end if;
end process;
-------------------------------------------------------------
image_position: process(clk_25)
begin


end process;
-------------------------------------------------------------
end Main;
-----------------------------------------------------------------------