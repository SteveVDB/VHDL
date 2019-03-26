--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     shift_register.vhd
-- Create date:     Wed Mar 13 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package shift_reg is

    ----------------------------------------------------------------
    -- N-bit shift register with synchronous load.
    ----------------------------------------------------------------
    component shift_reg_sl
        generic (
            N : positive
        );
        port (
            i_clk : in std_logic;
            i_pl  : in std_logic;
            i_ce  : in std_logic;
            i_dir : in std_logic;
            i_ser : in std_logic;
            i_par : in std_logic_vector(N-1 downto 0);
            o_reg : out std_logic_vector(N-1 downto 0)
        );
    end component;

end package;
