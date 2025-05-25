library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sorter is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        sort_start  : in  STD_LOGIC;
        data_in     : in  STD_LOGIC_VECTOR(9*8-1 downto 0); -- 72-bit input (9 x 8-bit)
        sorted_data : out STD_LOGIC_VECTOR(9*8-1 downto 0); -- 72-bit output
        sort_done   : out STD_LOGIC
    );
end sorter;

architecture Behavioral of sorter is

    type data_array is array(0 to 8) of unsigned(7 downto 0);
    signal data    : data_array := (others => (others => '0'));
    signal sorted  : data_array := (others => (others => '0'));
    signal i       : integer range 0 to 8 := 0;
    signal j       : integer range 0 to 8 := 0;
    signal sorting : boolean := false;
    signal done       : std_logic := '0';

begin

    sort_done <= done;

    process(clk)
        variable temp : unsigned(7 downto 0);
    begin
        if rising_edge(clk) then
            if reset = '1' then
                data    <= (others => (others => '0'));
                sorted  <= (others => (others => '0'));
                i       <= 0;
                j       <= 0;
                sorting <= false;
                done    <= '0';
            elsif sort_start = '1' and not sorting then
                -- Giriþ verisini parçala
                for idx in 0 to 8 loop
                    data(idx) <= unsigned(data_in((idx+1)*8-1 downto idx*8));
                end loop;
                i <= 0;
                j <= 0;
                sorting <= true;
                done <= '0';
            elsif sorting then
                -- Bubble sort algoritmasý
                if i < 8 then
                    if j < 8 - i then
                        if data(j) > data(j+1) then
                            -- Swap iþlemi
                            temp := data(j);
                            data(j) <= data(j+1);
                            data(j+1) <= temp;
                        end if;
                        j <= j + 1;
                    else
                        j <= 0;
                        i <= i + 1;
                    end if;
                else
                    sorted <= data;
                    sorting <= false;
                    done <= '1';
                end if;
            end if;
        end if;
    end process;

    -- Sýralanmýþ veriyi çýkýþa aktar
    process(sorted)
    begin
        for idx in 0 to 8 loop
            sorted_data((idx+1)*8-1 downto idx*8) <= std_logic_vector(sorted(idx));
        end loop;
    end process;

end Behavioral;
