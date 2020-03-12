library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

Entity VGA_Driver IS
Port(
clk_main: in std_logic;
rst: in std_logic;
selector: in std_logic_vector(1 downto 0);
direction: in std_logic_vector(3 downto 0);
Hsync, Vsync: out std_logic;
VGA_R, VGA_G, VGA_B : out std_logic_vector(3 downto 0)
);
end VGA_Driver;


Architecture Main of VGA_Driver is
-----------------------------------------
Component Sync_Counter is
Port(
clk: in std_logic;
reset: in std_logic;
sw: in std_logic_vector(1 downto 0);
btn: in std_logic_vector(3 downto 0);
hsync, vsync : out std_logic;
r,g,b : out std_logic_vector(3 downto 0)
);
end Component Sync_Counter;
------------------------------------------
begin
C1: Sync_Counter port map(clk_main, rst, selector, direction, Hsync, Vsync, VGA_R, VGA_G, VGA_B);

end Main;