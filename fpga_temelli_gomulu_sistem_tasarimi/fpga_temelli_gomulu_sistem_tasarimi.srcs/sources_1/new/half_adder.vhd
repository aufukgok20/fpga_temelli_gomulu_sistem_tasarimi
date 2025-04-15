----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.04.2025 23:02:45
-- Design Name: 
-- Module Name: half_adder - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity half_adder is
Port (
a_i     : in  std_logic ;
b_i     : in  std_logic ;
sum_o   : out std_logic ;
carry_o : out std_logic 
);
end half_adder;

architecture Behavioral of half_adder is

begin

sum_o   <= a_i xor b_i;
carry_o <= a_i and b_i;
end Behavioral;
