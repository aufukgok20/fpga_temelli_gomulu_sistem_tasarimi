library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
    generic (
        CLOCK_FREQ : integer := 100_000_000;
        BAUD_RATE  : integer := 115_200
    );
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        rx        : in  std_logic;
        result_sw : in STD_LOGIC;
        seg       : out std_logic_vector(7 downto 0);
        an        : out std_logic_vector(7 downto 0)
    );
end entity;

architecture Structural of top_level is

    -- UART RX
    signal rx_data     : std_logic_vector(7 downto 0);
    signal rx_done     : std_logic;

    -- Data Collection
    signal collected_data : std_logic_vector(71 downto 0);
    signal data_ready     : std_logic;

    -- Sorting
    signal sorted_data    : std_logic_vector(71 downto 0);
    signal sort_done      : std_logic;

    -- Extracted Values
    signal min_val, med_val, max_val : std_logic_vector(7 downto 0);

    -- BCD Signals
    signal min_h, min_t, min_o : std_logic_vector(3 downto 0);
    signal med_h, med_t, med_o : std_logic_vector(3 downto 0);
    signal max_h, max_t, max_o : std_logic_vector(3 downto 0);

    -- Display input (8 digits, 4-bit each = 32 bits)
    signal display_digits : std_logic_vector(31 downto 0);

begin

    -- UART Receiver Instance
    uart_rx_inst: entity work.uart_rx
        generic map (
            CLOCK_FREQ => CLOCK_FREQ,
            BAUD_RATE  => BAUD_RATE  
        )
        port map (
            clk      => clk,
            reset    => reset,
            rx       => rx,
            data_out => rx_data,
            done     => rx_done
        );

    -- Data Collector
    collector_inst: entity work.data_collector
        port map (
            clk       => clk,
            reset     => reset,
            rx_data   => rx_data,
            rx_done   => rx_done,
            data_array  => collected_data,
            data_ready => data_ready
        );

    -- Sorter
    sorter_inst: entity work.sorter
        port map (
            clk         => clk,
            reset       => reset,
            data_in     => collected_data,
            sort_start  => data_ready,
            sorted_data => sorted_data,
            sort_done   => sort_done
        );

    -- Min, Med, Max Extractor
    extractor_inst: entity work.min_med_max_extractor
        port map (
            sorted_data => sorted_data,
            min_val     => min_val,
            med_val     => med_val,
            max_val     => max_val
        );

    -- Binary to BCD Converters
    bin2bcd_min: entity work.binary_to_bcd
        port map (
            binary_in => min_val,
            hundreds  => min_h,
            tens      => min_t,
            ones      => min_o
        );

    bin2bcd_med: entity work.binary_to_bcd
        port map (
            binary_in => med_val,
            hundreds  => med_h,
            tens      => med_t,
            ones      => med_o
        );

    bin2bcd_max: entity work.binary_to_bcd
        port map (
            binary_in => max_val,
            hundreds  => max_h,
            tens      => max_t,
            ones      => max_o
        );

    -- Combine all BCD digits for display
    -- display_digits <= 
        --  max_h & max_t & max_o &     -- digits(11 downto 0)
        --  med_h & med_t & med_o &  -- digits(23 downto 12)
        --  min_h & min_t & min_o ;  -- digits(35 downto 24)

    
    process (clk, result_sw)
    begin
        if rising_edge(clk) then
            if (result_sw = '1') then
                display_digits <= min_t & min_o & med_h & med_t & med_o & max_h & max_t & max_o;    
            end if;
        end if;
    end process;


    -- Display Multiplexer
    display_inst: entity work.display_mux
        port map (
            clk     => clk,
            reset   => reset,
            digits  => display_digits,
            seg     => seg,
            an      => an
        );

end architecture;

