library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_top_module is
    generic (
        c_clkfreq		: integer := 100_000_000;
        c_baudrate		: integer := 9_600
    );
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
    constant c_baud9600  	: time := 1 us;
    
    constant c_hex02		: std_logic_vector (9 downto 0) := '1' & x"02" & '0';
    constant c_hex05		: std_logic_vector (9 downto 0) := '1' & x"05" & '0';



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

    process
    begin
        wait for 100 ns;
        reset <= '0';  -- Reset kaldýrýldý
        wait for 100 ns;

        -- UART ile: 02 ? Mavi kare komutu gönder
        for i in 0 to 9 loop
	       uart_rx <= c_hex02(i);
	       wait for c_baud9600;
        end loop;
        
        wait for 10 us;
        
        -- UART ile: 05 ? Hareket komutu gönder
        for i in 0 to 9 loop
	       uart_rx <= c_hex05(i);
	       wait for c_baud9600;
        end loop;

        wait for 20 us;

        assert false
        report "SIM DONE"
        severity failure;
    end process;

end behavior;
