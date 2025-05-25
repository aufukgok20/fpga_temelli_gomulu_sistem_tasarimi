library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bcd_to_7segment is
    port (
        bcd_in    : in  std_logic_vector(3 downto 0);
        seg_out  : out std_logic_vector(7 downto 0) -- a to g
    );
end entity;

architecture Behavioral of bcd_to_7segment is
begin
    process(bcd_in)
    begin
        case bcd_in is
            when "0000" => seg_out <= "00000011"; -- 0
            when "0001" => seg_out <= "10011111"; -- 1
            when "0010" => seg_out <= "00100101"; -- 2
            when "0011" => seg_out <= "00001101"; -- 3
            when "0100" => seg_out <= "10011001"; -- 4
            when "0101" => seg_out <= "01001001"; -- 5
            when "0110" => seg_out <= "01000001"; -- 6
            when "0111" => seg_out <= "00011111"; -- 7
            when "1000" => seg_out <= "00000001"; -- 8
            when "1001" => seg_out <= "00001001"; -- 9
            when others => seg_out <= "11111111"; -- blank
        end case;
    end process;
end architecture;