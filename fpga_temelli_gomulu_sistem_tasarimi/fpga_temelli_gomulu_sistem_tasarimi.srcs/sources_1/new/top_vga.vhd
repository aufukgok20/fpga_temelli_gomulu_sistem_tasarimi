----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 25.05.2025 21:34:11
-- Design Name: 
-- Module Name: top_vga - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Nexys4DdrUserDemo is
   port(
      clk_i          : in  std_logic;
      rstn_i         : in  std_logic;
      -- VGA display
      vga_hs_o       : out std_logic;
      vga_vs_o       : out std_logic;
      vga_red_o      : out std_logic_vector(3 downto 0);
      vga_blue_o     : out std_logic_vector(3 downto 0);
      vga_green_o    : out std_logic_vector(3 downto 0)
   );
end Nexys4DdrUserDemo;

architecture Behavioral of Nexys4DdrUserDemo is

----------------------------------------------------------------------------------
-- Component Declarations
----------------------------------------------------------------------------------  

-- 200 MHz Clock Generator
component ClkGen
port
 (-- Clock in ports
  clk_100MHz_i           : in     std_logic;
  -- Clock out ports
  clk_100MHz_o          : out    std_logic;
  clk_200MHz_o          : out    std_logic;
  -- Status and control signals
  reset_i             : in     std_logic;
  locked_o            : out    std_logic
 );
end component;

COMPONENT vga is
PORT( 
   clk_i          : in  std_logic;
   vga_hs_o       : out std_logic;
   vga_vs_o       : out std_logic;
   vga_red_o      : out std_logic_vector(3 downto 0);
   vga_blue_o     : out std_logic_vector(3 downto 0);
   vga_green_o    : out std_logic_vector(3 downto 0)
   );
END COMPONENT;

----------------------------------------------------------------------------------
-- Signal Declarations
----------------------------------------------------------------------------------  
-- Inverted input reset signal
signal rst        : std_logic;
-- Reset signal conditioned by the PLL lock
signal reset      : std_logic;
signal resetn     : std_logic;
signal locked     : std_logic;

-- 100 MHz buffered clock signal
signal clk_100MHz_buf : std_logic;
-- 200 MHz buffered clock signal
signal clk_200MHz_buf : std_logic;

-- pdm_clk and pdm_clk_rising are needed by the VGA controller
-- to display incoming microphone data
signal pdm_clk : std_logic;
signal pdm_clk_rising : std_logic;


begin
   

   -- The Reset Button on the Nexys4 board is active-low,
   -- however many components need an active-high reset
   rst <= not rstn_i;

   -- Assign reset signals conditioned by the PLL lock
   reset <= rst or (not locked);
   -- active-low version of the reset signal
   resetn <= not reset;

----------------------------------------------------------------------------------
-- 200MHz Clock Generator
----------------------------------------------------------------------------------
   Inst_ClkGen: ClkGen
   port map (
      clk_100MHz_i   => clk_i,
      clk_100MHz_o   => clk_100MHz_buf,
      clk_200MHz_o   => clk_200MHz_buf,
      reset_i        => rst,
      locked_o       => locked
      );

----------------------------------------------------------------------------------
-- VGA Controller
----------------------------------------------------------------------------------
   Inst_VGA: vga
   port map(
      clk_i          => clk_100MHz_buf,
      vga_hs_o       => vga_hs_o,
      vga_vs_o       => vga_vs_o,
      vga_red_o      => vga_red_o,
      vga_blue_o     => vga_blue_o,
      vga_green_o    => vga_green_o
      );  
end Behavioral;
