--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     vectors.vhd
-- Create date:     Tue Oct 23 2018
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package vectors is

    ----------------------------------------------------------------
    -- type STD_LOGIC_VECTOR_VECTOR
    ----------------------------------------------------------------

    type t_slvv_8  is array(natural range <>) of std_logic_vector(7  downto 0);
    type t_slvv_16 is array(natural range <>) of std_logic_vector(15 downto 0);
    type t_slvv_32 is array(natural range <>) of std_logic_vector(31 downto 0);

    -- convert t_slvv_8 to std_logic_vector
    function to_slv(slvv : t_slvv_8) return std_logic_vector;

    -- convert t_slvv_16 to std_logic_vector
    function to_slv(slvv : t_slvv_16) return std_logic_vector;

    -- convert t_slvv_32 to std_logic_vector
    function to_slv(slvv : t_slvv_32) return std_logic_vector;

    -- convert std_logic_vector to t_slvv_8
    function to_slvv_8(slv : std_logic_vector) return t_slvv_8;

    -- convert std_logic_vector to t_slvv_16
    function to_slvv_16(slv : std_logic_vector) return t_slvv_16;

    -- convert std_logic_vector to t_slvv_32
    function to_slvv_32(slv : std_logic_vector) return t_slvv_32;

    ----------------------------------------------------------------
    -- type STD_LOGIC_MATRIX
    ----------------------------------------------------------------

    type t_slm is array(natural range <>, natural range <>) of std_logic;

    -- short for: slm'length(1) * slm'length(2)
    function size(slm : t_slm) return natural;

    -- assign std_logic_vector to matrix row
    procedure set_row(variable slm : inout t_slm; slv : in std_logic_vector;
        row : in natural);

    -- assign std_logic_vector to matrix column
    procedure set_col(variable slm : inout t_slm; slv : in std_logic_vector;
        col : in natural);

    -- return matrix row as std_logic_vector
    function get_row(slm : t_slm; row : natural) return std_logic_vector;

    -- return matrix column as std_logic_vector
    function get_col(slm : t_slm; col : natural) return std_logic_vector;

end package;

package body vectors is

    ----------------------------------------------------------------
    -- type STD_LOGIC_VECTOR_VECTOR
    ----------------------------------------------------------------

    function to_slv(slvv : t_slvv_8) return std_logic_vector is
        variable slv : std_logic_vector((slvv'length*8)-1 downto 0);
    begin
        for i in slvv'range loop
            slv((i*8)+7 downto (i*8)) := slvv(i);
        end loop;
        return slv;
    end function;

    function to_slv(slvv : t_slvv_16) return std_logic_vector is
        variable slv : std_logic_vector((slvv'length*16)-1 downto 0);
    begin
        for i in slvv'range loop
            slv((i*16)+15 downto (i*16)) := slvv(i);
        end loop;
        return slv;
    end function;

    function to_slv(slvv : t_slvv_32) return std_logic_vector is
        variable slv : std_logic_vector((slvv'length*32)-1 downto 0);
    begin
        for i in slvv'range loop
            slv((i*32)+31 downto (i*32)) := slvv(i);
        end loop;
        return slv;
    end function;

    function to_slvv_8(slv : std_logic_vector) return t_slvv_8 is
        variable slvv : t_slvv_8((slv'length/8)-1 downto 0);
    begin
        if((slv'length mod 8) /= 0) then
            report "to_slvv_8: slv'length is no multiple of 8"
            severity failure;
        end if;

        for i in slvv'range loop
            slvv(i) := slv((i*8)+7 downto (i*8));
        end loop;
        return slvv;
    end function;

    function to_slvv_16(slv : std_logic_vector) return t_slvv_16 is
        variable slvv : t_slvv_16((slv'length/16)-1 downto 0);
    begin
        if((slv'length mod 16) /= 0) then
            report "to_slvv_16: slv'length is no multiple of 16"
            severity failure;
        end if;

        for i in slvv'range loop
            slvv(i) := slv((i*16)+15 downto (i*16));
        end loop;
        return slvv;
    end function;

    function to_slvv_32(slv : std_logic_vector) return t_slvv_32 is
        variable slvv : t_slvv_32((slv'length/32)-1 downto 0);
    begin
        if((slv'length mod 32) /= 0) then
            report "to_slvv_32: slv'length is no multiple of 32"
            severity failure;
        end if;

        for i in slvv'range loop
            slvv(i) := slv((i*32)+31 downto (i*32));
        end loop;
        return slvv;
    end function;

    ----------------------------------------------------------------
    -- type STD_LOGIC_MATRIX
    ----------------------------------------------------------------

    function size(slm : t_slm) return natural is
    begin
        return slm'length(1) * slm'length(2);
    end function;

    procedure set_row(variable slm : inout t_slm; slv : in std_logic_vector;
        row : in natural) is
    begin
        for i in slv'range loop
            slm(row, i) := slv(i);
        end loop;
    end procedure;

    procedure set_col(variable slm : inout t_slm; slv : in std_logic_vector;
        col : in natural) is
    begin
        for i in slv'range loop
            slm(i, col) := slv(i);
        end loop;
    end procedure;

    function get_row(slm : t_slm; row : natural) return std_logic_vector is
        variable slv : std_logic_vector(slm'high(2) downto slm'low(2));
    begin
        for i in slv'range loop
            slv(i) := slm(row, i);
        end loop;
        return slv;
    end function;

    function get_col(slm : t_slm; col : natural) return std_logic_vector is
        variable slv : std_logic_vector(slm'high(1) downto slm'low(1));
    begin
        for i in slv'reverse_range loop
            slv(i) := slm(i, col);
        end loop;
        return slv;
    end function;

end package body;
