--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     flipflop.vhd
-- Create date:     Wed Mar 13 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package flipflop is

    ----------------------------------------------------------------
    -- JK-flipflop with clock enable and synchronous reset.
    ----------------------------------------------------------------
    component jk_ff
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            i_j   : in std_logic;
            i_k   : in std_logic;
            o_q   : out std_logic
        );
    end component;

end package;
