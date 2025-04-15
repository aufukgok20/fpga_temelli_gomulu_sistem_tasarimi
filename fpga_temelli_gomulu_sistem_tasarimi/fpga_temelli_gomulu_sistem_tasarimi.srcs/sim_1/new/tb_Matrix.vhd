
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_Matrix is
    generic (
        c_clkfreq   : INTEGER := 100_000_000
    );
--  Port ( );
end tb_Matrix;

architecture Behavioral of tb_Matrix is

component Matrix is
    generic (
        c_clkfreq   : INTEGER := 100_000_000
    );
    Port (
        clk            : in  STD_LOGIC;
        row_col_select : in  STD_LOGIC; --Row? Column?
        row_sel        : in  STD_LOGIC_VECTOR(1 downto 0);
        col_sel        : in  STD_LOGIC_VECTOR(1 downto 0);
        anodes_o	   : out std_logic_vector(7 downto 0);
        seven_seg_o	   : out std_logic_vector (7 downto 0)
    );
end component;

signal sign_clk            : STD_LOGIC;                   
signal sign_row_col_select : STD_LOGIC;   
signal sign_row_sel        : STD_LOGIC_VECTOR(1 downto 0);
signal sign_col_sel        : STD_LOGIC_VECTOR(1 downto 0);
signal sign_anodes_o	   : std_logic_vector(7 downto 0);     
signal sign_seven_seg_o	   : std_logic_vector (7 downto 0);

constant c_clkperiod	: time := 10 ns;

begin

DUT_Matrix: Matrix
    generic map(
        c_clkfreq => c_clkfreq
    )
    port map(
        clk            => sign_clk           ,
        row_col_select => sign_row_col_select,
        row_sel        => sign_row_sel       ,
        col_sel        => sign_col_sel       ,
        anodes_o	   => sign_anodes_o	     ,
        seven_seg_o	   => sign_seven_seg_o	  
    );



P_CLKGEN : process begin
sign_clk	<= '0';
wait for c_clkperiod/2;
sign_clk	<= '1';
wait for c_clkperiod/2;
end process;

process
begin

sign_row_col_select <= '0';
sign_row_sel        <= "11";
sign_col_sel        <= "11";
wait for c_clkperiod*5;

sign_row_col_select <= '1';
wait for c_clkperiod;
sign_row_sel        <= "00";
wait for c_clkperiod;

sign_row_col_select <= '0';
wait for c_clkperiod;
sign_col_sel        <= "00";
wait for c_clkperiod;

sign_row_col_select <= '1';
wait for c_clkperiod;
sign_row_sel        <= "01";
wait for c_clkperiod;

sign_row_col_select <= '0';
wait for c_clkperiod;
sign_col_sel        <= "01";
wait for c_clkperiod;

sign_row_col_select <= '1';
wait for c_clkperiod;
sign_row_sel        <= "10";
wait for c_clkperiod;

sign_row_col_select <= '0';
wait for c_clkperiod;
sign_col_sel        <= "10";
wait for c_clkperiod;

sign_row_col_select <= '1';
wait for c_clkperiod;
sign_row_sel        <= "11";
wait for c_clkperiod;

sign_row_col_select <= '0';
wait for c_clkperiod;
sign_col_sel        <= "11";
wait for c_clkperiod;

wait for c_clkperiod*5;

assert false
report "SIM DONE"
severity failure;


end process;
end Behavioral;
