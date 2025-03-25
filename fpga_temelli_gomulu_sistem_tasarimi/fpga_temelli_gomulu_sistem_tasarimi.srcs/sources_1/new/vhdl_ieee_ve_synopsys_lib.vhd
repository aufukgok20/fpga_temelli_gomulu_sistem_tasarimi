library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

--NUMERIC_STD yerine asagidaki kutuphaneler kullanilirsa + gibi operatorler kullanilabilir.
-- use IEEE.STD_LOGIC_ARITH.ALL;
-- use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity vhdl_ieee_ve_synopsys_lib is
Port (
 s0_i : in  std_logic_vector(7 downto 0);
 s1_i : in  std_logic_vector(7 downto 0);
 s0_o : out std_logic
 );
end vhdl_ieee_ve_synopsys_lib;

architecture Behavioral of vhdl_ieee_ve_synopsys_lib is

signal s0 : std_logic_vector(7 downto 0) := x"00";
--signal s1 : unsigned(7 downto 0)         := x"00";
--signal s2 : std_logic_vector(7 downto 0) := x"00";

begin

s0 <= std_logic_vector(unsigned(s0_i) + unsigned(s1_i));
--s1 <= unsigned(s0_i) + unsigned(s1_i);
--s2 <= s0_i + s1_i;

process (s0) begin

    if(unsigned(s0) > 20) then
        s0_o <= '1';
    else
        s0_o <= '0';
    end if;
    
end process;

--process (s1) begin
    
--    if(s1 > 20) then
--        s0_o <= '1';
--    else
--        s0_o <= '0';
--    end if;
    
--end process;

--process (s2) begin
    
--    if(s2 > 20) then
--        s0_o <= '1';
--    else
--        s0_o <= '0';
--    end if;
    
--end process;


end Behavioral;