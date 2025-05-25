library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top_module is
end tb_top_module;

architecture behavior of tb_top_module is

    -- DUT port sinyalleri
    signal clk_100mhz : std_logic := '0';
    signal reset      : std_logic := '1';
    signal uart_rx    : std_logic := '1';  -- UART idle durumu: 1
    signal hsync      : std_logic;
    signal vsync      : std_logic;
    signal vga_red    : std_logic;
    signal vga_green  : std_logic;
    signal vga_blue   : std_logic;

    -- UART zamanlamasý (9600 bps için)
    constant CLK_PERIOD     : time := 10 ns;        -- 100 MHz clock
    constant UART_BAUD_RATE : integer := 115_200;
    constant UART_BIT_TIME  : time := 1 sec / UART_BAUD_RATE;



begin

    -- Saat üretimi
    clk_process : process
    begin
        clk_100mhz <= '0';
        wait for CLK_PERIOD / 2;
        clk_100mhz <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- DUT (Device Under Test) örneði
    DUT: entity work.top_module
        port map (
            clk_100mhz => clk_100mhz,
            reset      => reset,
            uart_rx    => uart_rx,
            hsync      => hsync,
            vsync      => vsync,
            vga_red    => vga_red,
            vga_green  => vga_green,
            vga_blue   => vga_blue
        );

    -- Reset süreci
    stim_proc : process

    --             -- UART karakter gönderme prosedürü
    --     procedure send_uart_byte(
    -- data : in std_logic_vector(7 downto 0)
    -- ) is
    -- begin
    --     uart_rx <= '0';  -- Start bit
    --     wait for UART_BIT_TIME;

    --     for i in 0 to 7 loop
    --         uart_rx <= data(i);
    --         wait for UART_BIT_TIME;
    --     end loop;

    --     uart_rx <= '1';  -- Stop bit
    --     wait for UART_BIT_TIME;
    -- end send_uart_byte;

    begin
        wait for 200 ns;
        reset <= '0';  -- Reset kaldýrýldý
        wait for 100 ns;

        -- UART ile: 02 ? Mavi kare komutu gönder
        send_uart_byte(x"02");
        wait for 2 ms;

        -- UART ile: 05 ? Hareket komutu gönder
        send_uart_byte(x"05");
        wait for 2 ms;

        wait;
    end process;
    
    process (clk_100mhz)

    -- UART karakter gönderme prosedürü
        procedure send_uart_byte(
    data : in std_logic_vector(7 downto 0);
    signal rx_uart : in STD_LOGIC := '1'
    ) is
    begin
        rx_uart <= '0';  -- Start bit
        wait for UART_BIT_TIME;

        for i in 0 to 7 loop
            rx_uart <= data(i);
            wait for UART_BIT_TIME;
        end loop;

        rx_uart <= '1';  -- Stop bit
        wait for UART_BIT_TIME;
    end send_uart_byte;

    begin
        uart_rx <= rx_uart;
    end process;

end behavior;
