--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     tb_disp4x7.vhd
-- Description:     testbench
-- Create date:     Thu Jan 24 2019
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_seg4x7 is
end tb_seg4x7;

architecture behavior of tb_seg4x7 is

    constant REFRESH_RATE   : time := 20 ms;
    constant DEAD_TIME      : time := 50 us;

    -- component declaration of Unit Under Test
    component seg4x7
        generic (
            LOW_SIDE_LEVEL  : bit := '0';
            HIGH_SIDE_LEVEL : bit := '1';
            MULTIPLEX_TICKS : positive;
            GHOSTING_TICKS  : positive
        );
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            i_blk : in std_logic;
            i_bcd : in std_logic_vector(15 downto 0);
            o_lsd : out std_logic_vector(6 downto 0);
            o_hsd : out std_logic_vector(3 downto 0)
        );
    end component;

    -- inputs
    signal i_clk : std_logic;
    signal i_rst : std_logic;
    signal i_ce  : std_logic;
    signal i_blk : std_logic;
    signal i_bcd : std_logic_vector(15 downto 0);

    -- outputs
    signal o_lsd : std_logic_vector(6 downto 0);
    signal o_hsd : std_logic_vector(3 downto 0);

    -- clock period definitions (1MHz)
    constant CLK_PERIOD : time :=  1 us;

    constant MULTIPLEX_TICKS : integer := REFRESH_RATE / (4*CLK_PERIOD);
    constant GHOSTING_TICKS  : integer := DEAD_TIME / CLK_PERIOD;

    -- simulation signal
    signal end_of_sim : boolean := false;

begin

    -- instantiate Unit Under Test (UUT)
    uut: seg4x7
    generic map (
        MULTIPLEX_TICKS => MULTIPLEX_TICKS,
        GHOSTING_TICKS  => GHOSTING_TICKS
    )
    port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_ce  => i_ce,
        i_blk => i_blk,
        i_bcd => i_bcd,
        o_lsd => o_lsd,
        o_hsd => o_hsd
    );

    -- clock process
    P_CLK: process
    begin
        while not end_of_sim loop
            i_clk <= '1';
            wait for CLK_PERIOD / 2;
            i_clk <= '0';
            wait for CLK_PERIOD / 2;
        end loop;

        report "simulation ended" severity note;
        wait;
    end process;

    -- stimulus process
    P_STIM: process
    begin

        i_ce  <= '1';
        i_blk <= '0';
        i_bcd <= X"2019";

        i_rst <= '1';
        wait for REFRESH_RATE * 1;
        i_rst <= '0';
        wait for REFRESH_RATE * 2;

        -- end simulation
        end_of_sim <= true;

        wait;

    end process;
end;
