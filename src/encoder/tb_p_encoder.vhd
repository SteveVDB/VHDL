--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     tb_p_encoder.vhd
-- Description:     testbench
-- Create date:     Mon Mar 25 2019
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

library SVDB;
use SVDB.utils.all;

entity tb_p_encoder is
end tb_p_encoder;

architecture behavior of tb_p_encoder is

    constant N : positive := 8;
    constant R : positive := ceil_log2(N);

    -- component declaration of Unit Under Test
    component p_encoder
        generic (
            N : positive;
            R : positive
        );
        port (
            i_enb  : in std_logic;
            i_data : in std_logic_vector(N-1 downto 0);
            o_bin  : out std_logic_vector(R-1 downto 0);
            o_gsel : out std_logic;
            o_enb  : out std_logic
        );
    end component;

    -- inputs
    signal i_enb  : std_logic;
    signal i_data : std_logic_vector(N-1 downto 0);

    -- outputs
    signal o_bin  : std_logic_vector(R-1 downto 0);
    signal o_gsel : std_logic;
    signal o_enb  : std_logic;

    -- simulation signal
    signal end_of_sim : boolean := false;

    type pattern_t is record
        ei  : std_logic;
        inp : std_logic_vector(N-1 downto 0);
        bin : std_logic_vector(R-1 downto 0);
        gs  : std_logic;
        eo  : std_logic;
    end record;

    type table_t is array (natural range <>) of pattern_t;
    constant LUT : table_t := (
        ('0',"00000000","000",'0','0'),
        ('1',"00000000","000",'0','1'),
        ('1',"00000001","000",'1','0'),
        ('1',"00000010","001",'1','0'),
        ('1',"00000100","010",'1','0'),
        ('1',"00001000","011",'1','0'),
        ('1',"00010000","100",'1','0'),
        ('1',"00100000","101",'1','0'),
        ('1',"01000000","110",'1','0'),
        ('1',"10000000","111",'1','0'),
        ('1',"11111111","111",'1','0'),
        ('1',"01111111","110",'1','0'),
        ('1',"00111111","101",'1','0'),
        ('1',"00011111","100",'1','0'),
        ('1',"00001111","011",'1','0'),
        ('1',"00000111","010",'1','0'),
        ('1',"00000011","001",'1','0')
    );

begin

    -- instantiate Unit Under Test (UUT)
    uut: p_encoder
    generic map (
        N => N,
        R => R
    )
    port map (
        i_enb  => i_enb,
        i_data => i_data,
        o_bin  => o_bin,
        o_gsel => o_gsel,
        o_enb  => o_enb
    );

    -- stimulus process
    P_STIM: process
    begin

        for i in LUT'range loop

            -- set inputs
            i_enb  <= LUT(i).ei;
            i_data <= LUT(i).inp;

            wait for 100 ns;

            -- check outputs
            assert o_bin = LUT(i).bin
            report "bad binary output (" & integer'image(i) & ")"
            severity error;

            assert o_enb = LUT(i).eo
            report "bad enable output (" & integer'image(i) & ")"
            severity error;

            assert o_gsel = LUT(i).gs
            report "bad group select (" & integer'image(i) & ")"
            severity error;

        end loop;

        -- end simulation
        end_of_sim <= true;

        wait;

    end process;
end;
