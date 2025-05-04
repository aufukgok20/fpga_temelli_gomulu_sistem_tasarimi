----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.05.2025 16:07:19
-- Design Name: 
-- Module Name: mux2x1 - Behavioral
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

entity mux2x1 is
Port (
a_i  : in std_logic;
b_i  : in std_logic;
s1_i : in std_logic;
c_i  : in std_logic;
d_i  : in std_logic;
s2_i : in std_logic;
e_i  : in std_logic;
f_i  : in std_logic;
s3_i : in std_logic;
q1_o : out std_logic;
q2_o : out std_logic;
q3_o : out std_logic   
);
end mux2x1;

architecture Behavioral of mux2x1 is

signal temp_1 :std_logic := '0';
signal temp_2 :std_logic := '0';

begin

------------------------------------------------------------
-- GATE LEVEL COMBINATIONAL DESIGN
------------------------------------------------------------
temp_1 <= not (a_i and s1_i);
temp_2 <= not ((not s1_i) and b_i); 
q1_o   <= (temp_1 and temp_2);

------------------------------------------------------------
-- CONCURRENT ASSIGNMENT  COMBINATIONAL DESIGN
------------------------------------------------------------
q2_o <= c_i when s2_i = '0' else
            d_i;
            
------------------------------------------------------------
-- PROCESS  COMBINATIONAL DESIGN
------------------------------------------------------------
P_LABEL : process (s3_i, e_i, f_i) begin

    if (s3_i = '1') then
        q3_o <= e_i;
    else
        q3_o <= f_i;
    end if;
end process P_LABEL;

end Behavioral;
