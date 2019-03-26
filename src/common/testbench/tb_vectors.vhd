--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     tb_vectors.vhd
-- Create date:     Wed Oct 24 2018
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.vectors.all;
use SVDB.strings.all;

entity tb_vectors is
end tb_vectors;

architecture behavior of tb_vectors is

    constant SLV_64 : std_logic_vector(63 downto 0) :=
    "0000000000010001001000100011001101000100010101010110011001110111";

    constant SLVV_8 : t_slvv_8(7 downto 0) := (
        SLV_64(63 downto 56),
        SLV_64(55 downto 48),
        SLV_64(47 downto 40),
        SLV_64(39 downto 32),
        SLV_64(31 downto 24),
        SLV_64(23 downto 16),
        SLV_64(15 downto  8),
        SLV_64( 7 downto  0)
    );

    constant SLVV_16 : t_slvv_16(3 downto 0) := (
        SLV_64(63 downto 48),
        SLV_64(47 downto 32),
        SLV_64(31 downto 16),
        SLV_64(15 downto  0)
    );

    constant SLVV_32 : t_slvv_32(1 downto 0) := (
        SLV_64(63 downto 32),
        SLV_64(31 downto  0)
    );

    constant SLM_8X3 : t_slm(0 to 7, 2 downto 0) := (
        ('X','0','0'),
        ('X','X','X'),
        ('X','1','0'),
        ('X','1','1'),
        ('X','0','0'),
        ('X','0','1'),
        ('X','1','0'),
        ('X','1','1')
    );

    constant SLM_8X3_SIZE : integer := 24;
    constant SLM_8X3_ROW1 : std_logic_vector(2 downto 0) := "001";
    constant SLM_8X3_COL2 : std_logic_vector(7 downto 0) := "11110000";

begin

    -- stimulus process
    P_STIM: process
        variable int : integer := 0;
        variable slv : std_logic_vector(SLV_64'range);
        variable slm : t_slm(0 to 7, 2 downto 0) := SLM_8X3;
    begin

        -- to_slv(t_slvv_8)
        slv := to_slv(SLVV_8);
        assert slv = SLV_64
        report "to_slv(t_slvv_8) error: " & to_string(slv) severity failure;

        -- to_slv(t_slvv_16)
        slv := to_slv(SLVV_16);
        assert slv = SLV_64
        report "to_slv(t_slvv_16) error: " & to_string(slv) severity failure;

        -- to_slv(t_slvv_32)
        slv := to_slv(SLVV_32);
        assert slv = SLV_64
        report "to_slv(t_slvv_32) error: " & to_string(slv) severity failure;

        -- to_slvv_8(slv)
        assert to_slvv_8(SLV_64) = SLVV_8
        report "to_slvv_8() error" severity failure;

        -- to_slvv_16(slv)
        assert to_slvv_16(SLV_64) = SLVV_16
        report "to_slvv_16() error" severity failure;

        -- to_slvv_32(slv)
        assert to_slvv_32(SLV_64) = SLVV_32
        report "to_slvv_32() error" severity failure;

        -- size()
        int := size(slm);
        assert int = SLM_8X3_SIZE
        report "slm_size error: " & integer'image(int) severity failure;

        -- set_row() / get_row()
        set_row(slm, SLM_8X3_ROW1, 1);
        assert get_row(slm, 1) = SLM_8X3_ROW1
        report "slm row error: " & to_string(slm) severity failure;

        -- set_col() / get_col()
        set_col(slm, SLM_8X3_COL2, 2);
        assert get_col(slm, 2) = SLM_8X3_COL2
        report "slm column error: " & to_string(slm) severity failure;

        report "testing package: vectors DONE !" severity note;
        wait;

    end process;
end;
