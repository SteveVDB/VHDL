--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     tb_utils.vhd
-- Create date:     Tue Oct 30 2018
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.utils.all;
use SVDB.strings.all;

entity tb_utils is
end tb_utils;

architecture behavior of tb_utils is

begin
    -- stimulus process
    P_STIM: process
        variable sl    : std_logic;
        variable int   : integer;
        variable bool  : boolean;
        variable slv_4 : std_logic_vector(3 downto 0);
        variable slv_5 : std_logic_vector(4 downto 0);
    begin

        -- ceil_div
        int := ceil_div(123, 45);
        assert int = 3
        report "ceil_div() error: " & integer'image(int) severity failure;

        -- is_pow2
        bool := is_pow2(128);
        assert bool = true report "is_pow2() error: false" severity failure;

        bool := is_pow2(2345);
        assert bool = false report "is_pow2() error: true" severity failure;

        -- next_pow2
        int := next_pow2(10245);
        assert int = 16384
        report "next_pow2() error: " & integer'image(int) severity failure;

        -- prev_pow2
        int := prev_pow2(10245);
        assert int = 8192
        report "prev_pow2() error: " & integer'image(int) severity failure;

        -- ceil_log2
        int := ceil_log2(457);
        assert int = 9
        report "ceil_log2() error: " & integer'image(int) severity failure;

        -- ceil_log10
        int := ceil_log10(13943);
        assert int = 5
        report "ceil_log10() error: " & integer'image(int) severity failure;

        -- slv_or
        sl := slv_or("10101010");
        assert sl = '1'
        --sl := slv_or("00000000");
        --assert sl = '0'
        report "slv_or() error: " & to_char(sl) severity failure;

        -- slv_and
        sl := slv_and("1101101");
        assert sl = '0'
        --sl := slv_and("1111111");
        --assert sl = '1'
        report "slv_and() error: " & to_char(sl) severity failure;

        -- slv_xor
        sl := slv_xor("10101011");
        assert sl = '1'
        --sl := slv_xor("10001011");
        --assert sl = '0'
        report "slv_xor() error: " & to_char(sl) severity failure;

        -- equ
        slv_4 := "1000";
        slv_5 := "01000";
        sl := equ(slv_4, slv_5);
        assert sl = '1'
        report "equ() error: " & to_char(sl) severity failure;

        -- lte
        slv_4 := "0011";
        slv_5 := "10001";
        sl := lte(slv_4, slv_5);
        assert sl = '1'
        report "lte() error: " & to_char(sl) severity failure;

        -- gte
        slv_4 := "0111";
        slv_5 := "00011";
        sl := gte(slv_4, slv_5);
        assert sl = '1'
        report "gte() error: " & to_char(sl) severity failure;

        report "testing package: utils DONE !" severity note;
        wait;

    end process;
end;
