--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     string.vhd
-- Create date:     Tue Oct 30 2018
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.vectors.all;

package strings is

    -- convert std_logic to character
    function to_char(sl : std_logic) return character;

    -- convert std_logic_vector to string
    function to_string(slv : std_logic_vector) return string;

    -- convert std_logic_matrix to string
    function to_string(slm : t_slm) return string;

    ----------------------------------------------------------------
    -- Character classification functions
    ----------------------------------------------------------------

    -- checks if 'c' is a lowercase letter (abcdefghijklmnopqrstuvwxyz)
    function is_lower(c : character) return boolean;

    -- checks if 'c' is a uppercase letter (ABCDEFGHIJKLMNOPQRSTUVWXYZ)
    function is_upper(c : character) return boolean;

    -- checks if 'c' is a numeric character (0123456789)
    function is_digit(c : character) return boolean;

    -- checks if 'c' is an alphabetic character
    function is_alpha(c : character) return boolean;

    -- checks if 'c' is an alphanumeric character
    function is_alnum(c : character) return boolean;

    -- checks if 'c' is a lowercase hexadecimal character (abcdef)
    function is_xlower(c : character) return boolean;

    -- chechs if 'c' is a uppercase hexadecimal character (ABCDEF)
    function is_xupper(c : character) return boolean;

    -- checks if 'c' is a hexadecimal character (012345678abcdefABCDEF)
    function is_xdigit(c : character) return boolean;

    -- convert character to lowercase
    function to_lower(c : character) return character;

    -- convert character to uppercase
    function to_upper(c : character) return character;

    ----------------------------------------------------------------
    -- BIN, OCT, DEC, and HEX subtypes incl. error value (-1)
    ----------------------------------------------------------------
    subtype t_bin is integer range -1 to 1;
    subtype t_oct is integer range -1 to 7;
    subtype t_dec is integer range -1 to 9;
    subtype t_hex is integer range -1 to 15;

    -- convert character to binary digit
    function to_bin(c : character) return integer;

    -- convert character to octal digit
    function to_oct(c : character) return integer;

    -- convert character to decimal digit
    function to_dec(c : character) return integer;

    -- convert character to hexadecimal digit
    function to_hex(c : character) return integer;

end package;

package body strings is

    function to_char(sl : std_logic) return character is
    begin
        case sl is
            when 'U'    => return 'U';
            when '0'    => return '0';
            when '1'    => return '1';
            when 'Z'    => return 'Z';
            when 'W'    => return 'W';
            when 'L'    => return 'L';
            when 'H'    => return 'H';
            when '-'    => return '-';
            when others => return 'X';
        end case;
    end function;

    function to_string(slv : std_logic_vector) return string is
        variable str : string(1 to slv'length);
        variable j : positive := 1;
    begin
        for i in slv'range loop
            str(j) := to_char(slv(i));
            j := j + 1;
        end loop;
        return str;
    end function;

    function to_string(slm : t_slm) return string is
        variable str : string(1 to 2*size(slm));
        variable k : integer := 1;
    begin
        str(k) := LF;
        k := k + 1;
        for i in slm'low(1) to slm'high(1) loop
            for j in slm'high(2) downto slm'low(2) loop
                str(k) := to_char(slm(i,j));
                if j > slm'low(2) then
                    str(k+1) := ',';
                    k := k + 2;
                else
                    k := k + 1;
                end if;
            end loop;
            if i < slm'high(1) then
                str(k) := LF;
                k := k + 1;
            end if;
        end loop;
        return str;
    end function;

    ----------------------------------------------------------------
    -- Character classification functions
    ----------------------------------------------------------------

    function is_lower(c : character) return boolean is
    begin
        return  (character'pos(c) >= character'pos('a')) and
                (character'pos(c) <= character'pos('z'));
    end function;

    function is_upper(c : character) return boolean is
    begin
        return  (character'pos(c) >= character'pos('A')) and
                (character'pos(c) <= character'pos('Z'));
    end function;

    function is_digit(c : character) return boolean is
    begin
        return  (character'pos(c) >= character'pos('0')) and
                (character'pos(c) <= character'pos('9'));
    end function;

    function is_alpha(c : character) return boolean is
    begin
        return is_lower(c) or is_upper(c);
    end function;

    function is_alnum(c : character) return boolean is
    begin
        return is_digit(c) or is_alpha(c);
    end function;

    function is_xlower(c : character) return boolean is
    begin
        return  (character'pos(c) >= character'pos('a')) and
                (character'pos(c) <= character'pos('f'));
    end function;

    function is_xupper(c : character) return boolean is
    begin
        return  (character'pos(c) >= character'pos('A')) and
                (character'pos(c) <= character'pos('F'));
    end function;

    function is_xdigit(c : character) return boolean is
    begin
        return is_digit(c) or is_xlower(c) or is_xupper(c);
    end function;

    -- number of characters between 'A' and 'a' in ASCII-table
    constant CU2L : integer := character'pos('a') - character'pos('A');

    function to_lower(c : character) return character is
    begin
        if is_upper(c) then
            return character'val(character'pos(c) + CU2L);
        else
            return c;
        end if;
    end function;

    function to_upper(c : character) return character is
    begin
        if is_lower(c) then
            return character'val(character'pos(c) - CU2L);
        else
            return c;
        end if;
    end function;

    ----------------------------------------------------------------
    -- BIN, OCT, DEC, and HEX subtypes incl. error value (-1)
    ----------------------------------------------------------------

    function to_bin(c : character) return integer is
    begin
        case c is
            when '0'    => return 0;
            when '1'    => return 1;
            when others => return -1;
        end case;
    end function;

    function to_oct(c : character) return integer is
        variable dec : integer;
    begin
        dec := to_dec(c);
        if dec >= 0 and dec < 8 then
            return dec;
        else
            return -1;
        end if;
    end function;

    function to_dec(c : character) return integer is
    begin
        if is_digit(c) then
            return character'pos(c) - character'pos('0');
        else
            return -1;
        end if;
    end function;

    function to_hex(c : character) return integer is
    begin
        if is_digit(c) then
            return character'pos(c) - character'pos('0');
        elsif is_xlower(c) then
            return character'pos(c) - character'pos('a') + 10;
        elsif is_xupper(c) then
            return character'pos(c) - character'pos('A') + 10;
        else
            return -1;
        end if;
    end function;

end package body;
