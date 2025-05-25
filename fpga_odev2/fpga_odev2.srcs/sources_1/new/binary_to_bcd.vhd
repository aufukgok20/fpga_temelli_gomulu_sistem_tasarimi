
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity binary_to_bcd is
    port (
        binary_in : in  std_logic_vector(7 downto 0);
        hundreds  : out std_logic_vector(3 downto 0);
        tens      : out std_logic_vector(3 downto 0);
        ones      : out std_logic_vector(3 downto 0)
    );
end entity;

architecture Behavioral of binary_to_bcd is
    
begin
    process(binary_in)
        variable value : integer;
        variable bin : unsigned(7 downto 0);
        variable h, t, o : integer range 0 to 9;
    begin
        bin := unsigned(binary_in);
        value := to_integer(unsigned(binary_in));
        h := value / 100;
        t := (value mod 100) / 10;
        o := value mod 10;

        hundreds <= std_logic_vector(to_unsigned(h, 4));
        tens     <= std_logic_vector(to_unsigned(t, 4));
        ones     <= std_logic_vector(to_unsigned(o, 4));
    end process;
end architecture;
