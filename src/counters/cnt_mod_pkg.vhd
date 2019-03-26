--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     counter_modulo.vhd
-- Description:     modulo counters
-- Create date:     Wed Mar 13 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package cnt_mod is

    ----------------------------------------------------------------
    -- modulo 6 counter
    ----------------------------------------------------------------
    component mod_cnt6
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            i_dir : in std_logic;
            o_bcd : out std_logic_vector(2 downto 0);
            o_tc  : out std_logic;
            o_rc  : out std_logic
        );
    end component;

    ----------------------------------------------------------------
    -- modulo 10 counter
    ----------------------------------------------------------------
    component mod_cnt10
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            i_dir : in std_logic;
            o_bcd : out std_logic_vector(3 downto 0);
            o_tc  : out std_logic;
            o_rc  : out std_logic
        );
    end component;

end package;
