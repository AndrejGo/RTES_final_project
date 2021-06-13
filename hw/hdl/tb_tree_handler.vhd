library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_tree_handler is
end tb_tree_handler;

architecture test of tb_tree_handler is

    signal clk                    : std_logic;
    signal rst_neg                : std_logic;

    signal tree_str_addr          : std_logic_vector(31 downto 0);
    signal dst_addr               : std_logic_vector(31 downto 0);
    signal wr                     : std_logic;
    signal start                  : std_logic;
    signal done                   : std_logic;

    signal tree_mstr_address      : std_logic_vector(31 downto 0);
    signal tree_mstr_read         : std_logic;
    signal tree_mstr_read_data    : std_logic_vector(7 downto 0);
    signal tree_mstr_write        : std_logic;
    signal tree_mstr_write_data   : std_logic_vector(7 downto 0);
    signal tree_mstr_wait_request : std_logic;

    constant clk_period : time := 100 ps;

begin

    dut : entity work.tree_handler
    port map (
        clk_i                    => clk,
        rst_neg_i                => rst_neg,
        tree_str_addr_i          => tree_str_addr,
        dst_addr_i               => dst_addr,
        write_i                  => wr,
        start_i                  => start,
        done_o                   => done,
        tree_mstr_address_o      => tree_mstr_address,
        tree_mstr_read_o         => tree_mstr_read,
        tree_mstr_read_data_i    => tree_mstr_read_data,
        tree_mstr_write_o        => tree_mstr_write,
        tree_mstr_write_data_o   => tree_mstr_write_data,
        tree_mstr_wait_request_i => tree_mstr_wait_request
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

	-- SET INPUT DATA
	tree_str_addr <= "00000000000000001000000010000000";
	dst_addr <= "00000000000000000000000011110000";
	wr <= '1';
	wait for 1 * clk_period;
	wr <= '0';
	wait for 2 * clk_period;

        -- START
	start <= '1';
	tree_mstr_wait_request <= '1';
	wait for 1 * clk_period;
	start <= '0';

	-- Simulate waiting for read
	wait for 10 * clk_period;
	
	tree_mstr_read_data <= "01000001";
	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';
	tree_mstr_read_data <= "01000010";

	-- Simulate waiting for read
	wait for 7 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	-- Simulate waiting for write
	wait for 4 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	tree_mstr_read_data <= "00000000";
	-- Simulate waiting for read
	wait for 7 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	-- Simulate waiting for write
	wait for 4 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	-- Simulate waiting for write
	wait for 4 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	-- Simulate waiting for write
	wait for 4 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	-- Simulate waiting for write
	wait for 4 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	-------------------------------------------------------

	-- SET INPUT DATA
	tree_str_addr <= "00000000000000001000000010000000";
	dst_addr <= "00000000000000000000000011110000";
	wr <= '1';
	wait for 1 * clk_period;
	wr <= '0';
	wait for 2 * clk_period;

        -- START
	start <= '1';
	tree_mstr_wait_request <= '1';
	wait for 1 * clk_period;
	start <= '0';

	-- Simulate waiting for read
	wait for 10 * clk_period;
	
	tree_mstr_read_data <= "01000001";
	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';
	-- Simulate waiting for write
	wait for 5 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';
	tree_mstr_read_data <= "01000010";

	-- Simulate waiting for read
	wait for 7 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	-- Simulate waiting for write
	wait for 4 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	tree_mstr_read_data <= "00000000";
	-- Simulate waiting for read
	wait for 7 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	-- Simulate waiting for write
	wait for 4 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	-- Simulate waiting for write
	wait for 4 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	-- Simulate waiting for write
	wait for 4 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

	-- Simulate waiting for write
	wait for 4 * clk_period;

	tree_mstr_wait_request <= '0';
	wait for 1 * clk_period;
	tree_mstr_wait_request <= '1';

        wait;
    end process;







end architecture test;