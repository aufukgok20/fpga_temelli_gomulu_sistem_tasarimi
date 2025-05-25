library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    generic (
        CLOCK_FREQ : integer := 100_000_000;
        BAUD_RATE  : integer := 115_200
    );
    port (
        clk      : in std_logic;
        reset    : in std_logic;
        rx       : in std_logic;
        data_out : out std_logic_vector(7 downto 0);
        done     : out std_logic
    );
end uart_rx;

architecture Behavioral of uart_rx is
    constant BAUD_TICK_COUNT : integer := CLOCK_FREQ / BAUD_RATE;
    constant HALF_BAUD_TICK  : integer := BAUD_TICK_COUNT / 2;

    type state_type is (idle, start_bit, data_bits, stop_bit);
    signal state        : state_type := idle;
    signal baud_counter : integer := 0;
    signal bit_index    : integer range 0 to 7 := 0;
    signal rx_shift     : std_logic_vector(7 downto 0) := (others => '0');
    signal done_i       : std_logic := '0';
begin

    done <= done_i;
    data_out <= rx_shift;

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= idle;
                baud_counter <= 0;
                bit_index <= 0;
                rx_shift <= (others => '0');
                done_i <= '0';
            else
                done_i <= '0';
                case state is
                    when idle =>
                        if rx = '0' then
                            state <= start_bit;
                            baud_counter <= 0;
                        end if;

                    when start_bit =>
                        if baud_counter = HALF_BAUD_TICK then
                            baud_counter <= 0;
                            state <= data_bits;
                            bit_index <= 0;
                        else
                            baud_counter <= baud_counter + 1;
                        end if;

                    when data_bits =>
                        if baud_counter = BAUD_TICK_COUNT then
                            baud_counter <= 0;
                            rx_shift(bit_index) <= rx;
                            if bit_index = 7 then
                                state <= stop_bit;
                            else
                                bit_index <= bit_index + 1;
                            end if;
                        else
                            baud_counter <= baud_counter + 1;
                        end if;

                    when stop_bit =>
                        if baud_counter = BAUD_TICK_COUNT then
                            state <= idle;
                            done_i <= '1';
                            baud_counter <= 0;
                        else
                            baud_counter <= baud_counter + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
