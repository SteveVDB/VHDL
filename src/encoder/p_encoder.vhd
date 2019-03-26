--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     p_encoder.vhd
-- Description:     N-bit priority encoder.
-- Create date:     Mon Mar 25 2019
--------------------------------------------------------------------------------
--
-- This priority encoder outputs an R-bit binary number that indicates which
-- one of the N-inputs is active high. Input N-1 has the highest priority.
-- With the enable input and enable output several encoders can by cascaded.
-- The group select output is a valid signal that goes high when any of the
-- input lines is selected.
--
-- look-up-table for eight inputs (N=8, R=3)
--
-- EI    = enable input     (i_enb)
-- I7-I0 = data inputs      (i_data)
-- A2-A0 = binary output    (o_bin)
-- GS    = group select     (o_gs)
-- EO    = enable output    (o_enb)
--
-- ---------------------------------------------------------
-- |EI |I7 |I6 |I5 |I4 |I3 |I2 |I1 |I0 |A2 |A1 |A0 |GS |EO |
-- |---|---|---|---|---|---|---|---|---|---|---|---|---|---|
-- | 0 | X | X | X | X | X | X | X | X | 0 | 0 | 0 | 0 | 0 |
-- | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 |
-- | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 1 | 0 |
-- | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | X | 0 | 0 | 1 | 1 | 0 |
-- | 1 | 0 | 0 | 0 | 0 | 0 | 1 | X | X | 0 | 1 | 0 | 1 | 0 |
-- | 1 | 0 | 0 | 0 | 0 | 1 | X | X | X | 0 | 1 | 1 | 1 | 0 |
-- | 1 | 0 | 0 | 0 | 1 | X | X | X | X | 1 | 0 | 0 | 1 | 0 |
-- | 1 | 0 | 0 | 1 | X | X | X | X | X | 1 | 0 | 1 | 1 | 0 |
-- | 1 | 0 | 1 | X | X | X | X | X | X | 1 | 1 | 0 | 1 | 0 |
-- | 1 | 1 | X | X | X | X | X | X | X | 1 | 1 | 1 | 1 | 0 |
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.utils.all;

entity p_encoder is
    generic (
        N : positive := 8;                              -- #inputs
        R : positive := 3                               -- #outputs
    );
    port (
        i_enb  : in std_logic;                          -- input enable
        i_data : in std_logic_vector(N-1 downto 0);     -- data inputs
        o_bin  : out std_logic_vector(R-1 downto 0);    -- binary output
        o_gsel : out std_logic;                         -- group select
        o_enb  : out std_logic                          -- output enable
    );
end ;

architecture behavioral of p_encoder is

begin

    o_gsel <= i_enb and slv_or(i_data);
    o_enb  <= i_enb and not slv_or(i_data);

    process(i_data)
    begin
        o_bin <= (others => '0');
        for j in 0 to N-1 loop
            if i_data(j) = '1' then
                o_bin <= to_slv(j, R);
            end if;
        end loop;
    end process;

end;
