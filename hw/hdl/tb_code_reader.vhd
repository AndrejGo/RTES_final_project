library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_code_reader is
end tb_code_reader;

architecture test of tb_code_reader is

    signal clk         : std_logic;
    signal rst_neg     : std_logic; -- negated signal

    signal code_addr : std_logic_vector(31 downto 0);
    signal start     : std_logic;

    signal done      : std_logic;
    signal length    : std_logic_vector(5 downto 0);
    signal bit_rep   : std_logic_vector(63 downto 0);

    -- Avalon master signals
    signal code_read_mstr_address      : std_logic_vector(31 downto 0);
    signal code_read_mstr_read         : std_logic;
    signal code_read_mstr_read_data    : std_logic_vector(7 downto 0);
    signal code_read_mstr_write        : std_logic;
    signal code_read_mstr_write_data   : std_logic_vector(7 downto 0);
    signal code_read_mstr_wait_request : std_logic;

    constant clk_period : time := 100 ps;

begin

    dut : entity work.code_reader
    port map (
        clk_i                         => clk,
        rst_neg_i                     => rst_neg,
        code_addr_i                   => code_addr,
        start_i                       => start,
        done_o                        => done,
        length_o                      => length,
        bit_rep_o                     => bit_rep,
        code_read_mstr_address_o      => code_read_mstr_address,
        code_read_mstr_read_o         => code_read_mstr_read,
        code_read_mstr_read_data_i    => code_read_mstr_read_data,
        code_read_mstr_write_o        => code_read_mstr_write,
        code_read_mstr_write_data_o   => code_read_mstr_write_data,
        code_read_mstr_wait_request_i => code_read_mstr_wait_request
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

    code_read_mstr_wait_request <= '1';

	-- SET ADDRESS OF ADDRESS
	code_addr <= "00000000000000001000000010000000";
    start <= '1';
	wait for 1 * clk_period;
	start <= '0';
	wait for 2 * clk_period;
	-- Simulate waiting for read
	wait for 10 * clk_period;
	


    -- READ ADDRESS OF C STRING
    code_read_mstr_read_data <= "00000001";
	code_read_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	code_read_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;

    code_read_mstr_read_data <= "00000010";
	code_read_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	code_read_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;

    code_read_mstr_read_data <= "00000011";
	code_read_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	code_read_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;

    code_read_mstr_read_data <= "00000100";
	code_read_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	code_read_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;



    -- READ C STRING
	code_read_mstr_read_data <= "00110001";
	code_read_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	code_read_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;

    code_read_mstr_read_data <= "00110000";
	code_read_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	code_read_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;

    code_read_mstr_read_data <= "00110001";
	code_read_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	code_read_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;

    code_read_mstr_read_data <= "00110000";
	code_read_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	code_read_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;

    code_read_mstr_read_data <= "00110000";
	code_read_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	code_read_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;

    code_read_mstr_read_data <= "00110001";
	code_read_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	code_read_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;

    code_read_mstr_read_data <= "00000000";
	code_read_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	code_read_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;

        wait;
    end process;
end architecture test;