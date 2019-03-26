--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     tb_timer_4d.vhd
-- Description:     testbench
-- Create date:     Thu Mar 14 2019
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;

entity tb_timer_4d is
end tb_timer_4d;

architecture behavior of tb_timer_4d is

    -- component declaration of Unit Under Test
    component timer_4d
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            i_dir : in std_logic;
            o_bcd : out std_logic_vector(15 downto 0);
            o_tc  : out std_logic;
            o_rc  : out std_logic
        );
    end component;

    -- inputs
    signal i_clk : std_logic;
    signal i_rst : std_logic;
    signal i_ce  : std_logic := '0';
    signal i_dir : std_logic;

    -- outputs
    signal o_bcd : std_logic_vector(15 downto 0);
    signal o_tc  : std_logic;
    signal o_rc  : std_logic;

    -- clock period definitions
    constant CLK_PERIOD : time := 10 ns;

    -- simulation signal
    signal end_of_sim : boolean := false;

begin

    -- instantiate Unit Under Test (UUT)
    uut: timer_4d
    port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_ce  => i_ce,
        i_dir => i_dir,
        o_bcd => o_bcd,
        o_tc  => o_tc,
        o_rc  => o_rc
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

    -- clock enable process
    P_CE: process
        variable cnt : integer := 0;
    begin
        while not end_of_sim loop
            wait until rising_edge(i_clk);
            if cnt = 9 then
                cnt := 0;
                i_ce <= '1';
            else
                cnt := cnt + 1;
                i_ce <= '0';
            end if;
        end loop;

        wait;
    end process;

    -- stimulus process
    P_STIM: process
    begin

        -- reset timer
        i_rst <= '1';
        i_dir <= '1';
        wait for CLK_PERIOD * 10;

        -- count up for "1h30m"
        i_rst <= '0';
        wait until o_bcd = X"5959";
        wait until o_bcd = X"3000";

        -- count down for "1h30m"
        i_dir <= '0';
        wait until o_bcd = X"5959";
        wait until o_bcd = X"0000";

        -- end simulation
        end_of_sim <= true;

        wait;

    end process;
end;
