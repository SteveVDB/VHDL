--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     lattice.vhd
-- Create date:     Thu Mar 14 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package lattice is

    -- iCE40HX8K breakout board reference clock [Hz]
    constant HX8K_DEV_CLK : positive := 12000000;

    ----------------------------------------------------------------
    -- 48MHz PLL clock generator for iCE40 FPGA.
    ----------------------------------------------------------------
    component pll_clk48
        port (
            i_ref    : in std_logic;
            i_rst    : in std_logic;
            o_core   : out std_logic;
            o_global : out std_logic
        );
    end component;

end package;
