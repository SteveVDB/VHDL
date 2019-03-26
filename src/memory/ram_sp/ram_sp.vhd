--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     ram_sp.vhd
-- Description:     single port RAM
-- Create date:     Mon Jan 14 2019
--------------------------------------------------------------------------------
--
-- read mode  => i_we = '0'
-- write mode => i_we = '1'
--
-- If attribute INIT_FILE is "none" then the memory is initialized to all 0s or
-- all 1s depending on the state of attribute INIT_VALUE. Otherwise the memory
-- is initialized from the specified file. The initialization file should
-- contain ASCII-coded hexadecimal or binary data with one word per line.
--
-- e.g. initialization file for a 8-bits wide, and 4-words depth RAM:
-- hexadecimal  binary
-- AF           10101111
-- 17           00010111
-- 03           00000011
-- CD           11001101
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.utils.all;
use SVDB.vectors.all;
use SVDB.strings.all;
use SVDB.mem_utils.all;

entity ram_sp is
    generic (
        A_BITS      : positive := 8;                        -- address bits
        D_BITS      : positive := 16;                       -- data bits
        INIT_VALUE  : bit      := '0';                      -- '0', or '1'
        INIT_FILE   : string   := "none";                   -- init. file
        FILE_FORMAT : string   := "hex"                     -- "hex", or "bin"
    );
    port (
        i_clk  : in std_logic;                              -- system clock
        i_ce   : in std_logic;                              -- clock enable
        i_we   : in std_logic;                              -- write enable
        i_addr : in std_logic_vector(A_BITS-1 downto 0);    -- address input
        i_data : in std_logic_vector(D_BITS-1 downto 0);    -- write data input
        o_data : out std_logic_vector(D_BITS-1 downto 0)    -- read data output
    );
end ;

architecture behavioral of ram_sp is

    -- memory depth
    constant DEPTH : positive := 2**A_BITS;

    -- memory type definitions
    subtype t_word is std_logic_vector(D_BITS-1 downto 0);
    type t_ram is array(0 to DEPTH-1) of t_word;

    -- memory initialization function
    impure function ram_init return t_ram is
        variable f_data : t_slm(0 to DEPTH-1, t_word'range);
        variable m_init : t_ram;
        variable sl : std_logic;
    begin
        if INIT_FILE = "none" then
            sl := to_stdulogic(INIT_VALUE);
            m_init := (others => (others => sl));
            report "ram_sp initial value: " & to_char(sl) & "s" severity note;
        else
            f_data := read_mem_file(INIT_FILE, FILE_FORMAT, DEPTH, D_BITS);
            for i in 0 to DEPTH-1 loop
                m_init(i) := get_row(f_data, i);
            end loop;
            report "ram_sp initial value: " & INIT_FILE severity note;
        end if;
        return m_init;
    end function;

    signal ram : t_ram := ram_init;

begin

    ----------------------------------------------------------------
    -- WRITE DATA: i_we = '1'
    ----------------------------------------------------------------
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_ce = '1' then
                if i_we = '1' then
                    ram(to_int(i_addr)) <= i_data;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- READ DATA: i_we = '0'
    ----------------------------------------------------------------
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_ce = '1' then
                if i_we = '0' then
                    o_data <= ram(to_int(i_addr));
                end if;
            end if;
        end if;
    end process;

end;
