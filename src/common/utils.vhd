--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     utils.vhd
-- Create date:     Wed Oct 24 2018
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package utils is

    -- short for: to_integer(unsigned(slv))
    function to_int(slv : std_logic_vector) return natural;

    -- short for: std_logic_vector(to_unsigned(int, size))
    function to_slv(int : natural; size : positive) return std_logic_vector;

    ----------------------------------------------------------------
    -- Min/Max functions
    ----------------------------------------------------------------

    -- return min(a, b) for integers
    function min(a: integer; b: integer) return integer;

    -- return max(a, b) for integers
    function max(a: integer; b: integer) return integer;

    ----------------------------------------------------------------
    -- Math functions
    ----------------------------------------------------------------

    -- calculate ceil(a / b)
    function ceil_div(a : natural; b: positive) return natural;

    -- return TRUE, if 'a' is power of 2
    function is_pow2(a : natural) return boolean;

    -- round 'a' to next power of 2
    function next_pow2(a : natural) return positive;

    -- round 'a' to previous power of 2
    function prev_pow2(a : natural) return natural;

    -- calculate ceil(log2(a))
    function ceil_log2(a : positive) return natural;

    -- calculate ceil(log10(a))
    function ceil_log10(a : positive) return natural;

    ----------------------------------------------------------------
    -- Vector compare functions
    ----------------------------------------------------------------

    -- return '1' when a = b else '0'
    function equ(a : std_logic_vector; b : std_logic_vector) return std_logic;

    -- return '1' when a < b else '0'
    function lte(a : std_logic_vector; b : std_logic_vector) return std_logic;

    -- return '1' when a > b else '0'
    function gte(a : std_logic_vector; b : std_logic_vector) return std_logic;

    ----------------------------------------------------------------
    -- Vector aggregate functions
    ----------------------------------------------------------------

    -- short for: slv(n-1) or ... or slv(1) or slv(0)
    function slv_or(slv : std_logic_vector) return std_logic;

    -- short for: slv(n-1) and ... and slv(1) and slv(0)
    function slv_and(slv : std_logic_vector) return std_logic;

    -- short for: slv(n-1) xor ... xor slv(1) xor slv(0)
    function slv_xor(slv : std_logic_vector) return std_logic;

end package;

package body utils is

    function to_int(slv : std_logic_vector) return natural is
    begin
        return to_integer(unsigned(slv));
    end function;

    function to_slv(int : natural; size : positive) return std_logic_vector is
    begin
        return std_logic_vector(to_unsigned(int, size));
    end function;

    ----------------------------------------------------------------
    -- Min/Max functions
    ----------------------------------------------------------------

    function min(a: integer; b: integer) return integer is
    begin
        if a < b then
            return a;
        else
            return b;
        end if;
    end function;

    function max(a: integer; b: integer) return integer is
    begin
        if a > b then
            return a;
        else
            return b;
        end if;
    end function;

    ----------------------------------------------------------------
    -- Math functions
    ----------------------------------------------------------------

    function ceil_div(a : natural; b : positive) return natural is
    begin
        return (a + (b - 1)) / b;
    end function;

    function is_pow2(a : natural) return boolean is
    begin
        return next_pow2(a) = a;
    end function;

    function next_pow2(a : natural) return positive is
    begin
        return 2**ceil_log2(a);
    end function;

    function prev_pow2(a : natural) return natural is
        variable tmp : unsigned(30 downto 0);
    begin
        tmp := to_unsigned(a, 31);
        for i in tmp'range loop
            if tmp(i) = '1' then
                return 2**i;
            end if;
        end loop;
        return 0;
    end function;

    function ceil_log2(a : positive) return natural is
        variable tmp : positive := 1;
        variable res : natural := 0;
    begin
        while a > tmp loop
            tmp := tmp * 2;
            res := res + 1;
        end loop;
        return res;
    end function;

    function ceil_log10(a : positive) return natural is
        variable tmp : positive := 1;
        variable res : natural := 0;
    begin
        while a > tmp loop
            tmp := tmp * 10;
            res := res + 1;
        end loop;
        return res;
    end function;

    ----------------------------------------------------------------
    -- Vector compare functions
    ----------------------------------------------------------------

    function equ(a : std_logic_vector; b : std_logic_vector) return std_logic is
        constant L : integer := max(a'length, b'length);
        variable x, y : std_logic_vector(L-1 downto 0) := (others => '0');
    begin
        x(a'high downto a'low) := a;
        y(b'high downto b'low) := b;

        if x = y then
            return '1';
        else
            return '0';
        end if;
    end function;

    function lte(a : std_logic_vector; b : std_logic_vector) return std_logic is
        constant L : integer := max(a'length, b'length);
        variable x, y : std_logic_vector(L-1 downto 0) := (others => '0');
    begin
        x(a'high downto a'low) := a;
        y(b'high downto b'low) := b;

        if x < y then
            return '1';
        else
            return '0';
        end if;
    end function;

    function gte(a : std_logic_vector; b : std_logic_vector) return std_logic is
        constant L : integer := max(a'length, b'length);
        variable x, y : std_logic_vector(L-1 downto 0) := (others => '0');
    begin
        x(a'high downto a'low) := a;
        y(b'high downto b'low) := b;

        if x > y then
            return '1';
        else
            return '0';
        end if;
    end function;

    ----------------------------------------------------------------
    -- Vector aggregate functions
    ----------------------------------------------------------------

    function slv_or(slv : std_logic_vector) return std_logic is
        variable res : std_logic := '0';
    begin
        for i in slv'range loop
            res := res or slv(i);
        end loop;
        return res;
    end function;

    function slv_and(slv : std_logic_vector) return std_logic is
        variable res : std_logic := '1';
    begin
        for i in slv'range loop
            res := res and slv(i);
        end loop;
        return res;
    end function;

    function slv_xor(slv : std_logic_vector) return std_logic is
        variable res : std_logic := '0';
    begin
        for i in slv'range loop
            res := res xor slv(i);
        end loop;
        return res;
    end function;

end package body;
