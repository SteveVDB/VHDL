--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     encoder_pkg.vhd
-- Create date:     Mon Mar 25 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package encoder is

    ----------------------------------------------------------------
    -- N-bit priority encoder.
    ----------------------------------------------------------------
    component p_encoder is
        generic (
            N : positive := 8;
            R : positive := 3
        );
        port (
            i_enb  : in std_logic;
            i_data : in std_logic_vector(N-1 downto 0);
            o_bin  : out std_logic_vector(R-1 downto 0);
            o_gsel : out std_logic;
            o_enb  : out std_logic
        );
    end component;

end package;
