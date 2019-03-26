--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     ice_clk48.vhd
-- Description:     48MHz PLL clock generator for iCE40 FPGA.
-- Create date:     Thu Mar 14 2019
--
-- reference clock: 12MHz (ice40HX-8K breakout board)
--
-- Output 'o_core' drives regular FPGA routing.
-- Output 'o_global' drives a global clock (GBUF4/GBUF5) network on the FPGA.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity pll_clk48 is
    port (
        i_ref    : in std_logic;        -- reference clock
        i_rst    : in std_logic;        -- active low reset
        o_core   : out std_logic;       -- core clock
        o_global : out std_logic        -- global clock
    );
end pll_clk48;

architecture behavioral of pll_clk48 is

    component SB_PLL40_CORE
        generic (
            FEEDBACK_PATH                   : string := "SIMPLE";
            DELAY_ADJUSTMENT_MODE_FEEDBACK  : string := "FIXED";
            DELAY_ADJUSTMENT_MODE_RELATIVE  : string := "FIXED";
            SHIFTREG_DIV_MODE               : bit_vector(1 downto 0) := "00";
            FDA_FEEDBACK                    : bit_vector(3 downto 0) := "0000";
            FDA_RELATIVE                    : bit_vector(3 downto 0) := "0000";
            PLLOUT_SELECT                   : string := "GENCLK";
            DIVF                            : bit_vector(6 downto 0);
            DIVR                            : bit_vector(3 downto 0);
            DIVQ                            : bit_vector(2 downto 0);
            FILTER_RANGE                    : bit_vector(2 downto 0);
            ENABLE_ICEGATE                  : bit := '0';
            TEST_MODE                       : bit := '0';
            EXTERNAL_DIVIDE_FACTOR          : integer := 1
        );
        port (
            REFERENCECLK                    : in std_logic;
            PLLOUTCORE                      : out std_logic;
            PLLOUTGLOBAL                    : out std_logic;
            EXTFEEDBACK                     : in std_logic;
            DYNAMICDELAY                    : in std_logic_vector (7 downto 0);
            LOCK                            : out std_logic;
            BYPASS                          : in std_logic;
            RESETB                          : in std_logic;
            LATCHINPUTVALUE                 : in std_logic;
            SDO                             : out std_logic;
            SDI                             : in std_logic;
            SCLK                            : in std_logic
        );
    end component;

    signal s_open_wire : std_logic := '0';
    signal s_open_bus  : std_logic_vector(7 downto 0) := (others => '0');

begin

    U0: SB_PLL40_CORE
    generic map (
        DIVR                                => "0000",
        DIVF                                => "0111111",
        DIVQ                                => "100",
        FILTER_RANGE                        => "001",
        FEEDBACK_PATH                       => "SIMPLE",
        FDA_FEEDBACK                        => "0000",
        DELAY_ADJUSTMENT_MODE_FEEDBACK      => "FIXED",
        DELAY_ADJUSTMENT_MODE_RELATIVE      => "FIXED",
        FDA_RELATIVE                        => "0000",
        SHIFTREG_DIV_MODE                   => "00",
        PLLOUT_SELECT                       => "GENCLK",
        ENABLE_ICEGATE                      => '0'
    )
    port map (
        REFERENCECLK                        => i_ref,
        PLLOUTCORE                          => o_core,
        PLLOUTGLOBAL                        => o_global,
        EXTFEEDBACK                         => s_open_wire,
        DYNAMICDELAY                        => s_open_bus,
        RESETB                              => i_rst,
        BYPASS                              => '0',
        LATCHINPUTVALUE                     => s_open_wire,
        LOCK                                => open,
        SDI                                 => s_open_wire,
        SDO                                 => open,
        SCLK                                => s_open_wire
    );

end;
