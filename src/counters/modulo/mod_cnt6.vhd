--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     mod_cnt6.vhd
-- Description:     Modulo 6 up/down counter with JK-flipflops
-- Create date:     Tue Mar 12 2019
--
-- state diagram
--
-- up: i_dir = 1
-- 0->1->2->3->4->5->0->1... / 6->7->2->...
--
-- down: i_dir = 0
-- 0->5->4->3->2->1->0->5... / 7->6->5->...
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.utils.all;
use SVDB.flipflop.all;

entity mod_cnt6 is
    port (
        i_clk : in std_logic;                       -- clock
        i_rst : in std_logic;                       -- reset
        i_ce  : in std_logic;                       -- clock enable
        i_dir : in std_logic;                       -- count up/down
        o_bcd : out std_logic_vector(2 downto 0);   -- counter output
        o_tc  : out std_logic;                      -- terminal count
        o_rc  : out std_logic                       -- ripple count
    );
end ;

architecture behavioral of mod_cnt6 is

    signal s_tc : std_logic;
    signal s_j, s_k, r_q : std_logic_vector(2 downto 0);

begin

    ----------------------------------------------------------------
    -- next state logic
    ----------------------------------------------------------------
    s_j(0) <= '1';

    s_j(1) <= (i_dir and not r_q(2) and r_q(0)) or
        (not i_dir and not r_q(0) and (r_q(2) or r_q(1)));

    s_j(2) <= (i_dir and r_q(0) and (r_q(2) or r_q(1))) or
        (not i_dir and not r_q(1) and not r_q(0));

    s_k <= s_j;

    ----------------------------------------------------------------
    -- terminal and ripple count
    ----------------------------------------------------------------
    s_tc <= (i_dir and equ(r_q, "101")) or (not i_dir and equ(r_q, "000"));

    o_tc <= s_tc;
    o_rc <= s_tc and i_ce;

    ----------------------------------------------------------------
    -- 3x JK-flipflop
    ----------------------------------------------------------------
    G0: for i in 0 to 2 generate
    begin
        UX: jk_ff
        port map(i_clk, i_rst, i_ce, s_j(i), s_k(i), r_q(i));
    end generate;

    o_bcd <= r_q;

end;
