--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     ram_dp.vhd
-- Description:     pseudo dual port RAM
-- Create date:     Tue Jan 15 2019
--------------------------------------------------------------------------------
--
-- RAM-mode is read-before-write when both ports are enabled, and addressing the
-- same memory location. Data from the specified memory location appears on the
-- read port data ouput, while the data at write port input is written to the
-- specified memory location.
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

entity ram_dp is
    generic (
        A_BITS      : positive := 8;                        -- address bits
        D_BITS      : positive := 16;                       -- data bits
        INIT_VALUE  : bit      := '0';                      -- '0', or '1'
        INIT_FILE   : string   := "none";                   -- init. file
        FILE_FORMAT : string   := "hex"                     -- "hex", or "bin"
    );
    port (
        i_wr_clk  : in std_logic;                           -- write clock
        i_wr_ce   : in std_logic;                           -- write clk enable
        i_wr_en   : in std_logic;                           -- write enable
        i_wr_addr : in std_logic_vector(A_BITS-1 downto 0); -- write address
        i_wr_data : in std_logic_vector(D_BITS-1 downto 0); -- write data input
        i_rd_clk  : in std_logic;                           -- read clock
        i_rd_ce   : in std_logic;                           -- read clk enable
        i_rd_en   : in std_logic;                           -- read enable
        i_rd_addr : in std_logic_vector(A_BITS-1 downto 0); -- read address
        o_rd_data : out std_logic_vector(D_BITS-1 downto 0) -- read data output
    );
end ;

architecture behavioral of ram_dp is

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
            report "ram_dp initial value: " & to_char(sl) & "s" severity note;
        else
            f_data := read_mem_file(INIT_FILE, FILE_FORMAT, DEPTH, D_BITS);
            for i in 0 to DEPTH-1 loop
                m_init(i) := get_row(f_data, i);
            end loop;
            report "ram_dp initial value: " & INIT_FILE severity note;
        end if;
        return m_init;
    end function;

    signal ram : t_ram := ram_init;

begin

    ----------------------------------------------------------------
    -- WRITE PORT
    ----------------------------------------------------------------
    process(i_wr_clk)
    begin
        if rising_edge(i_wr_clk) then
            if i_wr_ce = '1' then
                if i_wr_en = '1' then
                    ram(to_int(i_wr_addr)) <= i_wr_data;
                end if;
            end if;
        end if;
    end process;

    ----------------------------------------------------------------
    -- READ PORT
    ----------------------------------------------------------------
    process(i_rd_clk)
    begin
        if rising_edge(i_rd_clk) then
            if i_rd_ce = '1' then
                if i_rd_en = '1' then
                    o_rd_data <= ram(to_int(i_rd_addr));
                end if;
            end if;
        end if;
    end process;

end;
