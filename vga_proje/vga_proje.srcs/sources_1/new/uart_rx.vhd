library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rxx is
    generic (
    c_clkfreq		: integer := 100_000_000;
    c_baudrate		: integer := 9_600
    );
    Port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        rx        : in  std_logic;
        data_out  : out std_logic_vector(7 downto 0);
        data_valid: out std_logic
    );
end uart_rxx;

architecture Behavioral of uart_rxx is

    constant CLKS_PER_BIT : integer := c_clkfreq / c_baudrate;

    type state_type is (IDLE, START, DATA, STOP);
    signal state      : state_type := IDLE;
    signal clk_count  : integer := 0;
    signal bit_index  : integer range 0 to 7 := 0;
    signal rx_shift   : std_logic_vector(7 downto 0) := (others => '0');
    signal data_ready : std_logic := '0';
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state <= IDLE;
                clk_count  <= 0;
                bit_index  <= 0;
                rx_shift   <= (others => '0');
                data_ready <= '0';

            else
                case state is
                    when IDLE =>
                        data_ready <= '0';
                        if rx = '0' then
                            state <= START;
                            clk_count <= 0;
                        end if;

                    when START =>
                        if clk_count = CLKS_PER_BIT / 2 then
                            if rx = '0' then
                                clk_count <= 0;
                                bit_index <= 0;
                                state <= DATA;
                            else
                                state <= IDLE;
                            end if;
                        else
                            clk_count <= clk_count + 1;
                        end if;

                    when DATA =>
                        if clk_count = CLKS_PER_BIT then
                            clk_count <= 0;
                            rx_shift(bit_index) <= rx;
                            if bit_index = 7 then
                                state <= STOP;
                            else
                                bit_index <= bit_index + 1;
                            end if;
                        else
                            clk_count <= clk_count + 1;
                        end if;

                    when STOP =>
                        if clk_count = CLKS_PER_BIT then
                            state <= IDLE;
                            data_ready <= '1';
                        else
                            clk_count <= clk_count + 1;
                        end if;
                end case;
            end if;
        end if;
    end process;

    data_out  <= rx_shift;
    data_valid <= data_ready;

end Behavioral;
