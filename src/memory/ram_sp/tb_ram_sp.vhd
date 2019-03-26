--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     tb_ram_sp.vhd
-- Description:     testbench
-- Create date:     Mon Jan 14 2019
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.utils.all;
use SVDB.vectors.all;
use SVDB.strings.all;
use SVDB.mem_utils.all;

entity tb_ram_sp is
end tb_ram_sp;

architecture behavior of tb_ram_sp is

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
    component ram_sp
        generic (
            A_BITS      : positive := A_BITS;
            D_BITS      : positive := D_BITS;
            INIT_FILE   : string   := INIT_FILE;
            INIT_VALUE  : bit      := INIT_VALUE;
            FILE_FORMAT : string   := FILE_FORMAT
        );
        port (
            i_clk  : in std_logic;
            i_ce   : in std_logic;
            i_we   : in std_logic;
            i_addr : in std_logic_vector(A_BITS-1 downto 0);
            i_data : in std_logic_vector(D_BITS-1 downto 0);
            o_data : out std_logic_vector(D_BITS-1 downto 0)
        );
    end component;

    -- inputs
    signal i_clk  : std_logic;
    signal i_ce   : std_logic;
    signal i_we   : std_logic;
    signal i_addr : std_logic_vector(A_BITS-1 downto 0);
    signal i_data : std_logic_vector(D_BITS-1 downto 0);

    -- outputs
    signal o_data : std_logic_vector(D_BITS-1 downto 0);

    -- clock period definitions (25MHz)
    constant CLK_PERIOD : time := 40 ns;

    -- simulation signal
    signal end_of_sim : boolean := false;

begin

    -- instantiate Unit Under Test (UUT)
    uut: ram_sp
    port map (
        i_clk       => i_clk,
        i_ce        => i_ce,
        i_we        => i_we,
        i_addr      => i_addr,
        i_data      => i_data,
        o_data      => o_data
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
        variable f_data : t_slm(0 to DEPTH-1, D_BITS-1 downto 0);
        variable m_word : std_logic_vector(D_BITS-1 downto 0);
    begin

        i_ce <= '0';
        i_we <= '0';
        i_addr <= (others => '0');
        i_data <= (others => '0');

        wait for CLK_PERIOD;
        i_ce <= '1';

        -- read-verify initial RAM data
        f_data := read_mem_file(INIT_FILE, FILE_FORMAT, DEPTH, D_BITS);
        for i in 0 to DEPTH-1 loop
            m_word := get_row(f_data, i);

            -- read
            i_addr <= to_slv(i, A_BITS);
            wait for CLK_PERIOD;

            -- verify
            assert o_data = m_word
            report "read-verify error at line: " & integer'image(i) &
                   ", data read is: " & to_string(o_data) severity failure;
        end loop;

        -- write-verify new RAM DATA
        f_data := read_mem_file(TEST_FILE, FILE_FORMAT, DEPTH, D_BITS);
        for i in 0 to DEPTH-1 loop
            m_word := get_row(f_data, i);

            -- write
            i_we <= '1';
            i_data <= m_word;
            i_addr <= to_slv(i, A_BITS);
            wait for CLK_PERIOD;

            -- read
            i_we <= '0';
            wait for CLK_PERIOD;

            -- verify
            assert o_data = m_word
            report "write-verify error at line: " & integer'image(i) &
                   ", data read is: " & to_string(o_data) severity failure;
        end loop;

        i_ce <= '0';

        -- end simulation
        end_of_sim <= true;

        wait;

    end process;
end;
