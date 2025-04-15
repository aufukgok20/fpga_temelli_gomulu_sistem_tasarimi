
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_num_comp is
    generic (
        c_clkfreq   : INTEGER := 100_000_000;
        c_data_width : INTEGER := 8
    );
--  Port ( );
end tb_num_comp;

architecture Behavioral of tb_num_comp is

component num_comp is
    generic (
        c_clkfreq   : INTEGER := 100_000_000;
        c_data_width : INTEGER := 8
    );
    Port (
        clk         : in STD_LOGIC;
        result_max  : in  STD_LOGIC;
        result_mid  : in  STD_LOGIC;
        result_min  : in  STD_LOGIC;
        anodes_o	: out  std_logic_vector (7 downto 0);
        seven_seg_o	: out std_logic_vector (7 downto 0)
    );
end component;

signal sign_clk         : STD_LOGIC := '0';                         
signal sign_result_max  : STD_LOGIC;
signal sign_result_mid  : STD_LOGIC;
signal sign_result_min  : STD_LOGIC;
signal sign_anodes_o	: STD_LOGIC_VECTOR (7 downto 0);               
signal sign_seven_seg_o : STD_LOGIC_VECTOR (7 downto 0);           


constant c_clkperiod	: time := 10 ns;

begin

DUT_num_comp: num_comp
                       generic map
                       (
                        c_clkfreq    => c_clkfreq   ,
                        c_data_width => c_data_width
                       )
                       port map
                       (
                       
                       clk         => sign_clk        ,
                       result_max  => sign_result_max,
                       result_mid  => sign_result_mid,
                       result_min  => sign_result_min,
                       anodes_o	   => sign_anodes_o   , 
                       seven_seg_o => sign_seven_seg_o                       
                       ); 

P_CLKGEN : process begin
sign_clk	<= '0';
wait for c_clkperiod/2;
sign_clk	<= '1';
wait for c_clkperiod/2;
end process;

process
begin
sign_result_max <= '0';
sign_result_mid <= '0';
sign_result_min <= '0';

wait for c_clkperiod*5;

sign_result_max <= '1';
wait for c_clkperiod*2;

sign_result_max <= '0';
wait for c_clkperiod*2;

sign_result_mid <= '1';
wait for c_clkperiod*2;

sign_result_mid <= '0';
wait for c_clkperiod*2;

sign_result_min <= '1';
wait for c_clkperiod*2;

sign_result_min <= '0';
wait for c_clkperiod*2;

wait for c_clkperiod*5;

assert false
report "SIM DONE"
severity failure;

end process;

end Behavioral;
