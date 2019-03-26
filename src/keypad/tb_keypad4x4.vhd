--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     tb_keypad4x4.vhd
-- Description:     testbench
-- Create date:     Thu Mar 21 2019
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_keypad4x4 is
end tb_keypad4x4;

architecture behavior of tb_keypad4x4 is

    constant DEBOUNCE_TIME : time := 20 ms;

    -- component declaration of Unit Under Test
    component keypad4x4
        generic (
            KEY_SCAN_TICKS : positive := 10
        );
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_ce  : in std_logic;
            i_col : in std_logic_vector(3 downto 0);
            o_row : out std_logic_vector(3 downto 0);
            o_key : out std_logic_vector(15 downto 0)
        );
    end component;

    -- inputs
    signal i_clk : std_logic;
    signal i_rst : std_logic;
    signal i_ce  : std_logic;
    signal i_col : std_logic_vector(3 downto 0);

    -- outputs
    signal o_row : std_logic_vector(3 downto 0);
    signal o_key : std_logic_vector(15 downto 0);

    -- clock period definitions (1MHz)
    constant CLK_PERIOD : time := 1 us;

    constant KEY_SCAN_TICKS : integer:= DEBOUNCE_TIME / (8*CLK_PERIOD);

    -- simulation signal
    signal end_of_sim : boolean := false;

begin

    -- instantiate Unit Under Test (UUT)
    uut: keypad4x4
    generic map (
        KEY_SCAN_TICKS => KEY_SCAN_TICKS
    )
    port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_ce  => i_ce,
        i_col => i_col,
        o_row => o_row,
        o_key => o_key
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
        i_col <= "1001";

        i_rst <= '1';
        wait for DEBOUNCE_TIME;
        i_rst <= '0';
        wait for DEBOUNCE_TIME * 2;

        -- end simulation
        end_of_sim <= true;

        wait;

    end process;
end;
