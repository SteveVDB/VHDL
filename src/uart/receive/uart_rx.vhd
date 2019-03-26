--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     uart_rx.vhd
-- Description:     UART receiver
-- Create date:     Thu Jan 17 2019
--------------------------------------------------------------------------------
--
-- parity and data select bits:
-- "00" : 8-bit data no parity
-- "01" : 8-bit data even parity
-- "10" : 8-bit data odd parity
-- "11" : 9-bit data no parity
--
-- number of stop bits:
-- '0' : 1 stop bit
-- '1' : 2 stop bits
--
-- baud_rate = F_CLK / (2 * (BRV+1)) [bps]
-- BRV = F_CLK / (2 * baud_rate) - 1
--
-- e.g. F_CLK: 40MHz, baud_rate: 250kbps => BRV = 79
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library SVDB;
use SVDB.utils.all;
use SVDB.cnt_gen.all;

entity uart_rx is
    port (
        i_clk : in std_logic;                       -- clock
        i_rst : in std_logic;                       -- reset
        i_enb : in std_logic;                       -- enable
        i_rx  : in std_logic;                       -- receive input
        i_nsb : in std_logic;                       -- number of stop bits
        i_pds : in std_logic_vector(1 downto 0);    -- parity/data select bits
        i_brv : in std_logic_vector(7 downto 0);    -- baud rate value
        o_rxd : out std_logic_vector(7 downto 0);   -- bits 7-0 of received data
        o_rx8 : out std_logic;                      -- bit 8 of received data
        o_frs : out std_logic;                      -- frame receive status
        o_fps : out std_logic;                      -- frame parity status
        o_fes : out std_logic                       -- frame error status
    );
end uart_rx;

architecture behavioral of uart_rx is

    type t_state is (SPACE, MARK, F_START, F_DATA, F_BIT8, F_STOP);

    signal s_rst, s_nine_bit : std_logic;
    signal s_stop_bits : unsigned(1 downto 0);

    signal r_mid, s_midbit : std_logic;
    signal s_tmr_rst, s_tmr_top : std_logic;
    signal s_tmr : std_logic_vector(7 downto 0);

    signal s_parity, s_fps : std_logic;

    signal r_sample, r_bitx, r_bit8, r_fes : std_logic;
    signal r_data : std_logic_vector(7 downto 0);
    signal r_scnt : unsigned(1 downto 0);
    signal r_dcnt : unsigned(3 downto 0);

    signal s_state, r_state : t_state;
    signal s_rx_syn, s_rx_rdy : std_logic;

begin

    -- reset condition
    s_rst <= i_rst or not i_enb;

    -- 8-bit data + parity, or 9-bit data
    s_nine_bit <= i_pds(0) or i_pds(1);

    -- number of stop bits
    s_stop_bits <= "10" when i_nsb = '1' else "01";

    ----------------------------------------------------------------
    -- parity check
    ----------------------------------------------------------------
    s_parity <= slv_xor(r_data) xor r_bit8;

    process(i_pds, s_parity)
    begin
        if i_pds = "01" then
            s_fps <= s_parity;              -- even parity
        elsif i_pds = "10" then
            s_fps <= not s_parity;          -- odd parity
        else
            s_fps <= '0';                   -- no parity
        end if;
    end process;

    ----------------------------------------------------------------
    -- baud rate timer
    ----------------------------------------------------------------
    U0: cnt_sr generic map(N => 8)
    port map(i_clk, s_tmr_rst, '1', s_tmr);

    s_tmr_top <= equ(s_tmr, i_brv);
    s_tmr_rst <= s_rx_syn or s_tmr_top;

    -- sample RX at half the bit period
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if s_rx_syn = '1' then
                r_mid <= '0';
            elsif s_tmr_top = '1' then
                r_mid <= not r_mid;
            end if;
        end if;
    end process;

    s_midbit <= not r_mid and s_tmr_top;

    ----------------------------------------------------------------
    -- receiver input sampling
    ----------------------------------------------------------------
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if s_midbit = '1' then
                r_bitx <= i_rx;
                if r_state = F_START then
                    r_fes  <= '0';
                    r_bit8 <= '0';
                    r_scnt <= "00";
                    r_dcnt <= "0000";
                elsif r_state = F_DATA then
                    r_dcnt <= r_dcnt + 1;
                    r_data <= i_rx & r_data(7 downto 1);
                elsif r_state = F_BIT8 then
                    r_bit8 <= i_rx;
                elsif r_state = F_STOP then
                    r_scnt <= r_scnt + 1;
                    r_fes  <= r_fes or not i_rx;
                end if;
            end if;
            r_sample <= s_midbit;
        end if;
    end process;

    ----------------------------------------------------------------
    -- UART receive state machine
    ----------------------------------------------------------------

    -- state synchronization
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if s_rst = '1' then
                o_frs <= '0';
                o_fps <= '0';
                o_fes <= '0';
                r_state <= SPACE;
            else
                o_frs <= s_rx_rdy;
                r_state <= s_state;
                if s_rx_rdy = '1' then
                    o_fps <= s_fps;
                    o_fes <= r_fes;
                    o_rxd <= r_data;
                    o_rx8 <= r_bit8;
                end if;
            end if;
        end if;
    end process;

    -- next state decode
    process(r_state, i_rx, r_sample, r_bitx,
            r_dcnt, s_nine_bit, r_scnt, s_stop_bits)
    begin

        -- default values
        s_rx_syn <= '0';                    -- in synchronize state
        s_rx_rdy <= '0';                    -- new frame received

        case r_state is
            when SPACE   =>                 -- wait until RX is high
                s_rx_syn <= '1';
                if i_rx = '1' then
                    s_state <= MARK;
                else
                    s_state <= SPACE;
                end if;

            when MARK    =>                 -- wait until RX is low
                if i_rx = '0' then
                    s_state <= F_START;
                else
                    s_rx_syn <= '1';
                    s_state <= MARK;
                end if;

            when F_START =>                 -- frame start bit
                if r_sample = '1' then
                    if r_bitx = '0' then
                        s_state <= F_DATA;
                    else
                        s_rx_syn <= '1';
                        s_state <= MARK;
                    end if;
                end if;

            when F_DATA  =>                 -- frame eight data bits
                if r_dcnt = "1000" then
                    if s_nine_bit = '1' then
                        s_state <= F_BIT8;
                    else
                        s_state <= F_STOP;
                    end if;
                else
                    s_state <= F_DATA;
                end if;

            when F_BIT8  =>                 -- frame parity, or ninth data bit
                if r_sample = '1' then
                    s_state <= F_STOP;
                else
                    s_state <= F_BIT8;
                end if;

            when F_STOP  =>                 -- frame stop bit(s)
                if r_scnt = s_stop_bits then
                    s_rx_rdy <= '1';
                    s_rx_syn <= '1';
                    if r_bitx = '1' then
                        s_state <= MARK;
                    else
                        s_state <= SPACE;
                    end if;
                else
                    s_state <= F_STOP;
                end if;

            when others  =>                 -- illegal state
                s_rx_syn <= '1';
                if i_rx = '1' then
                    s_state <= MARK;
                else
                    s_state <= SPACE;
                end if;
        end case;
    end process;

end;
