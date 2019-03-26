--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     tb_memory.vhd
-- Create date:     Wed Jan 09 2019
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.memory.all;
use SVDB.strings.all;
use SVDB.vectors.all;

entity tb_mem_utils is
end tb_mem_utils;

architecture behavior of tb_mem_utils is

    constant HEX_FILE : string := "init_hex.mem";
    constant BIN_FILE : string := "init_bin.mem";

    constant A_BITS : positive := 2;            -- address bits
    constant D_BITS : positive := 8;            -- data bits
    constant DEPTH  : positive := 2**A_BITS;    -- memory depth

    constant HEX_FILE_CONTENT : t_slm(0 to DEPTH-1, D_BITS-1 downto 0) := (
        ('0','1','0','0','1','0','0','1'),      -- 49
        ('1','0','0','1','1','1','1','0'),      -- 9E
        ('1','0','1','0','1','0','1','1'),      -- AB
        ('0','0','0','0','1','1','0','0')       -- 0C
    );

    constant BIN_FILE_CONTENT : t_slm(0 to DEPTH-1, D_BITS-1 downto 0) := (
        ('1','1','0','0','1','0','0','1'),      -- 11001001
        ('0','0','1','1','0','0','1','1'),      -- 00110011
        ('1','0','1','0','0','0','0','0'),      -- 10100000
        ('0','0','1','0','1','1','1','0')       -- 00101110
    );

begin

    -- stimulus process
    P_STIM: process
        variable slm : t_slm(0 to DEPTH-1, D_BITS-1 downto 0);
    begin

        -- read_mem_file(hex)
        slm := read_mem_file(HEX_FILE, f_hex, DEPTH, D_BITS);
        assert slm = HEX_FILE_CONTENT
        report "read_mem_file(hex) error: " & to_string(slm) severity failure;

        -- read_mem_file(bin)
        slm := read_mem_file(BIN_FILE, f_bin, DEPTH, D_BITS);
        assert slm = BIN_FILE_CONTENT
        report "read_mem_file(bin) error: " & to_string(slm) severity failure;

        report "testing package: memory DONE !" severity note;
        wait;

    end process;
end;
