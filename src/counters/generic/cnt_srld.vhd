--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     cnt_srld.vhd
-- Description:     N-bit counter with synchronous reset, parallel load, and
--                  count direction.
-- Create date:     Thu Feb 28 2019
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cnt_srld is
    generic (
        N : positive := 8                           -- number of bits
    );
    port (
        i_clk : in std_logic;                       -- clock
        i_rst : in std_logic;                       -- reset
        i_ce  : in std_logic;                       -- clock enable
        i_pl  : in std_logic;                       -- parallel load
        i_dir : in std_logic;                       -- count direction
        i_par : in std_logic_vector(N-1 downto 0);  -- parallel data input
        o_cnt : out std_logic_vector(N-1 downto 0)  -- counter output
    );
end ;

architecture behavioral of cnt_srld is

    signal r_cnt : unsigned(N-1 downto 0) := (others => '0');

begin

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                r_cnt <= (others => '0');
            elsif i_ce = '1' then
                if i_pl = '1' then
                    r_cnt <= unsigned(i_par);
                elsif i_dir = '1' then
                    r_cnt <= r_cnt + 1;
                else
                    r_cnt <= r_cnt - 1;
                end if;
            end if;
        end if;
    end process;

    o_cnt <= std_logic_vector(r_cnt);

end;
