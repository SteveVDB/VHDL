--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     tb_ram_dp.vhd
-- Description:     testbench
-- Create date:     Tue Jan 15 2019
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.utils.all;
use SVDB.vectors.all;
use SVDB.strings.all;
use SVDB.mem_utils.all;

entity tb_ram_dp is
end tb_ram_dp;

architecture behavior of tb_ram_dp is

    constant A_BITS      : positive := 8;
    constant D_BITS      : positive := 16;
    constant DEPTH       : positive := 2**A_BITS;
    constant INIT_VALUE  : bit      := '0';
    constant INIT_FILE   : string   := "init_hex.mem";
    constant TEST_FILE   : string   := "test_hex.mem";
    constant FILE_FORMAT : string   := "hex";
    --constant INIT_FILE   : string   := "init_bin.mem";
    --constant TEST_FILE   : string   := "test_bin.mem";
    --constant FILE_FORMAT : string   := "bin";

    -- component declaration of Unit Under Test
    component ram_dp
        generic (
            A_BITS      : positive := A_BITS;
            D_BITS      : positive := D_BITS;
            INIT_FILE   : string   := INIT_FILE;
            INIT_VALUE  : bit      := INIT_VALUE;
            FILE_FORMAT : string   := FILE_FORMAT
        );
        port (
            i_wr_clk  : in std_logic;
            i_wr_ce   : in std_logic;
            i_wr_en   : in std_logic;
            i_wr_addr : in std_logic_vector(A_BITS-1 downto 0);
            i_wr_data : in std_logic_vector(D_BITS-1 downto 0);
            i_rd_clk  : in std_logic;
            i_rd_ce   : in std_logic;
            i_rd_en   : in std_logic;
            i_rd_addr : in std_logic_vector(A_BITS-1 downto 0);
            o_rd_data : out std_logic_vector(D_BITS-1 downto 0)
        );
    end component;

    -- inputs
    signal i_wr_clk  : std_logic;
    signal i_wr_ce   : std_logic;
    signal i_wr_en   : std_logic;
    signal i_wr_addr : std_logic_vector(A_BITS-1 downto 0);
    signal i_wr_data : std_logic_vector(D_BITS-1 downto 0);
    signal i_rd_clk  : std_logic;
    signal i_rd_ce   : std_logic;
    signal i_rd_en   : std_logic;
    signal i_rd_addr : std_logic_vector(A_BITS-1 downto 0);

    -- outputs
    signal o_rd_data : std_logic_vector(D_BITS-1 downto 0);

    -- clock period definitions (25MHz)
    constant CLK_PERIOD : time := 40 ns;

    -- simulation signal
    signal end_of_sim : boolean := false;

begin

    -- instantiate Unit Under Test (UUT)
    uut: ram_dp
    port map (
        i_wr_clk    => i_wr_clk,
        i_wr_ce     => i_wr_ce,
        i_wr_en     => i_wr_en,
        i_wr_addr   => i_wr_addr,
        i_wr_data   => i_wr_data,
        i_rd_clk    => i_rd_clk,
        i_rd_ce     => i_rd_ce,
        i_rd_en     => i_rd_en,
        i_rd_addr   => i_rd_addr,
        o_rd_data   => o_rd_data
    );

    -- clock process
    P_CLK: process
    begin
        while not end_of_sim loop
            i_wr_clk <= '0';
            i_rd_clk <= '0';
            wait for CLK_PERIOD / 2;
            i_wr_clk <= '1';
            i_rd_clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;

        report "simulation ended" severity note;
        wait;
    end process;

    -- stimulus process
    P_STIM: process
        variable f_init : t_slm(0 to DEPTH-1, D_BITS-1 downto 0);
        variable f_test : t_slm(0 to DEPTH-1, D_BITS-1 downto 0);
        variable m_init : std_logic_vector(D_BITS-1 downto 0);
        variable m_test : std_logic_vector(D_BITS-1 downto 0);
    begin

        i_wr_ce <= '0';
        i_wr_en <= '0';
        i_wr_addr <= (others => '0');
        i_wr_data <= (others => '0');
        i_rd_ce <= '0';
        i_rd_en <= '0';
        i_rd_addr <= (others => '0');

        wait for CLK_PERIOD;
        i_rd_ce <= '1';
        i_wr_ce <= '1';
        i_rd_en <= '1';

        -- read-verify + write-verify
        f_init := read_mem_file(INIT_FILE, FILE_FORMAT, DEPTH, D_BITS);
        f_test := read_mem_file(TEST_FILE, FILE_FORMAT, DEPTH, D_BITS);
        for i in 0 to DEPTH-1 loop
            m_init := get_row(f_init, i);
            m_test := get_row(f_test, i);

            -- read before write
            i_wr_en <= '1';
            i_wr_addr <= to_slv(i, A_BITS);
            i_rd_addr <= to_slv(i, A_BITS);
            i_wr_data <= m_test;
            wait for CLK_PERIOD;

            -- verify initial data
            assert o_rd_data = m_init
            report "error read-verify at line: " & integer'image(i) &
                   ", data read is: " & to_string(o_rd_data) severity failure;

            -- read
            i_wr_en <= '0';
            wait for CLK_PERIOD;

            -- verify new data
            assert o_rd_data = m_test
            report "error write-verify at line: " & integer'image(i) &
                   ", data read is: " & to_string(o_rd_data) severity failure;
        end loop;

        i_rd_ce <= '0';
        i_wr_ce <= '0';
        i_rd_en <= '0';

        -- end simulation
        end_of_sim <= true;

        wait;

    end process;
end;
