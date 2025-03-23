
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.NUMERIC_STD.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity num_comp is
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
end num_comp;

architecture Behavioral of num_comp is

constant c_timer1mslim			: integer := c_clkfreq/1000; -- 1 ms
signal timer1ms					: integer range 0 to c_timer1mslim := 0;

type t_array_num is array (0 to c_data_width) of STD_LOGIC_VECTOR(c_data_width-1 downto 0);
signal sorted_data : t_array_num;

signal i, j, k      : INTEGER := 0;

signal temp_num1  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := (others => '0');
signal temp_num2  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := (others => '0');
signal temp_num3  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := (others => '0');
signal temp_num4  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := (others => '0');
signal temp_num5  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := (others => '0');
-- signal temp_num6  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := (others => '0');
-- signal temp_num7  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := (others => '0');
-- signal temp_num8  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := (others => '0');
-- signal temp_num9  : STD_LOGIC_VECTOR(c_data_width-1 downto 0) := (others => '0');
 
signal anodes     : std_logic_vector (7 downto 0) := "11111110";
signal result_seg_birler : std_logic_vector (7 downto 0) := (others => '1');
signal result_seg_onlar  : std_logic_vector (7 downto 0) := (others => '1');
signal result_seg_yuzler : std_logic_vector (7 downto 0) := (others => '1');

component sevenseg_led is
    port (
        bcd_i		: in std_logic_vector (3 downto 0);
        sevenseg_o	: out std_logic_vector (7 downto 0)
        );
end component;

begin

    i_RESULT_SEG_Birler: sevenseg_led
    port map 
        (
        bcd_i	   => sel_birler, 
        sevenseg_o => result_seg_birler
        );
    
        i_RESULT_SEG_Onlar: sevenseg_led
    port map 
        (
        bcd_i	   => sel_onlar, 
        sevenseg_o => result_seg_onlar
        );

        i_RESULT_SEG_Yuzler: sevenseg_led
    port map 
        (
        bcd_i	   => sel_yuzler, 
        sevenseg_o => result_seg_yuzler
        );

    process(sel_in)
    begin
        
        if (sel_in = "0001") then
            temp_num1 <= data_in;
        end if;
        if (sel_in = "0010") then
            temp_num2 <= data_in;
        end if;
        if (sel_in = "0011") then
            temp_num3 <= data_in;
        end if;
        if (sel_in = "0100") then
            temp_num4 <= data_in;
        end if;
        if (sel_in = "0101") then
            temp_num5 <= data_in;
        end if;
        -- if (sel_in = "0110") then
        --     temp_num6 <= data_in;
        -- end if;
        -- if (sel_in = "0111") then
        --     temp_num7 <= data_in;
        -- end if;
        -- if (sel_in = "1000") then
        --     temp_num8 <= data_in;
        -- end if;

        -- if (sel_in = "1001") then
        --     temp_num9 <= data_in;
        -- end if;
    
    end process;


    process (temp_num1,temp_num2,temp_num3,temp_num4,temp_num5) --,temp_num6,temp_num7,temp_num8,temp_num9
        variable temp : t_array_num;
        variable t : std_logic_vector(c_data_width-1 downto 0);
        
    begin
        temp(0) := temp_num1;
        temp(1) := temp_num2;
        temp(2) := temp_num3;
        temp(3) := temp_num4;
        temp(4) := temp_num5;
        -- temp(5) := temp_num6;
        -- temp(6) := temp_num7;
        -- temp(7) := temp_num8;
        -- temp(8) := temp_num9;

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


    o_max <= sorted_data(4);
    o_mid <= sorted_data(2);
    o_min <= sorted_data(0);

    P_ANODES : process (clk) begin
        if (rising_edge(clk)) then
        
            anodes(7 downto 3)	<= "11111";
        
            if (timer1ms = c_timer1mslim-1) then
                timer1ms				<= 0;
                anodes(2 downto 1)		<= anodes(1 downto 0);
                anodes(0)				<= anodes(2);
            else
                timer1ms				<= timer1ms + 1;
            end if;
        
        end if;
        end process;

    P_CATHODES : process (clk)
    begin
        if (RISING_EDGE(clk)) then
            if (anodes(0) = '0') then
                seven_seg_o <= result_seg_birler;
            elsif (anodes(1) = '0') then
                seven_seg_o <= result_seg_onlar;
            elsif (anodes(2) = '0') then
                seven_seg_o <= result_seg_yuzler;
            else
                seven_seg_o <= ((others => '1'));
            end if;
        end if;
    end process;
    
    anodes_o <= anodes;

end Behavioral;    
