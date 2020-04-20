library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;

Entity VGA_Test is
end VGA_Test;

Architecture Main of VGA_Test is
signal clock_main: std_logic;
--signal clk_pix: std_logic;
signal res: std_logic;
signal hs, vs : std_logic;
signal switch: std_logic_vector(3 downto 0);
signal data: std_logic_vector(3 downto 0);
signal red, green, blue : std_logic_vector(3 downto 0);
constant colon: string := ":";
Component VGA_Driver is
Port(
clk_main: in std_logic;
rst: in std_logic;
selector: in std_logic_vector(3 downto 0);
Hsync, Vsync: out std_logic;
--pix_clk: out std_logic;
VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0)
);
end Component;

begin
U1: VGA_Driver port map(clock_main, res, switch, hs, vs, red, green, blue);

res <= '0', '1' after 10 ns;
switch(2) <= '0', '1' after 40 ns;

--process (clk_pix)
--
--file file_pointer: text open WRITE_MODE is "write.txt";
--variable line_el: line;
--
--begin
--
--	if rising_edge(clk_pix) then
--	  -- Write the time
--		write(line_el, now, left); -- write the line.
--		write(line_el, colon, right, 0);
--		write(line_el, hs, right, 2); -- write the line.
--		write(line_el, vs, right, 2);
--		write(line_el, red, right, 5);
--		write(line_el, green, right, 5);
--		write(line_el, blue, right, 5);
--	
--		writeline(file_pointer, line_el); -- write the contents into the file.
--	end if;
--end process;

end Main;