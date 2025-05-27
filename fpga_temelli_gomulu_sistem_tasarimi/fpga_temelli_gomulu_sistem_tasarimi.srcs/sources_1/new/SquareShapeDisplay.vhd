----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.05.2025 00:21:23
-- Design Name: 
-- Module Name: SquareShapeDisplay - Behavioral
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SquareShapeDisplay is
	 Generic (
			  X_START : integer range 100 to (Integer'high) := 600;
              Y_START : integer := 500
	 );
    Port ( CLK_I : in  STD_LOGIC;
           H_COUNT_I : in  STD_LOGIC_VECTOR(11 downto 0);
           V_COUNT_I : in  STD_LOGIC_VECTOR(11 downto 0);
           RED_O : out  STD_LOGIC_VECTOR(3 downto 0);
           BLUE_O : out  STD_LOGIC_VECTOR(3 downto 0);
           GREEN_O : out  STD_LOGIC_VECTOR(3 downto 0));
end SquareShapeDisplay;

architecture Behavioral of SquareShapeDisplay is

constant SZ_SQUARE_WIDTH 	: natural := 500; -- Width of the SQUARE frame
constant SZ_SQUARE_HEIGHT 	: natural := 500; -- Height of the SQUARE frame

signal douta	: std_logic_vector(11 downto 0);
signal rst		: std_logic;
signal en		: std_logic;

begin


-- Restart Address Counter when Vcount arrives to the beginning of the Logo frame
rst <= '1' when (H_COUNT_I = 0 and V_COUNT_I = Y_START-1) else '0';

-- Increment Address counter only inside the frame
en <= '1' when (H_COUNT_I > X_START-2 and H_COUNT_I < X_START + SZ_SQUARE_WIDTH - 1 
            and V_COUNT_I > Y_START and V_COUNT_I < Y_START + SZ_SQUARE_HEIGHT -1 ) 
          else '0';

-- Address counter
process (CLK_I, rst, en)
begin
	if(rising_edge(CLK_I))then 
		if(rst = '1') then
			douta <= (others => '0');
		elsif(en = '1') then
			douta <= douta + 1;
		end if;
	end if;	

end process;

-- Assign Outputs
RED_O <= douta(11 downto 8);
BLUE_O <= douta(3 downto 0);
GREEN_O <= douta(7 downto 4);


end Behavioral;