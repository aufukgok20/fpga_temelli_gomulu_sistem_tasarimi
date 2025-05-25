library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_collector is
    port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        rx_done     : in  std_logic;  -- UART RX tamam sinyali
        rx_data     : in  std_logic_vector(7 downto 0); -- UART'tan gelen veri
        data_array  : out std_logic_vector(9*8 - 1 downto 0); -- 9x8-bit array çıkışı
        data_ready  : out std_logic   -- 9 veri tamamlandı sinyali
    );
end entity;

architecture Behavioral of data_collector is
    type array_t is array(0 to 8) of std_logic_vector(7 downto 0);
    signal mem : array_t := (others => (others => '0'));
    signal index : integer range 0 to 9 := 0;
    signal ready : std_logic := '0';
    signal data_array_reg : std_logic_vector(9*8 - 1 downto 0) := (others => '0') ;

begin

    data_ready <= ready;
    data_array <= data_array_reg;

    -- Array'i flat out olarak veriyoruz
    process(mem)
    begin
        for i in 0 to 8 loop
            data_array_reg(i*8 + 7 downto i*8) <= mem(i);
        end loop;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                index <= 0;
                mem <= (others => (others => '0'));
                ready <= '0';
            elsif rx_done = '1' then
                if index < 9 then
                    mem(index) <= rx_data;
                    index <= index + 1;
                    if index = 8 then
                        ready <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

end architecture;
