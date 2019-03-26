--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     memory.vhd
-- Create date:     Thu Mar 14 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package memory is

    ----------------------------------------------------------------
    -- single port RAM
    ----------------------------------------------------------------
    component ram_sp
        generic (
            A_BITS      : positive;
            D_BITS      : positive;
            INIT_VALUE  : bit := '0';
            INIT_FILE   : string := "none";
            FILE_FORMAT : string := "bin"
        );
        port (
            i_clk  : in std_logic;
            i_ce   : in std_logic;
            i_we   : in std_logic;
            i_addr : in std_logic_vector(A_BITS-1 downto 0);
            i_data : in std_logic_vector(D_BITS-1 downto 0);
            o_data : out std_logic_vector(D_BITS-1 downto 0)
        );
    end component;

    ----------------------------------------------------------------
    -- pseudo dual port RAM
    ----------------------------------------------------------------
    component ram_dp
        generic (
            A_BITS      : positive;
            D_BITS      : positive;
            INIT_VALUE  : bit := '0';
            INIT_FILE   : string := "none";
            FILE_FORMAT : string := "bin"
        );
        port (
            i_wr_clk  : in std_logic;
            i_wr_ce   : in std_logic;
            i_wr_en   : in std_logic;
            i_wr_addr : in std_logic_vector(A_BITS-1 downto 0);
            i_wr_data : in std_logic_vector(D_BITS-1 downto 0);
            i_rd_clk  : in std_logic;
            i_rd_ce   : in std_logic;
            i_rd_en   : in std_logic;
            i_rd_addr : in std_logic_vector(A_BITS-1 downto 0);
            o_rd_data : out std_logic_vector(D_BITS-1 downto 0)
        );
    end component;



end package;
