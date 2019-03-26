--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     mem_utils.vhd
-- Create date:     Tue Jan 08 2019
--------------------------------------------------------------------------------
library STD;
use STD.textio.all;

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.utils.all;
use SVDB.vectors.all;
use SVDB.strings.all;

package mem_utils is

    ----------------------------------------------------------------
    -- Read ASCII-coded hexadecimal, or binary data from a file,
    -- and return a 2D std_logic_matrix.
    ----------------------------------------------------------------
    -- e.g.: read_mem_file(init.mem, "hex", 2, 9)
    -- 049
    -- 19E
    ----------------------------------------------------------------
    -- e.g.: read_mem_file(init.mem, "bin", 2, 9)
    -- 011001001
    -- 100110011
    ----------------------------------------------------------------
    impure function read_mem_file(f_name : string; f_format : string;
            mem_depth : positive; mem_width : positive) return t_slm;

end package;

package body mem_utils is

    procedure read_bin(pstr : inout line; res : out std_logic_vector;
            good : out boolean) is
        constant DIGITS : positive := res'length;
        variable slv    : std_logic_vector(DIGITS-1 downto 0);
        variable char   : character;
        variable ok     : boolean;
        variable bin    : t_bin;
    begin
        good := true;
        slv := (others => '0');

        for i in DIGITS-1 downto 0 loop
            read(pstr, char, ok);
            exit when not ok;

            bin := to_bin(char);
            if bin < 0 then
                good := false;
                return;
            end if;
            slv(i downto i) := to_slv(bin, 1);
        end loop;

        res := slv;
    end procedure;

    procedure read_hex(pstr : inout line; res : out std_logic_vector;
            good : out boolean) is
        constant DIGITS : positive := ceil_div(res'length,4);
        variable slv    : std_logic_vector((DIGITS*4)-1 downto 0);
        variable char   : character;
        variable ok     : boolean;
        variable hex    : t_hex;
    begin
        good := true;
        slv := (others => '0');

        for i in DIGITS-1 downto 0 loop
            read(pstr, char, ok);
            exit when not ok;

            hex := to_hex(char);
            if hex < 0 then
                good := false;
                return;
            end if;
            slv((i*4)+3 downto (i*4)) := to_slv(hex, 4);
        end loop;

        res := slv(res'range);
    end procedure;

    impure function read_mem_file(f_name : string; f_format : string;
            mem_depth : positive; mem_width : positive) return t_slm is
        file f_handle           : text open read_mode is f_name;
        variable good           : boolean;
        variable f_line         : line;
        variable mem_word       : std_logic_vector(mem_width-1 downto 0);
        variable mem_content    : t_slm(0 to mem_depth-1,mem_width-1 downto 0);
    begin
        mem_content := (others => (others => '0'));

        for i in 0 to mem_depth-1 loop
            exit when endfile(f_handle);

            readline(f_handle, f_line);

            if f_format = "hex" then
                read_hex(f_line, mem_word, good);
            elsif f_format = "bin" then
                read_bin(f_line, mem_word, good);
            else
                report "unknown file format: " & f_format severity failure;
            end if;

            if not good then
                report "error reading file: " & f_name severity failure;
            end if;

            set_row(mem_content, mem_word, i);
        end loop;
        return mem_content;
    end function;

end package body;
