library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.math_real.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga is
    Port ( CLK_I : in  STD_LOGIC;
           -- VGA Output Signals
           VGA_HS_O : out  STD_LOGIC; -- HSYNC OUT
           VGA_VS_O : out  STD_LOGIC; -- VSYNC OUT
           VGA_RED_O    : out  STD_LOGIC_VECTOR (3 downto 0); -- Red signal going to the VGA interface
           VGA_GREEN_O  : out  STD_LOGIC_VECTOR (3 downto 0); -- Green signal going to the VGA interface
           VGA_BLUE_O   : out  STD_LOGIC_VECTOR (3 downto 0) -- Blue signal going to the VGA interface
           );
end vga;

architecture Behavioral of vga is

-------------------------------------------------------------------------

-- Component Declarations

-------------------------------------------------------------------------


   -- To generate the 108 MHz Pixel Clock
   -- needed for a resolution of 1280*1024 pixels
--   COMPONENT PxlClkGen
--   PORT
--    (-- Clock in ports
--     CLK_IN1           : in std_logic;
--     -- Clock out ports
--     CLK_OUT1          : out std_logic;
--     -- Status and control signals
--     LOCKED            : out std_logic
--    );
--   END COMPONENT;

   -- Display the Digilent Nexys 4 and Analog Devices Logo
	COMPONENT LogoDisplay
	GENERIC(
      X_START : integer range 2 to (Integer'high) := 40; -- Logo Starting Horizontal Location
      Y_START : integer := 512 -- Logo Starting Vertical Location
	);
	PORT(
		CLK_I : IN std_logic;
		H_COUNT_I : IN std_logic_vector(11 downto 0);
		V_COUNT_I : IN std_logic_vector(11 downto 0);
      -- Logo Red, Green and Blue signals
		RED_O : OUT std_logic_vector(3 downto 0);
		BLUE_O : OUT std_logic_vector(3 downto 0);
		GREEN_O : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
   
   -- Display the overlay
   COMPONENT OverlayCtl
	PORT(
		CLK_I : IN std_logic;
		VSYNC_I : IN std_logic;
		ACTIVE_I : IN std_logic;          
		OVERLAY_O : OUT std_logic
		);
	END COMPONENT;

-------------------------------------------------------------

-- Constants for various VGA Resolutions

-------------------------------------------------------------

--***640x480@60Hz***--  
--constant FRAME_WIDTH : natural := 640;
--constant FRAME_HEIGHT : natural := 480;

--constant H_FP : natural := 16; --H front porch width (pixels)
--constant H_PW : natural := 96; --H sync pulse width (pixels)
--constant H_MAX : natural := 800; --H total period (pixels)
--
--constant V_FP : natural := 10; --V front porch width (lines)
--constant V_PW : natural := 2; --V sync pulse width (lines)
--constant V_MAX : natural := 525; --V total period (lines)

--constant H_POL : std_logic := '0';
--constant V_POL : std_logic := '0';

--***800x600@60Hz***--
--constant FRAME_WIDTH : natural := 800;
--constant FRAME_HEIGHT : natural := 600;
--
--constant H_FP : natural := 40; --H front porch width (pixels)
--constant H_PW : natural := 128; --H sync pulse width (pixels)
--constant H_MAX : natural := 1056; --H total period (pixels)
--
--constant V_FP : natural := 1; --V front porch width (lines)
--constant V_PW : natural := 4; --V sync pulse width (lines)
--constant V_MAX : natural := 628; --V total period (lines)
--
--constant H_POL : std_logic := '1';
--constant V_POL : std_logic := '1';

--***1280x1024@60Hz***--
constant FRAME_WIDTH : natural := 1280;
constant FRAME_HEIGHT : natural := 1024;

constant H_FP : natural := 48; --H front porch width (pixels)
constant H_PW : natural := 112; --H sync pulse width (pixels)
constant H_MAX : natural := 1688; --H total period (pixels)

constant V_FP : natural := 1; --V front porch width (lines)
constant V_PW : natural := 3; --V sync pulse width (lines)
constant V_MAX : natural := 1066; --V total period (lines)

constant H_POL : std_logic := '1';
constant V_POL : std_logic := '1';

--***1920x1080@60Hz***--
--constant FRAME_WIDTH : natural := 1920;
--constant FRAME_HEIGHT : natural := 1080;
--
--constant H_FP : natural := 88; --H front porch width (pixels)
--constant H_PW : natural := 44; --H sync pulse width (pixels)
--constant H_MAX : natural := 2200; --H total period (pixels)
--
--constant V_FP : natural := 4; --V front porch width (lines)
--constant V_PW : natural := 5; --V sync pulse width (lines)
--constant V_MAX : natural := 1125; --V total period (lines)
--
--constant H_POL : std_logic := '1';
--constant V_POL : std_logic := '1';

------------------------------------------------------------------

-- Constants for setting the displayed logo size and coordinates

------------------------------------------------------------------
constant SZ_LOGO_WIDTH 	   : natural := 335; -- Width of the logo frame
constant SZ_LOGO_HEIGHT 	: natural := 280; -- Height of the logo frame

constant FRM_LOGO_H_LOC 	: natural := 25; --  Starting horizontal location of the logo frame
constant FRM_LOGO_V_LOC 	: natural := 176; -- Starting vertical location of the logo frame

-- Logo frame limits
constant LOGO_LEFT 			: natural := FRM_LOGO_H_LOC - 1;
constant LOGO_RIGHT 		   : natural := FRM_LOGO_H_LOC + SZ_LOGO_WIDTH + 1;
constant LOGO_TOP 			: natural := FRM_LOGO_V_LOC - 1;
constant LOGO_BOTTOM 		: natural := FRM_LOGO_V_LOC + SZ_LOGO_HEIGHT + 1;

-------------------------------------------------------------------------

-- Signal Declarations

-------------------------------------------------------------------------


-------------------------------------------------------------------------

-- VGA Controller specific signals: Counters, Sync, R, G, B

-------------------------------------------------------------------------
-- Pixel clock, in this case 108 MHz
signal pxl_clk : std_logic;
-- The active signal is used to signal the active region of the screen (when not blank)
signal active  : std_logic;

-- Horizontal and Vertical counters
signal h_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');
signal v_cntr_reg : std_logic_vector(11 downto 0) := (others =>'0');

-- Pipe Horizontal and Vertical Counters
signal h_cntr_reg_dly   : std_logic_vector(11 downto 0) := (others => '0');
signal v_cntr_reg_dly   : std_logic_vector(11 downto 0) := (others => '0');

-- Horizontal and Vertical Sync
signal h_sync_reg : std_logic := not(H_POL);
signal v_sync_reg : std_logic := not(V_POL);
-- Pipe Horizontal and Vertical Sync
signal h_sync_reg_dly : std_logic := not(H_POL);
signal v_sync_reg_dly : std_logic :=  not(V_POL);

-- VGA R, G and B signals coming from the main multiplexers
signal vga_red_cmb   : std_logic_vector(3 downto 0);
signal vga_green_cmb : std_logic_vector(3 downto 0);
signal vga_blue_cmb  : std_logic_vector(3 downto 0);
--The main VGA R, G and B signals, validated by active
signal vga_red    : std_logic_vector(3 downto 0);
signal vga_green  : std_logic_vector(3 downto 0);
signal vga_blue   : std_logic_vector(3 downto 0);
-- Register VGA R, G and B signals
signal vga_red_reg   : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_green_reg : std_logic_vector(3 downto 0) := (others =>'0');
signal vga_blue_reg  : std_logic_vector(3 downto 0) := (others =>'0');


-----------------------------------------------------------
-- Signals for generating the background (moving colorbar)
-----------------------------------------------------------
signal cntDyn				: integer range 0 to 2**28-1; -- counter for generating the colorbar
signal intHcnt				: integer range 0 to H_MAX - 1;
signal intVcnt				: integer range 0 to V_MAX - 1;
-- Colorbar red, greeen and blue signals
signal bg_red 				: std_logic_vector(3 downto 0);
signal bg_blue 			: std_logic_vector(3 downto 0);
signal bg_green 			: std_logic_vector(3 downto 0);
-- Pipe the colorbar red, green and blue signals
signal bg_red_dly			: std_logic_vector(3 downto 0) := (others => '0');
signal bg_green_dly		: std_logic_vector(3 downto 0) := (others => '0');
signal bg_blue_dly		: std_logic_vector(3 downto 0) := (others => '0');


-------------------------------------------------------------------------

-- Interconnection signals for the displaying components

-------------------------------------------------------------------------

-- Digilent and Analog Devices logo display signals
signal logo_red   : std_logic_vector(3 downto 0);
signal logo_blue 	: std_logic_vector(3 downto 0);
signal logo_green : std_logic_vector(3 downto 0);

-- Overlay display signal
signal overlay_en : std_logic;

---------------------------------------------------------------------------------

-- Pipe all of the interconnection signals coming from the displaying components

---------------------------------------------------------------------------------

-- Registered Digilent and Analog Devices logo display signals
signal logo_red_dly			: std_logic_vector(3 downto 0);
signal logo_blue_dly 		: std_logic_vector(3 downto 0);
signal logo_green_dly 		: std_logic_vector(3 downto 0);

-- Registered Overlay display signal
signal overlay_en_dly : std_logic; 

begin
  
  pxl_clk <= CLK_I; 
------------------------------------

-- Generate the 108 MHz pixel clock 

------------------------------------
--   Inst_PxlClkGen: PxlClkGen
--   port map
--    (-- Clock in ports
--     CLK_IN1   => CLK_I,
--     -- Clock out ports
--     CLK_OUT1  => pxl_clk,
--     -- Status and control signals
--     LOCKED   => open
--    );

---------------------------------------------------------------

-- Generate Horizontal, Vertical counters and the Sync signals

---------------------------------------------------------------
  -- Horizontal counter
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (h_cntr_reg = (H_MAX - 1)) then
        h_cntr_reg <= (others =>'0');
      else
        h_cntr_reg <= h_cntr_reg + 1;
      end if;
    end if;
  end process;
  -- Vertical counter
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if ((h_cntr_reg = (H_MAX - 1)) and (v_cntr_reg = (V_MAX - 1))) then
        v_cntr_reg <= (others =>'0');
      elsif (h_cntr_reg = (H_MAX - 1)) then
        v_cntr_reg <= v_cntr_reg + 1;
      end if;
    end if;
  end process;
  -- Horizontal sync
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (h_cntr_reg >= (H_FP + FRAME_WIDTH - 1)) and (h_cntr_reg < (H_FP + FRAME_WIDTH + H_PW - 1)) then
        h_sync_reg <= H_POL;
      else
        h_sync_reg <= not(H_POL);
      end if;
    end if;
  end process;
  -- Vertical sync
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
      if (v_cntr_reg >= (V_FP + FRAME_HEIGHT - 1)) and (v_cntr_reg < (V_FP + FRAME_HEIGHT + V_PW - 1)) then
        v_sync_reg <= V_POL;
      else
        v_sync_reg <= not(V_POL);
      end if;
    end if;
  end process;
  
--------------------

-- The active 

--------------------  
  -- active signal
  active <= '1' when h_cntr_reg_dly < FRAME_WIDTH and v_cntr_reg_dly < FRAME_HEIGHT
            else '0';


--------------------------

-- Logo display instance

--------------------------
 	Inst_LogoDisplay: LogoDisplay 
	GENERIC MAP(
		X_START	=> FRM_LOGO_H_LOC,
		Y_START	=> FRM_LOGO_V_LOC
	)
	PORT MAP(
		CLK_I => pxl_clk,
		H_COUNT_I => h_cntr_reg,
		V_COUNT_I => v_cntr_reg,
		RED_O    => logo_red,
		BLUE_O   => logo_blue,
		GREEN_O  => logo_green
	);
 
----------------------------------

-- Overlay display instance

----------------------------------
    	Inst_OverlayCtrl: OverlayCtl 
      PORT MAP
      (
		CLK_I       => pxl_clk,
		VSYNC_I     => v_sync_reg,
		ACTIVE_I    => active,
		OVERLAY_O   => overlay_en
      );
  
  
---------------------------------------

-- Generate moving colorbar background

---------------------------------------

	process(pxl_clk)
	begin
		if(rising_edge(pxl_clk)) then
			cntdyn <= cntdyn + 1;
		end if;
	end process;
   
  	intHcnt <= conv_integer(h_cntr_reg);
	intVcnt <= conv_integer(v_cntr_reg);
	
	bg_red <= conv_std_logic_vector((-intvcnt - inthcnt - cntDyn/2**20),8)(7 downto 4);
	bg_green <= conv_std_logic_vector((inthcnt - cntDyn/2**20),8)(7 downto 4);
	bg_blue <= conv_std_logic_vector((intvcnt - cntDyn/2**20),8)(7 downto 4);

---------------------------------------------------------------------------------------------------

-- Register Outputs coming from the displaying components and the horizontal and vertical counters

---------------------------------------------------------------------------------------------------
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then
   
      logo_red_dly		<= logo_red;
		logo_green_dly	   <= logo_green;
		logo_blue_dly		<= logo_blue;

      overlay_en_dly <= overlay_en;
      
      h_cntr_reg_dly <= h_cntr_reg;
		v_cntr_reg_dly <= v_cntr_reg;
      
      
    end if;
  end process;


-------------------------------------------------------------

-- Main Multiplexers for the VGA Red, Green and Blue signals

-------------------------------------------------------------
----------
-- Red
----------

  vga_red <=   -- Mouse_cursor_display is on the top of others
               -- Overlay display is black 
               x"0" when overlay_en_dly = '1'
               else
               -- logo display
               logo_red_dly when h_cntr_reg_dly > LOGO_LEFT and h_cntr_reg_dly < LOGO_RIGHT 
                             and v_cntr_reg_dly < LOGO_BOTTOM and v_cntr_reg_dly > LOGO_TOP               
               else
               -- Colorbar will be on the backround
               bg_red_dly;
                
-----------
-- Green
-----------

  vga_green <= -- Mouse_cursor_display is on the top of others
               -- Overlay display is black 
               x"0" when overlay_en_dly = '1'
               else
               -- logo display
               logo_green_dly when h_cntr_reg_dly > LOGO_LEFT and h_cntr_reg_dly < LOGO_RIGHT 
                               and v_cntr_reg_dly < LOGO_BOTTOM and v_cntr_reg_dly > LOGO_TOP
               else
               -- Colorbar will be on the backround
               bg_green_dly;

-----------
-- Blue
-----------

  vga_blue <=  -- Mouse_cursor_display is on the top of others
               -- Overlay display is black 
               x"0" when overlay_en_dly = '1'
               else
               -- logo display
               logo_blue_dly when h_cntr_reg_dly > LOGO_LEFT and h_cntr_reg_dly < LOGO_RIGHT 
                              and v_cntr_reg_dly < LOGO_BOTTOM and v_cntr_reg_dly > LOGO_TOP
               else
               -- Colorbar will be on the backround
               bg_blue_dly;
                

------------------------------------------------------------
-- Turn Off VGA RBG Signals if outside of the active screen
-- Make a 4-bit AND logic with the R, G and B signals
------------------------------------------------------------
 vga_red_cmb <= (active & active & active & active) and vga_red;
 vga_green_cmb <= (active & active & active & active) and vga_green;
 vga_blue_cmb <= (active & active & active & active) and vga_blue;
 

 -- Register Outputs
  process (pxl_clk)
  begin
    if (rising_edge(pxl_clk)) then

      v_sync_reg_dly <= v_sync_reg;
      h_sync_reg_dly <= h_sync_reg;
      vga_red_reg    <= vga_red_cmb;
      vga_green_reg  <= vga_green_cmb;
      vga_blue_reg   <= vga_blue_cmb;      
    end if;
  end process;

  -- Assign outputs
  VGA_HS_O     <= h_sync_reg_dly;
  VGA_VS_O     <= v_sync_reg_dly;
  VGA_RED_O    <= vga_red_reg;
  VGA_GREEN_O  <= vga_green_reg;
  VGA_BLUE_O   <= vga_blue_reg;

end Behavioral;