--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     keypad_pkg.vhd
-- Create date:     Thu Mar 21 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package keypad is

    ----------------------------------------------------------------
    -- four-by-four keypad
    ----------------------------------------------------------------
    component keypad4x4
        generic (
            KEY_SCAN_TICKS : positive
        );
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            i_col : in std_logic_vector(3 downto 0);
            o_row : out std_logic_vector(3 downto 0);
            o_key : out std_logic_vector(15 downto 0)
        );
    end component;

end package;
