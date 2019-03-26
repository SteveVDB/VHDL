--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     timer_4d.vhd
-- Description:     4-digit timer (00:00 - 59:59)
-- Create date:     Thu Mar 14 2019
--
-- up: i_dir = '1'
-- terminal count high when output is X5959
--
-- down: i_dir = '0'
-- terminal count high when output is X0000
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.utils.all;
use SVDB.cnt_mod.all;

entity timer_4d is
    port (
        i_clk : in std_logic;                       -- clock
        i_rst : in std_logic;                       -- reset
        i_ce  : in std_logic;                       -- clock enable
        i_dir : in std_logic;                       -- count up/down
        o_bcd : out std_logic_vector(15 downto 0);  -- timer output
        o_tc  : out std_logic;                      -- terminal count
        o_rc  : out std_logic                       -- ripple count
    );
end ;

architecture behavioral of timer_4d is

    signal s_ce  : std_logic_vector(4 downto 0);
    signal s_tc  : std_logic_vector(3 downto 0);
    signal s_bcd : std_logic_vector(15 downto 0);

begin

    s_ce(0)   <= i_ce;
    s_bcd(7)  <= '0';
    s_bcd(15) <= '0';

    G0: for i in 0 to 3 generate
        GU: if i mod 2 = 0 generate
            UU: mod_cnt10
            port map (
                i_clk => i_clk,
                i_rst => i_rst,
                i_ce  => s_ce(i),
                i_dir => i_dir,
                o_bcd => s_bcd(3+(i*4) downto (i*4)),
                o_tc  => s_tc(i),
                o_rc  => s_ce(i+1)
            );
        end generate;

        GT: if i mod 2 /= 0 generate
            UT: mod_cnt6
            port map (
                i_clk => i_clk,
                i_rst => i_rst,
                i_ce  => s_ce(i),
                i_dir => i_dir,
                o_bcd => s_bcd(2+(i*4) downto (i*4)),
                o_tc  => s_tc(i),
                o_rc  => s_ce(i+1)
            );
        end generate;
    end generate;

    o_tc  <= slv_and(s_tc);
    o_rc  <= s_ce(4);
    o_bcd <= s_bcd;

end;
