--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     tb_mod_cnt6.vhd
-- Description:     testbench
-- Create date:     Tue Mar 12 2019
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_mod_cnt6 is
end tb_mod_cnt6;

architecture behavior of tb_mod_cnt6 is

    -- component declaration of Unit Under Test
    component mod_cnt6
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            i_dir : in std_logic;
            o_bcd : out std_logic_vector(2 downto 0);
            o_tc  : out std_logic;
            o_rc  : out std_logic
        );
    end component;

    -- inputs
    signal i_clk : std_logic;
    signal i_rst : std_logic;
    signal i_ce  : std_logic;
    signal i_dir : std_logic;

    -- outputs
    signal o_bcd : std_logic_vector(2 downto 0);
    signal o_tc  : std_logic;
    signal o_rc  : std_logic;

    -- clock period definitions
    constant CLK_PERIOD : time := 10 ns;

    -- simulation signal
    signal end_of_sim : boolean := false;

begin

    -- instantiate Unit Under Test (UUT)
    uut: mod_cnt6
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
            i_clk <= '0';
            wait for CLK_PERIOD / 2;
            i_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;

        report "simulation ended" severity note;
        wait;
    end process;

    -- stimulus process
    P_STIM: process
    begin

        -- reset counter
        i_rst <= '1';
        i_ce  <= '1';
        i_dir <= '1';
        wait for CLK_PERIOD * 5;

        -- up counting
        i_rst <= '0';
        wait for CLK_PERIOD * 15;

        -- down counting
        i_dir <= '0';
        wait for CLK_PERIOD * 15;

        -- end simulation
        end_of_sim <= true;

        wait;

    end process;
end;
