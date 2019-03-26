--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     mod_cnt10
-- Description:     Modulo 10 up/down counter with JK-flipflops
-- Create date:     Tue Mar 12 2019
--
-- state diagram:
--
-- up: i_dir = 1
-- 0->1->2->3->4->5->6->7->8->9->0->1->...
-- 10->11->6->... / 12->13->4->... / 14->15->2->...
--
-- down: i_dir = 0
-- 0->9->8->7->6->5->4->3->2->1->0->9->...
-- 15->14->13->12->-11->10->9->...
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.utils.all;
use SVDB.flipflop.all;

entity mod_cnt10 is
    port (
        i_clk : in std_logic;                       -- clock
        i_rst : in std_logic;                       -- reset
        i_ce  : in std_logic;                       -- clock enable
        i_dir : in std_logic;                       -- count up/down
        o_bcd : out std_logic_vector(3 downto 0);   -- counter output
        o_tc  : out std_logic;                      -- terminal count
        o_rc  : out std_logic                       -- ripple count
    );
end mod_cnt10;

architecture behavioral of mod_cnt10 is

    signal s_tc : std_logic;
    signal s_j, s_k, r_q : std_logic_vector(3 downto 0);

begin

    ----------------------------------------------------------------
    -- next state logic
    ----------------------------------------------------------------
    s_j(0) <=  '1';

    s_j(1) <= (i_dir and not r_q(3) and r_q(0)) or
        (not i_dir and not r_q(0) and (r_q(3) or r_q(2) or r_q(1)));

    s_j(2) <= (i_dir and r_q(1) and r_q(0)) or
        (not i_dir and not r_q(1) and not r_q(0) and (r_q(3) or r_q(2)));

    s_j(3) <= (i_dir and r_q(0) and (r_q(3) or (r_q(2) and r_q(1)))) or
        (not i_dir and not r_q(2) and not r_q(1) and not r_q(0));

    s_k <= s_j;

    ----------------------------------------------------------------
    -- terminal and ripple count
    ----------------------------------------------------------------
    s_tc <= (i_dir and equ(r_q, "1001")) or (not i_dir and equ(r_q, "0000"));

    o_tc <= s_tc;
    o_rc <= s_tc and i_ce;

    ----------------------------------------------------------------
    -- 4x JK-flipflop
    ----------------------------------------------------------------
    G0: for i in 0 to 3 generate
    begin
        UX: jk_ff
        port map(i_clk, i_rst, i_ce, s_j(i), s_k(i), r_q(i));
    end generate;

    o_bcd <= r_q;

end;
