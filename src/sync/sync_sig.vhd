--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     sync_sig.vhd
-- Description:     Synchronize a signal across clock-domain boundaries.
-- Create date:     Thu Mar 14 2019
--
-- This module synchronizes an asynchronous "long" time stable signal to clock
-- 'i_clk'. Output 'o_sync' is asserted and de-asserted synchronously.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.sync.all;

entity sync_sig is
    generic (
        I : bit := '0';                         -- init value
        D : t_sync_depth := t_sync_depth'low    -- synchronizer depth, min. 2
    );
    port (
        i_clk   : in std_logic;                 -- clock
        i_async : in std_logic;                 -- asynchronous input
        o_sync  : out std_logic                 -- synchronous output
    );
end sync_sig;

architecture behavioral of sync_sig is

    constant INIT : std_logic := to_stdulogic(I);
    signal r_sync : std_logic_vector(D-1 downto 0) := (others => INIT);

begin

    process(i_clk)
    begin
        if rising_edge(i_clk) then
            r_sync <= i_async &  r_sync(D-1 downto 1);
        end if;
    end process;

    o_sync <= r_sync(0);

end;
