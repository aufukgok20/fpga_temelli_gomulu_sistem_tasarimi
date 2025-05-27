library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_module is
    generic (
        c_clkfreq		: integer := 100_000_000;
        c_baudrate		: integer := 9_600
    );
    Port (
        clk_100mhz : in  std_logic;
        reset      : in  std_logic;
        uart_rx    : in  std_logic;
        hsync      : out std_logic;
        vsync      : out std_logic;
        vga_red    : out std_logic;
        vga_green  : out std_logic;
        vga_blue   : out std_logic
    );
end top_module;

architecture Structural of top_module is

component uart_rxx is
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
end component;

component command_decoder is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        data_in     : in  std_logic_vector(7 downto 0);
        data_valid  : in  std_logic;

        shape_type  : out std_logic_vector(1 downto 0);  -- 00: kare, 01: daire, 10: üçgen
        shape_color : out std_logic_vector(2 downto 0);  -- RGB: 3 bit renk kodu
        move_cmd    : out std_logic_vector(1 downto 0);  -- 00: yok, 01: sað, 10: sol, 11: yukarý/aþaðý
        update_flag : out std_logic                      -- Yeni komut geldi iþareti
    );
end component;

component move_controller is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        
        -- command_decoder gelenler
        shape_type_in  : in std_logic_vector(1 downto 0);
        shape_color_in : in std_logic_vector(2 downto 0);
        move_cmd       : in std_logic_vector(1 downto 0);
        update_flag    : in std_logic;
        
        -- VGA çiziciye çýkýþlar
        pos_x           : out integer range 0 to 639;  -- VGA çözünürlük uyumlu
        pos_y           : out integer range 0 to 479
    );
end component;

component vga_sync is
    Port (
        clk        : in  std_logic;  -- 100 MHz clock (640x480 için)
        reset      : in  std_logic;
        hsync      : out std_logic;
        vsync      : out std_logic;
        video_on   : out std_logic;
        pixel_x    : out integer range 0 to 799;
        pixel_y    : out integer range 0 to 524
    );
end component;

component shape_drawer is
    Port (
        clk           : in  std_logic;
        video_on      : in  std_logic;
        pixel_x       : in  integer range 0 to 799;
        pixel_y       : in  integer range 0 to 524;

        shape_x       : in  integer range 0 to 639;
        shape_y       : in  integer range 0 to 479;
        shape_type    : in  std_logic_vector(1 downto 0); -- 00: kare, 01: daire, 10: üçgen
        shape_color   : in  std_logic_vector(2 downto 0); -- RGB: 3 bit renk

        red_out       : out std_logic;
        green_out     : out std_logic;
        blue_out      : out std_logic
    );
end component;

    -- UART Signals
    signal uart_data     : std_logic_vector(7 downto 0);
    signal uart_ready    : std_logic;

    -- Komut çözümleyici sinyalleri
    signal shape_type_rx    : std_logic_vector(1 downto 0):= (others => '0');
    signal shape_color_rx   : std_logic_vector(2 downto 0):= (others => '0');
    signal move_cmd_rx      : std_logic_vector(1 downto 0):= (others => '0');
    signal update_flag_rx   : std_logic;

    -- VGA Sync Sinyalleri
    signal pixel_x       : integer range 0 to 799;
    signal pixel_y       : integer range 0 to 524;
    signal video_on      : std_logic;
    
    -- Þekil konumu
    signal pos_x         : integer range 0 to 639;
    signal pos_y         : integer range 0 to 479;
    
begin

    -- UART Receiver
    inst_uart_rx : uart_rxx
        generic map(
            c_clkfreq	=> c_clkfreq ,	
            c_baudrate  => c_baudrate
            )
        port map (
            clk        => clk_100mhz,
            reset      => reset,
            rx         => uart_rx,
            data_out   => uart_data,
            data_valid => uart_ready
        );

    -- Komut Çözümleyici
    parser_inst : command_decoder
        port map (
            clk         => clk_100mhz,
            reset       => reset,
            data_in     => uart_data,
            data_valid  => uart_ready,
            shape_type  => shape_type_rx,
            shape_color => shape_color_rx,
            move_cmd    => move_cmd_rx,
            update_flag => update_flag_rx
        );

    -- Hareket Kontrol
    move_controller_inst : move_controller
        port map (
            clk            => clk_100mhz,
            reset          => reset,
            shape_type_in  => shape_type_rx,
            shape_color_in => shape_color_rx,
            move_cmd       => move_cmd_rx,
            update_flag    => update_flag_rx,
            pos_x          => pos_x,
            pos_y          => pos_y
        );

    -- VGA Senkronizasyon
    vga_sync_inst : vga_sync
        port map (
            clk        => clk_100mhz,
            reset      => reset,
            hsync      => hsync,
            vsync      => vsync,
            video_on   => video_on,
            pixel_x    => pixel_x,
            pixel_y    => pixel_y
        );
 
    -- Þekil Çizimi
    drawer_inst : shape_drawer
        port map (
            clk         => clk_100mhz,
            video_on    => video_on,
            pixel_x     => pixel_x,
            pixel_y     => pixel_y,
            shape_x     => pos_x,
            shape_y     => pos_y,
            shape_type  => shape_type_rx,
            shape_color => shape_color_rx,
            red_out     => vga_red,
            green_out   => vga_green,
            blue_out    => vga_blue
        );

end Structural;
