--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     sync.vhd
-- Create date:     Thu Mar 14 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package sync is

    subtype t_sync_depth is integer range 2 to 16;

    ----------------------------------------------------------------
    -- Synchronize a reset signal across clock domain boundaries.
    ----------------------------------------------------------------
    component sync_rst
        generic (
            D : t_sync_depth := t_sync_depth'low
        );
        port (
            i_clk   : in std_logic;
            i_async : in std_logic;
            o_sync  : out std_logic
        );
    end component;

    ----------------------------------------------------------------
    -- Synchronize a signal across clock-domain boundaries.
    ----------------------------------------------------------------
    component sync_sig
        generic (
            I : bit := '0';
            D : t_sync_depth := t_sync_depth'low
        );
        port (
            i_clk   : in std_logic;
            i_async : in std_logic;
            o_sync  : out std_logic
        );

    end component;

end package;
