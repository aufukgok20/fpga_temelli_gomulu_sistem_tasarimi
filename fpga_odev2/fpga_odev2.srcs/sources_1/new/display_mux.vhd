library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_mux is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        digits      : in  std_logic_vector(31 downto 0); -- 8 basamaklýk BCD (4 bit * 8)
        seg         : out std_logic_vector(7 downto 0);
        an          : out std_logic_vector(7 downto 0)  -- aktif düþük
    );
end entity;

architecture Behavioral of display_mux is
    signal refresh_counter : unsigned(15 downto 0) := (others => '0');
    signal digit_select     : unsigned(2 downto 0);
    signal current_digit    : std_logic_vector(3 downto 0);
    signal seg_internal     : std_logic_vector(7 downto 0);
begin

    -- Display scanning clock
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                refresh_counter <= (others => '0');
            else
                refresh_counter <= refresh_counter + 1;
            end if;
        end if;
    end process;

    digit_select <= refresh_counter(15 downto 13); -- 3-bit seçim

    -- Anode control
    process(digit_select)
    begin
        an <= "11111111";
        an(to_integer(digit_select)) <= '0'; -- Aktif düþük
    end process;

    -- Seçilen digit için BCD seçimi
    process(digit_select, digits)
    begin
        current_digit <= digits(to_integer(digit_select)*4 + 3 downto to_integer(digit_select)*4);
    end process;

    -- 7 segment sürme
    seg_decoder: entity work.bcd_to_7segment
        port map (
            bcd_in => current_digit,
            seg_out => seg_internal
        );

    seg <= seg_internal;

end architecture;
