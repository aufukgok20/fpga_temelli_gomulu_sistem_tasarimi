
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity num_comp is
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
end num_comp;

architecture Behavioral of num_comp is

constant c_timer1mslim			: integer := c_clkfreq/1000; -- 1 ms
signal timer1ms					: integer range 0 to c_timer1mslim := 0;

type t_array_num is array (0 to c_data_width) of STD_LOGIC_VECTOR(c_data_width-1 downto 0);
signal sorted_data : t_array_num;

signal i, j, k      : INTEGER := 0;

signal temp_num1  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := "00001111"; --15 9 
signal temp_num2  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := "01000100"; --68 5
signal temp_num3  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := "01001001"; --73 4
signal temp_num4  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := "00111000"; --56 6
signal temp_num5  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := "01100010"; --98 2
signal temp_num6  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := "00011001"; --88 3
signal temp_num7  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := "00110101"; --53 7
signal temp_num8  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := "00101010"; --42 8
signal temp_num9  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := "01100011"; --99 1
 
signal anodes            : std_logic_vector (7 downto 0) := "11111110";
signal max_seg_birler : std_logic_vector (7 downto 0) := (others => '1');
signal max_seg_onlar  : std_logic_vector (7 downto 0) := (others => '1');
signal mid_seg_birler : std_logic_vector (7 downto 0) := (others => '1');
signal mid_seg_onlar  : std_logic_vector (7 downto 0) := (others => '1');
signal min_seg_birler : std_logic_vector (7 downto 0) := (others => '1');
signal min_seg_onlar  : std_logic_vector (7 downto 0) := (others => '1');

signal max_birler : STD_LOGIC_VECTOR(3 downto 0) := ((others => '0'));
signal max_onlar  : STD_LOGIC_VECTOR(3 downto 0) := ((others => '0'));
signal mid_birler : STD_LOGIC_VECTOR(3 downto 0) := ((others => '0'));
signal mid_onlar  : STD_LOGIC_VECTOR(3 downto 0) := ((others => '0'));
signal min_birler : STD_LOGIC_VECTOR(3 downto 0) := ((others => '0'));
signal min_onlar  : STD_LOGIC_VECTOR(3 downto 0) := ((others => '0'));

component sevenseg_led is
    port (
        bcd_i		: in std_logic_vector (3 downto 0);
        sevenseg_o	: out std_logic_vector (7 downto 0)
        );
end component;

begin

    i_MAX_SEG_Birler: sevenseg_led
    port map 
        (
        bcd_i	   => max_birler, 
        sevenseg_o => max_seg_birler
        );
    
        i_MAX_SEG_Onlar: sevenseg_led
    port map 
        (
        bcd_i	   => max_onlar, 
        sevenseg_o => max_seg_onlar
        );

        i_MID_SEG_Birler: sevenseg_led
    port map 
        (
        bcd_i	   => mid_birler, 
        sevenseg_o => mid_seg_birler
        );
    
        i_MID_SEG_Onlar: sevenseg_led
    port map 
        (
        bcd_i	   => mid_onlar, 
        sevenseg_o => mid_seg_onlar
        );

        i_MIN_SEG_Birler: sevenseg_led
    port map 
        (
        bcd_i	   => min_birler, 
        sevenseg_o => min_seg_birler
        );
    
        i_MIN_SEG_Onlar: sevenseg_led
    port map 
        (
        bcd_i	   => min_onlar, 
        sevenseg_o => min_seg_onlar
        );
    
    process (clk,result_max)
    begin
        if (rising_edge(clk)) then
            if (result_max = '1') then
                max_birler <= "1001"; 
                max_onlar  <= "1001";
            else
                max_birler <= "0000";
                max_onlar  <= "0000"; 
            end if;  
        end if;  
    end process; 

    process (clk,result_mid)
    begin
        if (rising_edge(clk)) then
            if (result_mid = '1') then
                mid_birler <= "1000";
                mid_onlar  <= "0110";
            else
                mid_birler <= "0000";
                mid_onlar  <= "0000";
            end if;   
        end if;   
    end process; 

    process (clk,result_min)
    begin
        if (rising_edge(clk)) then
            if (result_min = '1') then
                min_birler <= "0101"; 
                min_onlar  <= "0001";
            else
                min_birler <= "0000";
                min_onlar  <= "0000";    
            end if;    
        end if; 
    end process; 


    process (temp_num1,temp_num2,temp_num3,temp_num4,temp_num5,temp_num6,temp_num7,temp_num8,temp_num9)
        variable temp : t_array_num;
        variable t : std_logic_vector(c_data_width-1 downto 0);
        
    begin
        temp(0) := temp_num1;
        temp(1) := temp_num2;
        temp(2) := temp_num3;
        temp(3) := temp_num4;
        temp(4) := temp_num5;
        temp(5) := temp_num6;
        temp(6) := temp_num7;
        temp(7) := temp_num8;
        temp(8) := temp_num9;

        for i in 0 to 3 loop
            for j in 0 to 3-i loop
                if (temp(j) > temp(j+1)) then

                    t := temp(j);
                    temp(j) := temp(j+1);
                    temp(j+1) := t;

                end if;
            end loop;
        end loop;
        sorted_data <= temp;

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
                seven_seg_o <= max_seg_birler;
            elsif (anodes(1) = '0') then
                seven_seg_o <= max_seg_onlar;
            elsif (anodes(2) = '0') then
                seven_seg_o <= mid_seg_birler;
            elsif (anodes(3) = '0') then
                seven_seg_o <= mid_seg_onlar;
            elsif (anodes(4) = '0') then
                seven_seg_o <= min_seg_birler;
            elsif (anodes(5) = '0') then
                seven_seg_o <= min_seg_onlar;  
            else
                seven_seg_o <= ((others => '1'));
            end if;
        end if;
    end process;
    
    anodes_o <= anodes;

end Behavioral;    
