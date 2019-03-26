--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     counter_generic.vhd
-- Description:     generic N-bit counters
-- Create date:     Wed Mar 13 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package cnt_gen is

    ----------------------------------------------------------------
    -- N-bit counter with synchronous reset.
    ----------------------------------------------------------------
    component cnt_sr
        generic (
            N : positive
        );
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            o_cnt : out std_logic_vector(N-1 downto 0)
        );
    end component;

    ----------------------------------------------------------------
    -- N-bit counter with synchronous reset, and parallel load.
    ----------------------------------------------------------------
    component cnt_srl
        generic (
            N : positive
        );
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            i_pl  : in std_logic;
            i_par : in std_logic_vector(N-1 downto 0);
            o_cnt : out std_logic_vector(N-1 downto 0)
        );
    end component;

    ----------------------------------------------------------------
    -- N-bit counter with synchronous reset, parallel load, and
    -- count direction.
    ----------------------------------------------------------------
    component cnt_srld
        generic (
            N : positive
        );
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            i_pl  : in std_logic;
            i_dir : in std_logic;
            i_par : in std_logic_vector(N-1 downto 0);
            o_cnt : out std_logic_vector(N-1 downto 0)
        );
    end component;

end package;
