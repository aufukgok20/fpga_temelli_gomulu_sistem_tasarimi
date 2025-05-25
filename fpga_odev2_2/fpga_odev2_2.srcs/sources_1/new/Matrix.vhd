
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.std_logic_arith.all;

entity Matrix is
    generic (
        c_clkfreq   : INTEGER := 100_000_000;
        c_baudrate	 : integer := 115_200
    );
    Port (
        clk : in STD_LOGIC;
        rx_i : in STD_LOGIC;
        row_col_select : in  STD_LOGIC; --Row? Column?
        row_sel        : in STD_LOGIC_VECTOR(1 downto 0);
        col_sel        : in STD_LOGIC_VECTOR(1 downto 0);
        rx_data_led_o   : out std_logic_vector (7 downto 0);
        anodes_o	   : out  std_logic_vector(7 downto 0);
        seven_seg_o	   : out std_logic_vector (7 downto 0)
    );
end Matrix;

architecture Behavioral of Matrix is

    component seven_segment is
        port (
            bcd_i		: in std_logic_vector (3 downto 0);
            sevenseg_o	: out std_logic_vector (7 downto 0)
            );
    end component;

    component uart_rx is
    generic (
    c_clkfreq		: integer := 100_000_000;
    c_baudrate		: integer := 115_200
    );
    port (
    clk				: in std_logic;
    rx_i			: in std_logic;
    dout_o			: out std_logic_vector (7 downto 0);
    rx_done_tick_o	: out std_logic
    );
    end component;

    signal rx_data     : std_logic_vector(7 downto 0);
    signal rx_done     : std_logic;

    constant c_timer1mslim			: integer := c_clkfreq/1000; -- 1 ms
    signal timer1ms					: integer range 0 to c_timer1mslim := 0;

    type t_matrix is array (0 to 2, 0 to 2) of STD_LOGIC_VECTOR(7 downto 0);
    signal matrix : t_matrix := ((others => (others => (others => '0') ) ) );

    signal anodes     : std_logic_vector (7 downto 0) := "11111110";

    signal row_integer: INTEGER := 0;
    signal col_integer: INTEGER := 0;

    signal row0 : std_logic_vector (7 downto 0) := (others => '0') ;
    signal row1 : std_logic_vector (7 downto 0) := (others => '0') ;
    signal row2 : std_logic_vector (7 downto 0) := (others => '0') ;

    signal column0 : std_logic_vector (7 downto 0) := (others => '0') ;
    signal column1 : std_logic_vector (7 downto 0) := (others => '0') ;
    signal column2 : std_logic_vector (7 downto 0) := (others => '0') ;

    signal row0_birler : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); 
    signal row0_onlar  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); 
    signal row1_birler : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); 
    signal row1_onlar  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); 
    signal row2_birler : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); 
    signal row2_onlar  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    
    signal col0_birler : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal col0_onlar  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal col1_birler : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal col1_onlar  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal col2_birler : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal col2_onlar  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

    signal rc0_birler : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); 
    signal rc0_onlar  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); 
    signal rc1_birler : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); 
    signal rc1_onlar  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); 
    signal rc2_birler : STD_LOGIC_VECTOR(3 downto 0) := (others => '0'); 
    signal rc2_onlar  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');

    signal rc0_seg_birler : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rc0_seg_onlar  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rc1_seg_birler : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rc1_seg_onlar  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rc2_seg_birler : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal rc2_seg_onlar  : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');

begin

        i_UART_RX : uart_rx
    generic map (
        c_clkfreq  => c_clkfreq,
        c_baudrate => c_baudrate
    )
    port map (
        clk			   => clk,
        rx_i		   => rx_i,
        dout_o		   => rx_data,
        rx_done_tick_o => rx_done
    );

    matrix(0,0) <= "00001111";
    matrix(0,1) <= "01000100";
    matrix(0,2) <= "01001001";

    matrix(1,0) <= "00111000";
    matrix(1,1) <= "01100010";
    matrix(1,2) <= "00011001";

    matrix(2,0) <= "00110101";
    matrix(2,1) <= "00101010";
    matrix(2,2) <= "01100011";

        process (clk, rx_data, rx_done)
    begin
        if rising_edge(clk) then
            if (rx_done = '1') then
                rx_data_led_o <= rx_data;
            end if;
        end if;
    end process;

    process (clk,row_col_select,row0_birler,row0_onlar,row1_birler,row1_onlar,row2_birler,row2_onlar,col0_birler,col0_onlar,col1_birler,col1_onlar,col2_birler,col2_onlar)
    begin
        if (rising_edge(clk)) then
            if ((row_col_select = '1')) then
                rc0_birler <= row0_birler;
                rc0_onlar  <= row0_onlar ;
                rc1_birler <= row1_birler;
                rc1_onlar  <= row1_onlar ;
                rc2_birler <= row2_birler;
                rc2_onlar  <= row2_onlar ;
                
            else
                rc0_birler <= col0_birler;
                rc0_onlar  <= col0_onlar ;
                rc1_birler <= col1_birler;
                rc1_onlar  <= col1_onlar ;
                rc2_birler <= col2_birler;
                rc2_onlar  <= col2_onlar ;    
            end if;
        end if;
    end process;

    i_row0_seg_birler: seven_segment
    port map (
        bcd_i	   => rc0_birler,
        sevenseg_o => rc0_seg_birler
    );

    i_row0_seg_onlar: seven_segment
    port map (
        bcd_i	   => rc0_onlar,
        sevenseg_o => rc0_seg_onlar
    );

    i_row1_seg_birler: seven_segment
    port map (
        bcd_i	   => rc1_birler,
        sevenseg_o => rc1_seg_birler
    );

    i_row1_seg_onlar: seven_segment
    port map (
        bcd_i	   => rc1_onlar,
        sevenseg_o => rc1_seg_onlar
    );

    i_row2_seg_birler: seven_segment
    port map (
        bcd_i	   => rc2_birler,
        sevenseg_o => rc2_seg_birler
    );

    i_row2_seg_onlar: seven_segment
    port map (
        bcd_i	   => rc2_onlar,
        sevenseg_o => rc2_seg_onlar
    );

    process (clk,row_sel)
    begin
        if (rising_edge(clk)) then
            if (row_sel = "00") then
                row_integer <= 0;
            elsif (row_sel = "01") then
                row_integer <= 1;
            elsif (row_sel = "10") then
                row_integer <= 2;
            else
                null;
            end if;        
        end if;
    end process;

    process (clk,col_sel)
    begin
        if (rising_edge(clk)) then
            if (col_sel = "00") then
                col_integer <= 0;
            elsif (col_sel = "01") then
                col_integer <= 1;
            elsif (col_sel = "10") then
                col_integer <= 2;
            else
                null;
            end if;        
        end if;
    end process;

    process (clk,row_col_select, row_integer,col_integer)
    begin
        if (rising_edge(clk)) then
            if (row_col_select = '1') then --Row Selection
                row0 <= matrix(0,row_integer);
                row1 <= matrix(1,row_integer);
                row2 <= matrix(2,row_integer);
            else                           -- Column Selection
                column0 <= matrix(col_integer,0);
                column1 <= matrix(col_integer,1);
                column2 <= matrix(col_integer,2);
            end if;
        end if;
    end process;

    process (clk,row_col_select, row_sel)
    begin
        if (rising_edge(clk)) then
            if (row_col_select = '1' and row_sel = "00") then
                row0_birler <= "0101";
                row0_onlar  <= "0001";
                row1_birler <= "0110";
                row1_onlar  <= "0101";
                row2_birler <= "0011";
                row2_onlar  <= "0101";
            
            elsif (row_col_select = '1' and row_sel = "01") then
                row0_birler <= "1000";
                row0_onlar  <= "0110";
                row1_birler <= "1000";
                row1_onlar  <= "1001";
                row2_birler <= "0010";
                row2_onlar  <= "0100";

            elsif (row_col_select = '1' and row_sel = "10") then
                
                row0_birler <= "0011";
                row0_onlar  <= "0111";
                row1_birler <= "0101";
                row1_onlar  <= "0010";
                row2_birler <= "1001";
                row2_onlar  <= "1001";

            elsif (row_col_select = '1' and row_sel = "11") then
                row0_birler <= "0000";
                row0_onlar  <= "0000";
                row1_birler <= "0000";
                row1_onlar  <= "0000";
                row2_birler <= "0000";
                row2_onlar  <= "0000";
            end if;
            
        end if;
    end process;

    process (clk,row_col_select, col_sel)
    begin
        if (rising_edge(clk)) then
            if (row_col_select = '0' and col_sel = "00") then
                col0_birler <= "0101";
                col0_onlar  <= "0001";
                col1_birler <= "1000";
                col1_onlar  <= "0110";
                col2_birler <= "0011";
                col2_onlar  <= "0111";
            
            elsif (row_col_select = '0' and col_sel = "01") then
                col0_birler <= "0110";
                col0_onlar  <= "0101";
                col1_birler <= "1000";
                col1_onlar  <= "1001";
                col2_birler <= "0101";
                col2_onlar  <= "0010";

            elsif (row_col_select = '0' and col_sel = "10") then
                
                col0_birler <= "0011";
                col0_onlar  <= "0101";
                col1_birler <= "0010";
                col1_onlar  <= "0100";
                col2_birler <= "1001";
                col2_onlar  <= "1001";

            elsif (row_col_select = '0' and col_sel = "11") then
                
                col0_birler <= "0000";
                col0_onlar  <= "0000";
                col1_birler <= "0000";
                col1_onlar  <= "0000";
                col2_birler <= "0000";
                col2_onlar  <= "0000";
            end if;
            
        end if;
    end process;

    P_ANODES : process (clk) begin
        if (rising_edge(clk)) then
        
            anodes(7 downto 6)	<= "11";
        
            if (timer1ms = c_timer1mslim-1) then
                timer1ms	<= 0;
                anodes(5 downto 1)	<= anodes(4 downto 0);
                anodes(0)	        <= anodes(5);
            else
                timer1ms	<= timer1ms + 1;
            end if;
        
        end if;
        end process;

        P_CATHODES : process (clk)
        begin
            if (RISING_EDGE(clk)) then
                if (anodes(0) = '0') then
                    seven_seg_o <= rc2_seg_birler;
                elsif (anodes(1) = '0') then
                    seven_seg_o <= rc2_seg_onlar;
                elsif (anodes(2) = '0') then
                    seven_seg_o <= rc1_seg_birler;
                elsif (anodes(3) = '0') then
                    seven_seg_o <= rc1_seg_onlar;
                elsif (anodes(4) = '0') then
                    seven_seg_o <= rc0_seg_birler;
                elsif (anodes(5) = '0') then
                    seven_seg_o <= rc0_seg_onlar;  
                else
                    seven_seg_o <= ((others => '1'));
                end if;
            end if;
        end process;
        
        anodes_o <= anodes;
end Behavioral;


