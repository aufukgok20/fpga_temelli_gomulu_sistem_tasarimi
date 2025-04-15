----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.04.2025 23:06:39
-- Design Name: 
-- Module Name: full_adder - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity full_adder is
Port (
a_i     : in  std_logic ;
b_i     : in  std_logic ;
carry_i : in  std_logic ;
sum_o   : out std_logic ;
carry_o : out std_logic 
);
end full_adder;

architecture Behavioral of full_adder is

-- COMPONENET DECLERATION
component half_adder is
port(
a_i     : in  std_logic ;
b_i     : in  std_logic ;
sum_o   : out std_logic ;
carry_o : out std_logic 
);
end component half_adder;

-- SIGNAL 
signal first_sum    : std_logic := '0';
signal first_carry  : std_logic := '0';
signal second_carry : std_logic := '0';

begin

-- COMPONENT INSTANTIATION
first_half_adder : half_adder
port map(
a_i     => a_i,
b_i     => b_i,
sum_o   => first_sum,
carry_o => first_carry
);

second_half_adder : half_adder
port map(
a_i     => first_sum,
b_i     => carry_i,
sum_o   => sum_o,
carry_o => second_carry
);

-- CONCURRENT SIGNAL ASSIGNMENTS
carry_o <= first_carry or second_carry;

end Behavioral;
