--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     sync_rst.vhd
-- Description:     Synchronize a reset signal across clock domain boundaries.
-- Create date:     Thu Mar 14 2019
--
-- This module synchronizes an asynchronous reset signal to the clock 'i_clk'.
-- Output 'o_sync' is asserted asynchronously and de-asserted synchronously.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.sync.all;

entity sync_rst is
    generic (
        D : t_sync_depth := t_sync_depth'low    -- synchronizer depth, min. 2
    );
    port (
        i_clk   : in std_logic;                 -- clock
        i_async : in std_logic;                 -- asynchronous input
        o_sync  : out std_logic                 -- synchronous output
    );
end sync_rst;

architecture behavioral of sync_rst is

    signal r_sync : std_logic_vector(D-1 downto 0) := (others => '1');

begin

    process(i_async, i_clk)
    begin
        if i_async = '1' then
            r_sync <= (others => '1');
        elsif rising_edge(i_clk) then
            r_sync <= '0' & r_sync(D-1 downto 1);
        end if;
    end process;

    o_sync <= r_sync(0);

end;
