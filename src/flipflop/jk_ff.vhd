--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     jk_ff.vhd
-- Description:     JF-flipflop with clock enable and synchronous reset
-- Create date:     Tue Mar 12 2019
--
-- Q = present state, Q' = next state
--
-- j | k | Q | Q'
-- 0 | 0 | 0 | 0 hold
-- 0 | 0 | 1 | 1 hold
-- 0 | 1 | 0 | 0 reset
-- 0 | 1 | 1 | 0 reset
-- 1 | 0 | 0 | 1 set
-- 1 | 0 | 1 | 1 set
-- 1 | 1 | 0 | 1 toggle
-- 1 | 1 | 1 | 0 toggle
--
-- Q | Q'| J | K
-- 0 | 0 | 0 | x hold
-- 0 | 1 | 1 | x set
-- 1 | 0 | x | 1 reset
-- 1 | 1 | x | 0 hold
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity jk_ff is
    port (
        i_clk : in std_logic;       -- clock
        i_rst : in std_logic;       -- reset
        i_ce  : in std_logic;       -- clock enable
        i_j   : in std_logic;       -- J-input
        i_k   : in std_logic;       -- K-input
        o_q   : out std_logic       -- output
    );
end jk_ff;

architecture behavioral of jk_ff is

    signal r_q : std_logic;
    signal s_jk : std_logic_vector(1 downto 0);

begin

    s_jk <= i_j & i_k;

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                r_q <= '0';
            elsif i_ce = '1' then
                if s_jk = "00" then
                    r_q <= r_q;
                elsif s_jk = "01" then
                    r_q <= '0';
                elsif s_jk = "10" then
                    r_q <= '1';
                else
                    r_q <= not r_q;
                end if;
            end if;
        end if;
    end process;

    o_q <= r_q;

end;
