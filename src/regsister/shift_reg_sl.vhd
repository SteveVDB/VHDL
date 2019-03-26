--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     shift_reg_sl.vhd
-- Description:     N-bit shift register with synchronous parallel load.
-- Create date:     Wed Jan 16 2019

-- shift left when direction = '0'               shift register <- i_ser
-- shift right when direction = '1'     i_ser -> shift register
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity shift_reg_sl is
    generic (
        N : positive := 8                           -- number of bits
    );
    port (
        i_clk : in std_logic;                       -- clock
        i_pl  : in std_logic;                       -- parallel load
        i_ce  : in std_logic;                       -- clock enable
        i_dir : in std_logic;                       -- shift direction
        i_ser : in std_logic;                       -- serial input
        i_par : in std_logic_vector(N-1 downto 0);  -- parallel input
        o_reg : out std_logic_vector(N-1 downto 0)  -- register output
    );

end shift_reg_sl;

architecture behavioral of shift_reg_sl is

    signal r_shift : std_logic_vector(N-1 downto 0);

begin

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_pl = '1' then
                r_shift <= i_par;
            elsif i_ce = '1' then
                if i_dir = '0' then
                    r_shift <= r_shift(N-2 downto 0) & i_ser;
                else
                    r_shift <= i_ser & r_shift(N-1 downto 1);
                end if;
            end if;
        end if;
    end process;

    o_reg <= r_shift;

end;
