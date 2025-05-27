library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shape_drawer is
    Port (
        clk           : in  std_logic;
        video_on      : in  std_logic;
        pixel_x       : in  integer range 0 to 799;
        pixel_y       : in  integer range 0 to 524;

        shape_x       : in  integer range 0 to 639;
        shape_y       : in  integer range 0 to 479;
        shape_type    : in  std_logic_vector(1 downto 0); -- 00: kare, 01: daire, 10: üçgen
        shape_color   : in  std_logic_vector(2 downto 0); -- RGB: 3 bit renk

        red_out       : out std_logic;
        green_out     : out std_logic;
        blue_out      : out std_logic
    );
end shape_drawer;

architecture Behavioral of shape_drawer is
    constant SHAPE_SIZE : integer := 40;  -- Þekil yarýçapý (çapý ~80 piksel)

    signal pixel_r, pixel_g, pixel_b : std_logic := '0';
begin

    process(clk)
        variable dx, dy : integer;
    begin
        if rising_edge(clk) then
            -- Varsayýlan olarak siyah yap
            pixel_r <= '0';
            pixel_g <= '0';
            pixel_b <= '0';

            if video_on = '1' then
                dx := pixel_x - shape_x;
                dy := pixel_y - shape_y;
               
                case shape_type is
                    when "00" =>  -- KARE
                        if abs(dx) <= SHAPE_SIZE and abs(dy) <= SHAPE_SIZE then
                            pixel_r <= shape_color(2);
                            pixel_g <= shape_color(1);
                            pixel_b <= shape_color(0);
                        end if;

                    when "01" =>  -- DAÝRE
                        if dx*dx + dy*dy <= SHAPE_SIZE * SHAPE_SIZE then
                            pixel_r <= shape_color(2);
                            pixel_g <= shape_color(1);
                            pixel_b <= shape_color(0);
                        end if;

                    when "10" =>  -- ÜÇGEN (yukarý bakan)
                        if abs(dx) <= SHAPE_SIZE and dy >= 0 and dy <= SHAPE_SIZE and abs(dx) <= (SHAPE_SIZE - dy) then
                            pixel_r <= shape_color(2);
                            pixel_g <= shape_color(1);
                            pixel_b <= shape_color(0);
                        end if;

                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process; 
 
    -- Renk çýkýþlarýný baðla
    red_out   <= pixel_r;
    green_out <= pixel_g;
    blue_out  <= pixel_b;

end Behavioral;
