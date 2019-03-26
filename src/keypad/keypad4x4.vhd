--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     keypad4x4.vhd
-- Description:     four-by-four keypad
-- Create date:     Wed Mar 20 2019
--------------------------------------------------------------------------------
--
-- keypad layout:
-- Active high buttons with external pull-down resistors.
--
-- -----------------------------
-- |BTN_15|BTN_14|BTN_13|BTN_12|-- R3 <- o_row(3)
-- |BTN_11|BTN_10|BTN_09|BTN_08|-- R2 <- o_row(2)
-- |BTN_07|BTN_06|BTN_05|BTN_04|-- R1 <- o_row(1)
-- |BTN_03|BTN_02|BTN_01|BTN_00|-- R0 <- o_row(0)
-- -----------------------------
--    |      |      |      |
--    |      |      |      ------- C0 -> i_col(0)
--    |      |      -------------- C1 -> i_col(1)
--    |      --------------------- C2 -> i_col(2)
--    ---------------------------- C3 -> i_col(3)
--
-- notes:
-- - tri-state buffers on row outputs
-- - 2-stage synchronizer on column inputs
--
-- The keys are scanned at debounce_time intervals:
-- KEY_SCAN_TICKS = (F_CLK * debounce_time) / (8 * DIV)
--
-- DIV = F_CLK divider
-- - clock enable connected to a logic '1'       => DIV = 1
-- - clock enable connected to a strobe signal   => DIV = F_CLK / F_STROBE
--
-- e.g. F_CLK: 40MHz, DIV: 2000, debounce_time: 20ms
-- - KEY_SCAN_TICKS = 50
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.sync.all;
use SVDB.utils.all;
use SVDB.cnt_gen.all;

entity keypad4x4 is
    generic (
        KEY_SCAN_TICKS : positive := 10             -- key scan value [ticks]
    );
    port (
        i_clk : in std_logic;                       -- clock
        i_rst : in std_logic;                       -- reset
        i_ce  : in std_logic;                       -- clock enable
        i_col : in std_logic_vector(3 downto 0);    -- column inputs
        o_row : out std_logic_vector(3 downto 0);   -- row outputs
        o_key : out std_logic_vector(15 downto 0)   -- keypad status
    );
end keypad4x4;

architecture behavioral of keypad4x4 is

    constant T : integer := KEY_SCAN_TICKS - 1;
    constant R : integer := ceil_log2(T);

    signal s_rst, s_top : std_logic;
    signal s_tmr : std_logic_vector(R-1 downto 0);

    signal r_ctl, s_sample, s_select : std_logic;

    signal s_in : std_logic;
    signal r_oe : std_logic_vector(3 downto 0);

    signal s_col : std_logic_vector(3 downto 0);

begin

    ----------------------------------------------------------------
    -- keypad scan timing
    ----------------------------------------------------------------
    U0: cnt_sr generic map(N => R)
    port map(i_clk, s_rst, i_ce, s_tmr);

    s_rst <= i_rst or s_top;
    s_top <= equ(s_tmr, to_slv(T, R));

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                r_ctl <= '0';
            elsif s_top = '1' then
                r_ctl <= not r_ctl;
            end if;
        end if;
    end process;

    s_sample <= r_ctl and s_top;        -- column sample signal
    s_select <= not r_ctl and s_top;    -- row select signal

    ----------------------------------------------------------------
    -- row select
    ----------------------------------------------------------------
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                r_oe <= "0000";
            elsif s_select = '1' then
                r_oe <= r_oe(2 downto 0) & s_in;
            end if;
        end if;
    end process;

    s_in <= not slv_or(r_oe(2 downto 0));

    -- row output tri-state buffers
    G0: for i in 0 to 3 generate
        o_row(i) <= '1' when r_oe(i) = '1' else 'Z';
    end generate;

    ----------------------------------------------------------------
    -- column sampling
    ----------------------------------------------------------------
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                o_key <= (others => '0');
            else
                for i in 0 to 3 loop
                    if s_sample = '1' and r_oe(i) = '1' then
                        o_key(3+(i*4) downto (i*4)) <= s_col;
                    end if;
                end loop;
            end if;
        end if;
    end process;

    -- column input synchronizers
    G1: for i in 0 to 3 generate
        U2: sync_sig generic map(I => '0')
        port map(i_clk, i_col(i), s_col(i));
    end generate;

end;
