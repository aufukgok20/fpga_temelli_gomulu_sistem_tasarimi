
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_num_comp is
    generic (
        c_clkfreq   : INTEGER := 100_000_000;
        c_data_width : INTEGER := 4;
        c_data_piece : INTEGER := 4
    );
--  Port ( );
end tb_num_comp;

architecture Behavioral of tb_num_comp is

component num_comp is
    generic (
        c_clkfreq   : INTEGER := 100_000_000;
        c_data_width : INTEGER := 4;
        c_data_piece : INTEGER := 4
    );
    Port (
        clk         : in STD_LOGIC;
        data_in     : in  STD_LOGIC_VECTOR(c_data_width-1 downto 0);
        sel_in      : in  STD_LOGIC_VECTOR(2 downto 0);
        sel_birler  : in  STD_LOGIC_VECTOR(c_data_piece-1 downto 0);
        sel_onlar   : in  STD_LOGIC_VECTOR(c_data_piece-1 downto 0);
        sel_yuzler  : in  STD_LOGIC_VECTOR(c_data_piece-1 downto 0);
        anodes_o	: out  std_logic_vector (7 downto 0);
        seven_seg_o	: out std_logic_vector (7 downto 0);
        o_max       : out STD_LOGIC_VECTOR(c_data_width-1 downto 0);
        o_mid       : out STD_LOGIC_VECTOR(c_data_width-1 downto 0);
        o_min       : out STD_LOGIC_VECTOR(c_data_width-1 downto 0)
    );
end component;

signal sign_clk         :  STD_LOGIC := '0'                           ;
signal sign_data_in     :  STD_LOGIC_VECTOR(c_data_width-1 downto 0);
signal sign_sel_in      :  STD_LOGIC_VECTOR(2 downto 0);            
signal sign_sel_birler  :  STD_LOGIC_VECTOR(c_data_piece-1 downto 0);
signal sign_sel_onlar   :  STD_LOGIC_VECTOR(c_data_piece-1 downto 0);
signal sign_sel_yuzler  :  STD_LOGIC_VECTOR(c_data_piece-1 downto 0);
signal sign_anodes_o	:  STD_LOGIC_VECTOR (7 downto 0);               
signal sign_seven_seg_o :  STD_LOGIC_VECTOR (7 downto 0);           
signal sign_o_max       :  STD_LOGIC_VECTOR(c_data_width-1 downto 0);
signal sign_o_mid       :  STD_LOGIC_VECTOR(c_data_width-1 downto 0);
signal sign_o_min       :  STD_LOGIC_VECTOR(c_data_width-1 downto 0);

constant c_clkperiod	: time := 10 ns;

begin

INSTANTATION_num_comp: num_comp
                       generic map
                       (
                        c_clkfreq    => c_clkfreq   ,
                        c_data_width => c_data_width,
                        c_data_piece => c_data_piece
                       )
                       port map
                       (
                       
                       clk         => sign_clk        ,
                       data_in     => sign_data_in    ,
                       sel_in      => sign_sel_in     ,
                       sel_birler  => sign_sel_birler ,
                       sel_onlar   => sign_sel_onlar  ,
                       sel_yuzler  => sign_sel_yuzler ,
                       anodes_o	   => sign_anodes_o   , 
                       seven_seg_o => sign_seven_seg_o,
                       o_max       => sign_o_max      ,
                       o_mid       => sign_o_mid      ,
                       o_min       => sign_o_min      
                       
                       ); 

P_CLKGEN : process begin
sign_clk	<= '0';
wait for c_clkperiod/2;
sign_clk	<= '1';
wait for c_clkperiod/2;
end process;

process
begin
sign_data_in <= "0000";
sign_sel_in  <= "000";
sign_sel_birler   <= "0000";
sign_sel_onlar    <= "0000";
sign_sel_yuzler   <= "0000";


wait for c_clkperiod*10;
sign_sel_in <= "001";
sign_data_in <= "1010";

wait for c_clkperiod;
sign_sel_in <= "010";
sign_data_in <= "0010";

wait for c_clkperiod;
sign_sel_in <= "011";
sign_data_in <= "0011";

wait for c_clkperiod;
sign_sel_in <= "100";
sign_data_in <= "1011";

wait for c_clkperiod;
sign_sel_in <= "101";
sign_data_in <= "0110";

wait for c_clkperiod;
sign_sel_birler <= "0001";

wait for c_clkperiod;
sign_sel_onlar  <= "0010";

wait for c_clkperiod;
sign_sel_yuzler <= "0011";

wait for c_clkperiod*10;

assert false
report "SIM DONE"
severity failure;

end process;

end Behavioral;
