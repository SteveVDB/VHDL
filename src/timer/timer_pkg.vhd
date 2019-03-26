--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     timer.vhd
-- Create date:     Thu Mar 14 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package timer is

    ----------------------------------------------------------------
    -- 4-digit timer (00:00 - 59:59)
    ----------------------------------------------------------------
    component timer_4d
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            i_dir : in std_logic;
            o_bcd : out std_logic_vector(15 downto 0);
            o_tc  : out std_logic;
            o_rc  : out std_logic
        );
    end component;

end package;
