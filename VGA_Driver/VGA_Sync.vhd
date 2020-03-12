library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

Entity Sync_Counter IS
Port(
clk: in std_logic;
reset: in std_logic;
sw: in std_logic_vector(1 downto 0);
btn: in std_logic_vector(3 downto 0);
hsync, vsync : out std_logic;
r,g,b : out std_logic_vector(3 downto 0)
);
end Sync_Counter;

Architecture Main of Sync_Counter is
----------------------------------------------------
signal hpos : INTEGER range 0 to 799;
signal vpos : INTEGER range 0 to 524;
signal clk_25 : std_logic := '0';
signal display_en: std_logic := '0';

constant HFP: INTEGER := 16;
constant HSP: INTEGER := 96;
constant HBP: INTEGER := 48;
constant HDP: INTEGER := 639;

constant VFP: INTEGER := 2;
constant VSP: INTEGER := 33;
constant VBP: INTEGER := 10;
constant VDP: INTEGER := 479;
----------------------------------------------------
begin

clock_25:process(clk, reset)
begin
	if (reset = '1') then
		clk_25 <= '0';
	elsif(clk'event and clk = '1') then
		clk_25 <= not clk_25;
	end if;
end process;

counter:process(clk_25)
begin
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
		
		if ((hpos > HFP) and (hpos <= (HFP + HSP))) then
			hsync <= '0';
		else
			hsync <= '1';
		end if;
		
		if ((vpos > VFP) and (vpos <= (VFP + VSP))) then
			vsync <= '0';
		else
			vsync <= '1';
		end if;
	end if;	
end process;

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

display:process(display_en)
begin
	if(display_en = '1')then
		r <= (others => '1');
		g <= (others => '1');
		b <= (others => '1');
	else
		r <= (others => '0');
		g <= (others => '0');
		b <= (others => '0');
	end if;
end process;
end Main;