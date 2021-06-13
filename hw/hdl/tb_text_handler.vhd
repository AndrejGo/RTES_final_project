library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_text_handler is
end tb_text_handler;

architecture test of tb_text_handler is

    signal clk         : std_logic;
    signal rst_neg     : std_logic; -- negated signal

    signal codes_base_addr : std_logic_vector(31 downto 0);
    signal text_addr       : std_logic_vector(31 downto 0);
    signal dst_addr        : std_logic_vector(31 downto 0);
    signal header_size     : std_logic_vector(31 downto 0);
    signal wr              : std_logic;
    signal start           : std_logic;
    signal done            : std_logic;

    -- Avalon master signals
    signal text_mstr_address      : std_logic_vector(31 downto 0);
    signal text_mstr_read         : std_logic;
    signal text_mstr_read_data    : std_logic_vector(7 downto 0);
    signal text_mstr_write        : std_logic;
    signal text_mstr_write_data   : std_logic_vector(7 downto 0);
    signal text_mstr_wait_request : std_logic;

    constant clk_period : time := 100 ps;

begin

    dut : entity work.text_handler
    port map (
        clk_i                    => clk,
        rst_neg_i                => rst_neg,
        codes_base_addr_i        => codes_base_addr,
        text_addr_i              => text_addr,
        dst_addr_i               => dst_addr,
        header_size_i            => header_size,
        write_i                  => wr,
        start_i                  => start,
        done_o                   => done,
        text_mstr_address_o      => text_mstr_address,
        text_mstr_read_o         => text_mstr_read,
        text_mstr_read_data_i    => text_mstr_read_data,
        text_mstr_write_o        => text_mstr_write,
        text_mstr_write_data_o   => text_mstr_write_data,
        text_mstr_wait_request_i => text_mstr_wait_request
    );

    clock : process
    begin
        while(true) loop
            clk <= '1';
            wait for clk_period / 2;
            clk <= '0';
            wait for clk_period / 2;
        end loop;
        wait;
    end process;

    simulation : process
    begin

        -- INITIAL RESET
        rst_neg <= '0';
        wait for 2 * clk_period;
        rst_neg <= '1';
        wait for 2 * clk_period;

        text_mstr_wait_request <= '1';

        wait for 2 * clk_period;

        codes_base_addr <= X"0000ff00";
        text_addr <= X"00ff0000";
        dst_addr <= X"00000000";
        header_size <= X"00000010";
        wr <= '1';
        wait for 1 * clk_period;
        wr <= '0';
        wait for 1 * clk_period;

        start <= '1';
        wait for 1 * clk_period;
        start <= '0';
        wait for 1 * clk_period;

        text_mstr_read_data <= X"64"; -- d
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 1 * clk_period;

        wait for 5 * clk_period;
        
        -- Read address of encoding of d
        text_mstr_read_data <= X"01";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"02";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"03";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"04";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 6 * clk_period;

        -- READ THE ACTUAL ENCODING of d 0111111
        text_mstr_read_data <= X"30";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"00";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        wait for 10 * clk_period;

        text_mstr_read_data <= X"6f"; -- o
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 1 * clk_period;

        wait for 5 * clk_period;
        
        -- Read address of encoding of o
        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 6 * clk_period;

        -- READ THE ACTUAL ENCODING of o 1110
        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"30";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"00";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        -- Write first encoding byte
        wait for 5 * clk_period;
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        wait for 10 * clk_period;

        text_mstr_read_data <= X"67"; -- g
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 1 * clk_period;

        wait for 5 * clk_period;
        
        -- Read address of encoding of g
        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 6 * clk_period;

        -- READ THE ACTUAL ENCODING of g 100001
        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"30";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"30";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"30";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"30";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"30";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"00";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        -- Write second encoding byte
        wait for 5 * clk_period;
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        wait for 10 * clk_period;

        text_mstr_read_data <= X"2e"; -- .
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 1 * clk_period;

        wait for 5 * clk_period;
        
        -- Read address of encoding of .
        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 6 * clk_period;

        -- READ THE ACTUAL ENCODING of . 10001
        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"30";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"30";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"30";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"31";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"00";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        wait for 10 * clk_period;

        text_mstr_read_data <= X"32"; -- _
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 1 * clk_period;

        wait for 5 * clk_period;
        
        -- Read address of encoding of _
        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"ff";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 6 * clk_period;

        -- READ THE ACTUAL ENCODING of _ 00
        text_mstr_read_data <= X"30";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"30";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        text_mstr_read_data <= X"00";
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        wait for 10 * clk_period;

        text_mstr_read_data <= X"00"; -- \0
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 1 * clk_period;
        
        ---------------------------------------
        -- Write length
        wait for 5 * clk_period;
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        wait for 5 * clk_period;
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        wait for 5 * clk_period;
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        wait for 5 * clk_period;
        text_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        text_mstr_wait_request <= '1';
        wait for 2 * clk_period;

        wait;
    end process;
end architecture test;