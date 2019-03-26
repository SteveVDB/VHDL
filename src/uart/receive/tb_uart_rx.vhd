--------------------------------------------------------------------------------
-- Engineer:        Steve Vandenbussche
-- Module name:     tb_uart_rx
-- Description:     testbench
-- Create date:     Mon Jan 21 2019
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;

library SVDB;
use SVDB.utils.all;
use SVDB.strings.all;

entity tb_uart_rx is
end tb_uart_rx;

architecture behavior of tb_uart_rx is

    -- 0: 8N1   2: 8E1  4: 8O1  6: 9N1
    -- 1: 8N2   3: 8E2  5: 8O2  7: 9N2
    constant UART_MODE : integer := 1;
    constant UART_DATA : string := "Test!";

    -- simulate frame and parity error
    constant FRAME_ERROR0 : boolean := false;       -- stop bit 0 error
    constant FRAME_ERROR1 : boolean := false;       -- stop bit 1 error
    constant PARITY_ERROR : boolean := false;       -- parity bit error

    -- component declaration of Unit Under Test
    component uart_rx
        port (
            i_clk : in std_logic;
            i_rst : in std_logic;
            i_enb : in std_logic;
            i_rx  : in std_logic;
            i_nsb : in std_logic;
            i_pds : in std_logic_vector(1 downto 0);
            i_brv : in std_logic_vector(7 downto 0);
            o_rxd : out std_logic_vector(7 downto 0);
            o_rx8 : out std_logic;
            o_frs : out std_logic;
            o_fps : out std_logic;
            o_fes : out std_logic
        );
    end component;

    -- inputs
    signal i_clk : std_logic;
    signal i_rst : std_logic;
    signal i_enb : std_logic;
    signal i_rx  : std_logic;
    signal i_nsb : std_logic;
    signal i_pds : std_logic_vector(1 downto 0);
    signal i_brv : std_logic_vector(7 downto 0);

    -- outputs
    signal o_rxd : std_logic_vector(7 downto 0);
    signal o_rx8 : std_logic;
    signal o_frs : std_logic;
    signal o_fps : std_logic;
    signal o_fes : std_logic;

    -- clock period definitions (40MHz)
    constant CLK_PERIOD : time := 25 ns;

    -- UART baud rate (250kbps)
    constant BIT_TIME : time := 4 us;

    -- simulation signal
    signal end_of_sim : boolean := false;

    -- UART transmit procedure
    procedure uart_tx(str : in string; tx8 : in std_logic; nsb : in std_logic;
            pds : in std_logic_vector(1 downto 0); signal tx : out std_logic) is
        constant ERR_FRAME : integer := ceil_div(str'length, 2);
        variable txd0,txd1 : std_logic_vector(7 downto 0);
        variable bit8 : std_logic := tx8;
    begin

        for i in 1 to str'length loop
            txd0 := to_slv(character'pos(str(i)), 8);
            txd1 := txd0;

            -- add parity error to frame
            if i = ERR_FRAME then
                if PARITY_ERROR = true then
                    txd1(3) := not txd1(3);
                end if;
            end if;

            -- start bit
            tx <= '0';
            wait for BIT_TIME;

            -- eight data bits
            for j in 0 to 7 loop
                tx <= txd1(j);
                wait for BIT_TIME;
            end loop;

            -- parity or ninth data bit
            if pds = "01" then
                tx <= slv_xor(txd0);
                wait for BIT_TIME;
            elsif pds = "10" then
                tx <= not slv_xor(txd0);
                wait for BIT_TIME;
            elsif pds = "11" then
                tx <= bit8;
                bit8 := not bit8;
                wait for BIT_TIME;
            end if;

            -- stop bit0
            tx <= '1';
            if i = ERR_FRAME then
                if FRAME_ERROR0 = true then
                    tx <= '0';
                end if;
            end if;
            wait for BIT_TIME;

            -- stop bit1
            if nsb = '1' then
                tx <= '1';
                if i = ERR_FRAME then
                    if FRAME_ERROR1 = true then
                        tx <= '0';
                    end if;
                end if;
                wait for BIT_TIME;
            end if;

        end loop;
    end procedure;

begin

    -- instantiate Unit Under Test (UUT)
    uut: uart_rx
    port map (
        i_clk => i_clk,
        i_rst => i_rst,
        i_enb => i_enb,
        i_rx  => i_rx,
        i_nsb => i_nsb,
        i_pds => i_pds,
        i_brv => i_brv,
        o_rxd => o_rxd,
        o_rx8 => o_rx8,
        o_frs => o_frs,
        o_fps => o_fps,
        o_fes => o_fes
    );

    -- clock process
    P_CLK: process
    begin
        while not end_of_sim loop
            i_clk <= '1';
            wait for CLK_PERIOD / 2;
            i_clk <= '0';
            wait for CLK_PERIOD / 2;
        end loop;

        report "simulation ended" severity note;
        wait;
    end process;

    -- stimulus process
    P_STIM: process
    begin

        -- receive input high
        i_rx  <= '1';

        -- set number of stop bits
        -- set parity/data select bits
        case UART_MODE is
            when 0      => i_nsb <= '0'; i_pds <= "00";      -- 8N1
            when 1      => i_nsb <= '1'; i_pds <= "00";      -- 8N2
            when 2      => i_nsb <= '0'; i_pds <= "01";      -- 8E1
            when 3      => i_nsb <= '1'; i_pds <= "01";      -- 8E2
            when 4      => i_nsb <= '0'; i_pds <= "10";      -- 8O1
            when 5      => i_nsb <= '1'; i_pds <= "10";      -- 8O2
            when 6      => i_nsb <= '0'; i_pds <= "11";      -- 9N1
            when others => i_nsb <= '1'; i_pds <= "11";      -- 9N2
        end case;

        -- set baud rate value
        i_brv <= to_slv((BIT_TIME / (2*CLK_PERIOD))-1, 8);

        -- reset UART receiver;
        i_rst <= '1';
        i_enb <= '0';
        wait for CLK_PERIOD * 10;
        i_rst <= '0';
        i_enb <= '1';
        wait for CLK_PERIOD * 10;

        -- transmit UART data
        uart_tx(UART_DATA, '0', i_nsb, i_pds, i_rx);

        -- end simulation
        end_of_sim <= true;

        wait;

    end process;
end;
