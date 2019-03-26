--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     uart.vhd
-- Create date:     Thu Mar 14 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package uart is

    ----------------------------------------------------------------
    -- UART receiver
    ----------------------------------------------------------------
    component uart_rx
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_enb : in std_logic;
            i_rx  : in std_logic;
            i_nsb : in std_logic;
            i_pds : in std_logic_vector(1 downto 0);
            i_brv : in std_logic_vector(7 downto 0);
            o_rxd : out std_logic_vector(7 downto 0);
            o_rx8 : out std_logic;
            o_frs : out std_logic;
            o_fps : out std_logic;
            o_fes : out std_logic
        );
    end component;

    ----------------------------------------------------------------
    -- UART transmitter
    ----------------------------------------------------------------

end package;
