library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity command_decoder is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        data_in     : in  std_logic_vector(7 downto 0);
        data_valid  : in  std_logic;

        shape_type  : out std_logic_vector(1 downto 0);  -- 00: kare, 01: daire, 10: üçgen
        shape_color : out std_logic_vector(2 downto 0);  -- RGB: 3 bit renk kodu
        move_cmd    : out std_logic_vector(1 downto 0);  -- 00: yok, 01: sað, 10: sol, 11: yukarý/aþaðý
        update_flag : out std_logic                      -- Yeni komut geldi iþareti
    );
end command_decoder;

architecture Behavioral of command_decoder is
begin

    process(clk, reset)
    begin
        if reset = '1' then
            shape_type  <= "00";
            shape_color <= "000";
            move_cmd    <= "00";
            update_flag <= '0';

        elsif rising_edge(clk) then
            update_flag <= '0';  -- her clockta sýfýrla
            if data_valid = '1' then
                case data_in is
                    -- Þekil ve renk komutlarý
                    when x"01" => shape_type <= "00"; shape_color <= "100"; -- kýrmýzý kare
                    when x"02" => shape_type <= "00"; shape_color <= "001"; -- mavi kare
                    when x"03" => shape_type <= "01"; shape_color <= "010"; -- yeþil daire
                    when x"04" => shape_type <= "10"; shape_color <= "110"; -- sarý üçgen

                    -- Hareket komutlarý
                    when x"05" => move_cmd <= "01"; -- sað
                    when x"06" => move_cmd <= "10"; -- sol
                    when x"07" => move_cmd <= "11"; -- yukarý
                    when x"08" => move_cmd <= "00"; -- aþaðý

                    when others =>
                        null;
                end case;
                update_flag <= '1';
            end if;
        end if;
    end process;

end Behavioral;
