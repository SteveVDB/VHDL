--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     seg4x7.vhd
-- Description:     quad 7-segment display driver
-- Create date:     Thu Jan 24 2019
--------------------------------------------------------------------------------
--
-- display layout:
--
--       -------------------------------------------- D3 <- o_hsd(3)
--       |          --------------------------------- D2 <- o_hsd(2)
--       |          |          ---------------------- D1 <- o_hsd(1)
--       |          |          |          ----------- D0 <- o_hsd(0)
--       |          |          |          |
---------|----------|----------|----------|-----
-- |  -------    -------    -------    -------  |---- SA <- o_lsd(6)
-- | |       |  |       |  |       |  |       | |---- SB <- o_lsd(5)
-- | |       |  |       |  |       |  |       | |---- SC <- o_lsd(4)
-- |  -------    -------    -------    -------  |---- SD <- o_lsd(3)
-- | |       |  |       |  |       |  |       | |---- SE <- o_lsd(2)
-- | |       |  |       |  |       |  |       | |---- SF <- o_lsd(1)
-- |  -------    -------    -------    -------  |---- SG <- o_lsd(0)
-------------------------------------------------
--
-- notes:
-- - common anode display:    HIGH_SIDE_LEVEL= '1', LOW_SIDE_LEVEL: '0'
-- - common cathode display:  HIGH_SIDE_LEVEL= '0', LOW_SIDE_LEVEL: '1'
--
-- blank leading zero when "i_blk" = '1'
--
-- The anti-ghosting feature adds a dead time to the start and end of each
-- high side drive output pulse. By doing this, the low side drive outputs
-- change there state when all digits are off and possible ghosting is
-- eliminated. The dead time is defined by GHOSTING_TICKS, and should be much
-- lower than the MULTIPLEX_TICKS value.
--
-- MULTIPLEX_TICKS = F_CLK / (4 * DIV * refresh_rate)
-- GHOSTING_TICKS  = F_CLK / (DIV * dead_time)
--
-- DIV = F_CLK devider
-- - clock enable connected to a logic '1'       => DIV = 1
-- - clock enable connected to a strobe signal   => DIV = F_CLK / F_STROBE
--
-- e.g. F_CLK: 40MHz, DIV: 2000 refresh_rate: 50Hz, dead_time: 100us
-- - MULTIPLEX_TICKS = 100
-- - GHOSTING_TICKS  = 2
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library SVDB;
use SVDB.utils.all;
use SVDB.cnt_gen.all;
use SVDB.disp_utils.all;

entity seg4x7 is
    generic (
        LOW_SIDE_LEVEL  : bit      := '0';          -- low side active level
        HIGH_SIDE_LEVEL : bit      := '1';          -- high side active level
        MULTIPLEX_TICKS : positive := 10;           -- multiplex value [ticks]
        GHOSTING_TICKS  : positive := 1             -- ghosting value [ticks]
    );
    port (
        i_clk : in std_logic;                       -- clock
        i_rst : in std_logic;                       -- reset
        i_ce  : in std_logic;                       -- clock enable
        i_blk : in std_logic;                       -- blank control
        i_bcd : in std_logic_vector(15 downto 0);   -- display input (BCD)
        o_lsd : out std_logic_vector(6 downto 0);   -- low side drive output
        o_hsd : out std_logic_vector(3 downto 0)    -- high side drive output
    );
end seg4x7;

architecture behavioral of seg4x7 is

    constant T : integer := MULTIPLEX_TICKS-1;
    constant R : integer := ceil_log2(T);

    constant LB : std_logic_vector := to_slv(GHOSTING_TICKS-1, R);
    constant HB : std_logic_vector := to_slv(T-GHOSTING_TICKS+1, R);

    signal s_blk : std_logic_vector(3 downto 0);

    signal s_rst, s_top, s_don : std_logic;
    signal s_tmr : std_logic_vector(R-1 downto 0);

    signal s_seg : std_logic_vector(1 downto 0);
    signal s_bcd : std_logic_vector(3 downto 0);

begin

    ----------------------------------------------------------------
    -- blank leading zeros
    ----------------------------------------------------------------
    s_blk(0) <= '0';
    s_blk(1) <= i_blk and not slv_or(i_bcd(15 downto  4));
    s_blk(2) <= i_blk and not slv_or(i_bcd(15 downto  8));
    s_blk(3) <= i_blk and not slv_or(i_bcd(15 downto 12));

    ----------------------------------------------------------------
    -- display multiplex timer
    ----------------------------------------------------------------
    U0: cnt_sr generic map(N => R)
    port map(i_clk, s_rst, i_ce, s_tmr);

    s_rst <= i_rst or s_top;
    s_top <= equ(s_tmr, to_slv(T, R));

    -- digit on-time
    s_don <= '1' when s_tmr > LB and s_tmr < HB else '0';

    ----------------------------------------------------------------
    -- segment select
    ----------------------------------------------------------------
    U1: cnt_sr generic map(N => 2)
    port map(i_clk, i_rst, s_top, s_seg);

	process(s_seg, i_bcd)
    begin
        case s_seg is
            when "00" 	=> s_bcd <= i_bcd( 3 downto  0);
            when "01" 	=> s_bcd <= i_bcd( 7 downto  4);
            when "10" 	=> s_bcd <= i_bcd(11 downto  8);
            when others => s_bcd <= i_bcd(15 downto 12);
        end case;
    end process;

    ----------------------------------------------------------------
    -- high side drive
    ----------------------------------------------------------------
    G0: if HIGH_SIDE_LEVEL = '0' generate
        o_hsd(0) <=     s_seg(1) or     s_seg(0) or not s_don or s_blk(0);
        o_hsd(1) <=     s_seg(1) or not s_seg(0) or not s_don or s_blk(1);
        o_hsd(2) <= not s_seg(1) or     s_seg(0) or not s_don or s_blk(2);
        o_hsd(3) <= not s_seg(1) or not s_seg(0) or not s_don or s_blk(3);
    end generate;

    G1: if HIGH_SIDE_LEVEL = '1' generate
        o_hsd(0) <= not s_seg(1) and not s_seg(0) and s_don and not s_blk(0);
        o_hsd(1) <= not s_seg(1) and     s_seg(0) and s_don and not s_blk(1);
        o_hsd(2) <=     s_seg(1) and not s_seg(0) and s_don and not s_blk(2);
        o_hsd(3) <=     s_seg(1) and     s_seg(0) and s_don and not s_blk(3);
    end generate;

    ----------------------------------------------------------------
    -- low side drive
    ----------------------------------------------------------------
    o_lsd <= decode7(s_bcd, LOW_SIDE_LEVEL);

end;
