--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     display.vhd
-- Create date:     Wed Mar 13 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package display is

    ----------------------------------------------------------------
    -- quad 7-segment display driver
    ---------------------------------------------------------------
    component seg4x7
        generic (
            LOW_SIDE_LEVEL  : bit := '0';
            HIGH_SIDE_LEVEL : bit := '1';
            MULTIPLEX_TICKS : positive;
            GHOSTING_TICKS  : positive := 1
        );
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            i_blk : in std_logic;
            i_bcd : in std_logic_vector(15 downto 0);
            o_lsd : out std_logic_vector(6 downto 0);
            o_hsd : out std_logic_vector(3 downto 0)
        );
    end component;

end package;
