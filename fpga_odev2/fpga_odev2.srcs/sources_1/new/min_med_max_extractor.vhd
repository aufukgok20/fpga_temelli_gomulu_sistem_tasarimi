library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity min_med_max_extractor is
    port (
        sorted_data   : in  std_logic_vector(71 downto 0); -- sýralanmýþ 9 veri
        min_val       : out std_logic_vector(7 downto 0);
        med_val       : out std_logic_vector(7 downto 0);
        max_val       : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Behavioral of min_med_max_extractor is
begin
    process(sorted_data)
    begin
        -- sýralý olduðundan direkt eriþiyoruz
        min_val <= sorted_data(7 downto 0);                -- index 0
        med_val <= sorted_data(8*5 - 1 downto 8*4);         -- index 4
        max_val <= sorted_data(8*9 - 1 downto 8*8);         -- index 8
    end process;
end architecture;
