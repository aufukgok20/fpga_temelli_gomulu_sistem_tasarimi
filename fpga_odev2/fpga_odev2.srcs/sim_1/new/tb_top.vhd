
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity tb_top is
    generic (
        CLOCK_FREQ : integer := 100_000_000;
        BAUD_RATE  : integer := 115_200
    );

end tb_top;

architecture Behavioral of tb_top is

    component top_level is
    generic (
        CLOCK_FREQ : integer := 100_000_000;
        BAUD_RATE  : integer := 115_200
    );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        rx        : in  std_logic;
        result_sw : in STD_LOGIC;
        seg       : out std_logic_vector(7 downto 0);
        an        : out std_logic_vector(7 downto 0)
    );
    end component;

    signal clk       : STD_LOGIC := '0' ;
    signal reset     : STD_LOGIC := '1' ;
    signal rx        : STD_LOGIC ;
    signal result_sw : STD_LOGIC := '0' ;
    signal seg       : STD_LOGIC_VECTOR(7 downto 0) ;
    signal an        : STD_LOGIC_VECTOR(7 downto 0) ;

    constant c_clkperiod	: time := 10 ns;
    -- constant c_baud115200	: time := 8.68 us;
    constant c_baud115200	: time := 1 us;

    constant c_hex86		: std_logic_vector (9 downto 0) := '1' & x"86" & '0' ;
    constant c_hex45		: std_logic_vector (9 downto 0) := '1' & x"45" & '0' ;
    constant c_hex43		: std_logic_vector (9 downto 0) := '1' & x"43" & '0' ;
    constant c_hex51		: std_logic_vector (9 downto 0) := '1' & x"51" & '0' ;
    constant c_hex35		: std_logic_vector (9 downto 0) := '1' & x"35" & '0' ;
    constant c_hex11		: std_logic_vector (9 downto 0) := '1' & x"11" & '0' ;
    constant c_hex99		: std_logic_vector (9 downto 0) := '1' & x"99" & '0' ;
    constant c_hex27		: std_logic_vector (9 downto 0) := '1' & x"27" & '0' ;
    constant c_hex67		: std_logic_vector (9 downto 0) := '1' & x"67" & '0' ;

begin

    DUT: top_level
    generic map (
        CLOCK_FREQ => CLOCK_FREQ,
        BAUD_RATE  => BAUD_RATE 
    )
    port map (
        clk       => clk      ,
        reset     => reset    ,
        rx        => rx       ,
        result_sw => result_sw,
        seg       => seg      ,
        an        => an       
    );

    P_CLKGEN : process begin

    clk	<= '0';
    wait for c_clkperiod/2;
    clk	<= '1';
    wait for c_clkperiod/2;

    end process P_CLKGEN;

    P_STIMULI : process begin

        reset <= '1';
        wait for c_clkperiod*10;
        reset <= '0';     
        
        for i in 0 to 9 loop
	    rx <= c_hex86(i);
	    wait for c_baud115200;
        end loop;
  
        wait for 10 us;
        
        for i in 0 to 9 loop
	    rx <= c_hex45(i);
	    wait for c_baud115200;
        end loop;
        
        wait for 10 us;
        
        for i in 0 to 9 loop
	    rx <= c_hex43(i);
	    wait for c_baud115200;
        end loop;
        
        wait for 10 us;

        for i in 0 to 9 loop
	    rx <= c_hex51(i);
	    wait for c_baud115200;
        end loop;
        
        wait for 10 us;
        
        for i in 0 to 9 loop
	    rx <= c_hex35(i);
	    wait for c_baud115200;
        end loop;
        
        wait for 10 us;
        
        for i in 0 to 9 loop
	    rx <= c_hex11(i);
	    wait for c_baud115200;
        end loop;
        
        wait for 10 us;
        
        for i in 0 to 9 loop
	    rx <= c_hex99(i);
	    wait for c_baud115200;
        end loop;
        
        wait for 10 us;
        
        for i in 0 to 9 loop
	    rx <= c_hex27(i);
	    wait for c_baud115200;
        end loop;
        
        wait for 10 us;
        
        for i in 0 to 9 loop
	    rx <= c_hex67(i);
	    wait for c_baud115200;
        end loop;
        
        wait for 10 us;
        
        result_sw <= '1';
        
        wait for 5 ms;

        assert false
        report "SIM DONE"
        severity failure;
    
    end process;
end Behavioral;
