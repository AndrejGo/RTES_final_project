library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_encoder is
end tb_encoder;

architecture test of tb_encoder is

    signal clk         : std_logic;
    signal rst_neg     : std_logic; -- negated signal

    -- Avalon slave for the processor
    signal slv_address     : std_logic_vector(2 downto 0);
    signal slv_chip_select : std_logic;
    signal slv_read        : std_logic;
    signal slv_read_data   : std_logic_vector(31 downto 0);
    signal slv_write       : std_logic;
    signal slv_write_data  : std_logic_vector(31 downto 0);
    signal slv_irq         : std_logic;

    -- Avalon master for the SDRAM
    signal mstr_address      : std_logic_vector(31 downto 0);
    signal mstr_read         : std_logic;
    signal mstr_read_data    : std_logic_vector(7 downto 0);
    signal mstr_write        : std_logic;
    signal mstr_write_data   : std_logic_vector(7 downto 0);
    signal mstr_wait_request : std_logic;

    constant clk_period : time := 100 ps;

begin

    dut : entity work.encoder
    port map (
        clk_i               => clk,
        rst_neg_i           => rst_neg,
        slv_address_i       => slv_address,
        slv_chip_select_i   => slv_chip_select,
        slv_read_i          => slv_read,
        slv_read_data_o     => slv_read_data,
        slv_write_i         => slv_write,
        slv_write_data_i    => slv_write_data,
        slv_irq_o           => slv_irq,
        mstr_address_o      => mstr_address,
        mstr_read_o         => mstr_read,
        mstr_read_data_i    => mstr_read_data,
        mstr_write_o        => mstr_write,
        mstr_write_data_o   => mstr_write_data,
        mstr_wait_request_i => mstr_wait_request
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

        -- Write addresses into the encoder
        slv_chip_select <= '1';

        -- Codes address
        slv_address <= "000";
        slv_write_data <= X"00001100";
        slv_write <= '1';
        wait for 1 * clk_period;
        slv_write <= '0';
        wait for 1 * clk_period;

        -- Tree string address
        slv_address <= "001";
        slv_write_data <= X"ff000000";
        slv_write <= '1';
        wait for 1 * clk_period;
        slv_write <= '0';
        wait for 1 * clk_period;

        -- Text address
        slv_address <= "010";
        slv_write_data <= X"0000aa00";
        slv_write <= '1';
        wait for 1 * clk_period;
        slv_write <= '0';
        wait for 1 * clk_period;

        -- Destination address
        slv_address <= "011";
        slv_write_data <= X"00000000";
        slv_write <= '1';
        wait for 1 * clk_period;
        slv_write <= '0';
        wait for 1 * clk_period;

        -- Start the encoder
        slv_address <= "100";
        slv_write_data <= "00000000000000000000000000000010";
        slv_write <= '1';
        wait for 1 * clk_period;
        slv_write <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';

        wait for 10 * clk_period;

        -- ////////////////////////////////////////////////////////////////////////////////
        -- ////////////////////////////////////////////////////////////////////////////////
        -- The encoder first employs the tree handler, which starts copying the string
        -- representation of the tree from the source to the destination

        -- 0
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 1
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 2
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 3
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 4
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 5
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 6
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 7
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 8
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 9
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 10
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 11
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 12
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 13
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 14
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- 15
        mstr_read_data <= X"30"; -- '0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"31"; -- '1'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        ------------------------
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_read_data <= X"00"; -- '\0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- After copying the tree string, the tree handler will write the length
        -- of the string at destination address + 4
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;
        
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        -- The tree handler is now finished

        -- ////////////////////////////////////////////////////////////////////////////////
        -- ////////////////////////////////////////////////////////////////////////////////
        -- The text handler starts by reading a character from the source address
        mstr_read_data <= X"41"; -- 'A'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;
        -- Then, it begins to read the address of the code string
        mstr_read_data <= X"00";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"00";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"11";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"10";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        -- Then, it begins to read the actual code string at address 0x00001110
        mstr_read_data <= X"30";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"30";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"31";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"00";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        -- The code writer will do nothing, since it has only 3 bits

        -- ////////////////////////////////////////////////////////////////////////////////
        -- ////////////////////////////////////////////////////////////////////////////////
        -- The text handler continues by reading a character from the source address
        mstr_read_data <= X"42"; -- 'B'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;
        -- Then, it begins to read the address of the code string
        mstr_read_data <= X"00";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"00";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"11";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"20";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        -- Then, it begins to read the actual code string at address 0x00001110
        mstr_read_data <= X"31";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"31";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"31";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"00";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        -- The code writer will do nothing, since it has only 6 bits

        -- ////////////////////////////////////////////////////////////////////////////////
        -- ////////////////////////////////////////////////////////////////////////////////
        -- The text handler continues by reading a character from the source address
        mstr_read_data <= X"43"; -- 'C'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;
        -- Then, it begins to read the address of the code string
        mstr_read_data <= X"00";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"00";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"11";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"30";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        -- Then, it begins to read the actual code string at address 0x00001110
        mstr_read_data <= X"30";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"31";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"30";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"31";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;
        mstr_read_data <= X"30";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"31";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        mstr_read_data <= X"00";
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        -- The code writer will write 001 111 01 to Destination + 12 + 6 = 0x12

        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        -- ////////////////////////////////////////////////////////////////////////////////
        -- ////////////////////////////////////////////////////////////////////////////////
        -- Now, the text handler reaches the end of the string
        mstr_read_data <= X"00"; -- '\0'
        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;
        
        -- It adds a padding byte to the encoding and writes 0101 0000 to Destination + 12 + 6 + 1 = 0x13

        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 10 * clk_period;

        -- ////////////////////////////////////////////////////////////////////////////////
        -- ////////////////////////////////////////////////////////////////////////////////
        -- The text writer finishes by writing the length 3 to Destination + 8

        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        -- ////////////////////////////////////////////////////////////////////////////////
        -- ////////////////////////////////////////////////////////////////////////////////
        -- The encoder finishes by writing the length 12 + 6 + 2 = 20 to Destination

        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        mstr_wait_request <= '0';
        wait for 1 * clk_period;
        mstr_wait_request <= '1';
        wait for 4 * clk_period;

        wait;
    end process;
end architecture test;