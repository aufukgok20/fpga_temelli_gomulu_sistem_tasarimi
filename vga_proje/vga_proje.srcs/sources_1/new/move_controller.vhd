library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity move_controller is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        
        -- command_decoder gelenler
        shape_type_in  : in std_logic_vector(1 downto 0);
        shape_color_in : in std_logic_vector(2 downto 0);
        move_cmd       : in std_logic_vector(1 downto 0);
        update_flag    : in std_logic;
        
        -- VGA çiziciye çýkýþlar
        shape_type_out  : out std_logic_vector(1 downto 0);
        shape_color_out : out std_logic_vector(2 downto 0);
        pos_x           : out integer range 0 to 639;  -- VGA çözünürlük uyumlu
        pos_y           : out integer range 0 to 479
    );
end move_controller;

architecture Behavioral of move_controller is
    signal x_pos  : integer range 0 to 639 := 320;  -- baþlangýç merkezi
    signal y_pos  : integer range 0 to 479 := 240;

    constant MOVE_STEP : integer := 10;
begin

    process(clk, reset)
    begin
        if reset = '1' then
            x_pos <= 320;
            y_pos <= 240;
            shape_type_out  <= "00";
            shape_color_out <= "000"; 

        elsif rising_edge(clk) then
            if update_flag = '1' then
                -- Hareket komutu varsa pozisyonu güncelle
                case move_cmd is
                    when "01" => -- sað
                        if x_pos < 620 then
                            x_pos <= x_pos + MOVE_STEP;
                        end if;
                    when "10" => -- sol
                        if x_pos > 20 then
                            x_pos <= x_pos - MOVE_STEP;
                        end if;
                    when "11" => -- yukarý
                        if y_pos > 20 then
                            y_pos <= y_pos - MOVE_STEP;
                        end if;
                    when "00" => -- aþaðý
                        if y_pos < 460 then
                            y_pos <= y_pos + MOVE_STEP;
                        end if;
                    when others => null;
                end case;
            end if;
        end if;
    end process;

    pos_x <= x_pos;
    pos_y <= y_pos;

end Behavioral;
