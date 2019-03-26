--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     tb_strings
-- Create date:     Tue Oct 30 2018
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.strings.all;
use SVDB.vectors.all;

entity tb_strings is
end tb_strings;

architecture behavior of tb_strings is

    constant STR_SLV_8 : string := "10101101";
    constant SLV_8 : std_logic_vector(7 downto 0) := "10101101";

    constant STR_SLM_8x3 : string := (LF,
        '0',',','0',',','0',LF,
        '0',',','0',',','1',LF,
        '0',',','1',',','0',LF,
        '0',',','1',',','1',LF,
        '1',',','0',',','0',LF,
        '1',',','0',',','1',LF,
        '1',',','1',',','0',LF,
        '1',',','1',',','1'
    );

    constant SLM_8X3 : t_slm(0 to 7, 2 downto 0) := (
        ('0','0','0'),
        ('0','0','1'),
        ('0','1','0'),
        ('0','1','1'),
        ('1','0','0'),
        ('1','0','1'),
        ('1','1','0'),
        ('1','1','1')
    );

    constant STR_HEX        : string := "0123456789ABCDEFabcdef";

    constant STR_ALPHA_LOW  : string := "abcdefghijklmnopqrstuvwxyz";
    constant STR_ALPHA_UPP  : string := "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

    constant STR_ALNUM      : string := "0123456789" &
                                        "ABCDEFGHIJKLMNOPQRSTUVWXYZ" &
                                        "abcdefghijklmnopqrstuvwxyz";

    function find(str : string; c : character) return integer is
    begin
        for i in str'range loop
            if c = str(i) then
                return i;
            end if;
        end loop;
        return -1;
    end function;

begin

    -- stimulus process
    P_STIM: process
        variable char : character;
        variable j,k : integer := 1;
        variable str_slv : string(STR_SLV_8'range);
        variable str_slm : string(STR_SLM_8x3'range);
    begin

        -- to_string(slv)
        str_slv := to_string(SLV_8);
        assert str_slv = STR_SLV_8
        report "to_string(slv) error: " & str_slv severity failure;

        -- to_string(slm)
        str_slm := to_string(SLM_8X3);
        assert str_slm = STR_SLM_8x3
        report "to_string(slm) error: " & str_slm severity failure;

        -- is_alnum()
        for i in 0 to 127 loop
            char := character'val(i);
            if is_alnum(char) then
                assert find(STR_ALNUM, char) >= 0
                report "is_alnum() error: " & character'image(char)
                severity failure;
            end if;
        end loop;

        -- to_lower() / to_upper
        for i in 1 to 26 loop
            char := to_lower(STR_ALPHA_UPP(i));
            assert char = STR_ALPHA_LOW(i)
            report "to_lower() error: " & character'image(char)
            severity failure;

            char := to_upper(STR_ALPHA_LOW(i));
            assert char = STR_ALPHA_UPP(i)
            report "to_upper() error: " & character'image(char)
            severity failure;
        end loop;

        -- to_bin() / to_oct() / to_dec() / to_hex()
        for i in 1 to STR_HEX'length loop
            char := STR_HEX(i);

            if i <= 16 then
                j := i - 1;
            else
                j := i - 7;
            end if;

            if j < 2 then
                k := to_bin(STR_HEX(i));
                assert k = j
                report "to_bin() error: " & character'image(char)
                severity failure;
            end if;

            if j < 8 then
                k := to_oct(STR_HEX(i));
                assert k = j
                report "to_oct() error: " & character'image(char)
                severity failure;
            end if;

            if j < 10 then
                k := to_dec(STR_HEX(i));
                assert k = j
                report "to_dec() error: " & character'image(char)
                severity failure;
            end if;

            k := to_hex(STR_HEX(i));
            assert k = j
            report "to_hex() error : " & character'image(char)
            severity failure;
        end loop;

        report "testing package: strings DONE !" severity note;
        wait;

    end process;
end;
