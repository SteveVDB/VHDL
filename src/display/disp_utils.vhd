--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     disp_utils.vhd
-- Create date:     Thu Mar 21 2019
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package disp_utils is

    -- BCD to 7-segment decoder
    -- al = Active Level ('0' or '1') to turn a segment on.
    function decode7(bcd : std_logic_vector(3 downto 0); al : bit)
            return std_logic_vector;

end package;

package body disp_utils is

    function decode7(bcd : std_logic_vector(3 downto 0); al : bit)
            return std_logic_vector is
        constant E   : std_logic := to_stdulogic(al);   -- enable segment
        constant D   : std_logic := not E;              -- disable segment
        variable res : std_logic_vector(6 downto 0);
    begin
        case bcd is             -- a b c d e f g
            when "0000" => res := (E,E,E,E,E,E,D);  -- 0
            when "0001" => res := (D,E,E,D,D,D,D);  -- 1
            when "0010" => res := (E,E,D,E,E,D,E);  -- 2
            when "0011" => res := (E,E,E,E,D,D,E);  -- 3
            when "0100" => res := (D,E,E,D,D,E,E);  -- 4
            when "0101" => res := (E,D,E,E,D,E,E);  -- 5
            when "0110" => res := (E,D,E,E,E,E,E);  -- 6
            when "0111" => res := (E,E,E,D,D,D,D);  -- 7
            when "1000" => res := (E,E,E,E,E,E,E);  -- 8
            when "1001" => res := (E,E,E,E,D,E,E);  -- 9
            when "1010" => res := (E,E,E,D,E,E,E);  -- A
            when "1011" => res := (D,D,E,E,E,E,E);  -- b
            when "1100" => res := (E,D,D,E,E,E,D);  -- C
            when "1101" => res := (D,E,E,E,E,D,E);  -- d
            when "1110" => res := (E,D,D,E,E,E,E);  -- E
            when others => res := (E,D,D,D,E,E,E);  -- F
        end case;
        return res;
    end function;
    
end package body;
