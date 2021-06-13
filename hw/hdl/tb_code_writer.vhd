library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_code_writer is
end tb_code_writer;

architecture test of tb_code_writer is

    signal clk         : std_logic;
    signal rst_neg     : std_logic; -- negated signal

    signal dst_addr : std_logic_vector(31 downto 0);
    signal code     : std_logic_vector(63 downto 0);
    signal code_len : std_logic_vector(5 downto 0);
    signal wr       : std_logic;
    signal start    : std_logic;

    signal done     : std_logic;

    -- Avalon master signals
    signal code_write_mstr_address      : std_logic_vector(31 downto 0);
    signal code_write_mstr_read         : std_logic;
    signal code_write_mstr_read_data    : std_logic_vector(7 downto 0);
    signal code_write_mstr_write        : std_logic;
    signal code_write_mstr_write_data   : std_logic_vector(7 downto 0);
    signal code_write_mstr_wait_request : std_logic;

    constant clk_period : time := 100 ps;

begin

    dut : entity work.code_writer
    port map (
        clk_i                         => clk,
        rst_neg_i                     => rst_neg,
        dst_addr_i                    => dst_addr,
        code_i                        => code,
        code_len_i                    => code_len,
        write_i                       => wr,
        start_i                       => start,
        done_o                        => done,
        code_write_mstr_address_o      => code_write_mstr_address,
        code_write_mstr_read_o         => code_write_mstr_read,
        code_write_mstr_read_data_i    => code_write_mstr_read_data,
        code_write_mstr_write_o        => code_write_mstr_write,
        code_write_mstr_write_data_o   => code_write_mstr_write_data,
        code_write_mstr_wait_request_i => code_write_mstr_wait_request
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

        code_write_mstr_wait_request <= '1';

        -- SET DESTINATION ADDRESS
	    dst_addr <= "00000000000000001000000010000000";
        wr <= '1';
	    wait for 1 * clk_period;
	    wr <= '0';
	    wait for 1 * clk_period;

        -- START
        code <= "1010000000000000000000000000000000000000000000000000000000000000";
        code_len <= "000100";
        start <= '1';
        wait for 1 * clk_period;
        start <= '0';
        wait for 4 * clk_period;

        code <= "0000110000000000000000000000000000000000000000000000000000000000";
        code_len <= "000110";
        start <= '1';
        wait for 1 * clk_period;
        start <= '0';
        wait for 1 * clk_period;

	    -- Simulate waiting for read
	    wait for 10 * clk_period;

        code_write_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        code_write_mstr_wait_request <= '1';
        wait for 7 * clk_period;

        code <= "1111000011110000111100000000000000000000000000000000000000000000";
        code_len <= "010100";
        start <= '1';
        wait for 1 * clk_period;
        start <= '0';
        wait for 6 * clk_period;

        code_write_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        code_write_mstr_wait_request <= '1';
        wait for 7 * clk_period;

        code_write_mstr_wait_request <= '0';
        wait for 1 * clk_period;
        code_write_mstr_wait_request <= '1';
        wait for 7 * clk_period;

        wait;
    end process;
end architecture test;