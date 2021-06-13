library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity encoder is
    port (
        clk_i         : in  std_logic;
        rst_neg_i     : in  std_logic; -- negated signal

        -- Avalon slave for the processor
        slv_address_i     : in  std_logic_vector(2 downto 0);
        slv_chip_select_i : in  std_logic;
        slv_read_i        : in  std_logic;
        slv_read_data_o   : out std_logic_vector(31 downto 0);
        slv_write_i       : in  std_logic;
        slv_write_data_i  : in  std_logic_vector(31 downto 0);

        -- Avalon master for the SDRAM
        mstr_address_o      : out std_logic_vector(31 downto 0);
        mstr_read_o         : out std_logic;
        mstr_read_data_i    : in  std_logic_vector(7 downto 0);
        mstr_write_o        : out std_logic;
        mstr_write_data_o   : out std_logic_vector(7 downto 0);
        mstr_wait_request_i : in  std_logic
    );
end encoder;

architecture arch of encoder is

    component tree_handler is
    port(
        clk_i                    : in  std_logic;
        rst_neg_i                : in  std_logic; -- negated signal

        tree_str_addr_i          : in  std_logic_vector(31 downto 0);
        dst_addr_i               : in  std_logic_vector(31 downto 0);
        write_i                  : in  std_logic;
        start_i                  : in  std_logic;
        done_o                   : out std_logic;
        tree_size_o              : out std_logic_vector(31 downto 0);

        -- Avalon master signals
        tree_mstr_address_o      : out std_logic_vector(31 downto 0);
        tree_mstr_read_o         : out std_logic;
        tree_mstr_read_data_i    : in  std_logic_vector(7 downto 0);
        tree_mstr_write_o        : out std_logic;
        tree_mstr_write_data_o   : out std_logic_vector(7 downto 0);
        tree_mstr_wait_request_i : in  std_logic
    );
    end component tree_handler;

    signal write_to_tree_handler  : std_logic;
    signal start_tree_handler     : std_logic;
    signal tree_handler_done      : std_logic;
    signal tree_description_size  : std_logic_vector(31 downto 0);
    signal tree_mstr_address      : std_logic_vector(31 downto 0);
    signal tree_mstr_read         : std_logic;
    signal tree_mstr_read_data    : std_logic_vector(7 downto 0);
    signal tree_mstr_write        : std_logic;
    signal tree_mstr_write_data   : std_logic_vector(7 downto 0);
    signal tree_mstr_wait_request : std_logic;

    component text_handler is
        port (
            clk_i         : in  std_logic;
            rst_neg_i     : in  std_logic; -- negated signal
    
            codes_base_addr_i : in  std_logic_vector(31 downto 0);
            text_addr_i       : in  std_logic_vector(31 downto 0);
            dst_addr_i        : in  std_logic_vector(31 downto 0);
            header_size_i     : in  std_logic_vector(31 downto 0);
            write_i           : in  std_logic;
            start_i           : in  std_logic;
            done_o            : out std_logic;
            encoding_size_o   : out std_logic_vector(31 downto 0);

            -- Avalon master signals
            text_mstr_address_o      : out std_logic_vector(31 downto 0);
            text_mstr_read_o         : out std_logic;
            text_mstr_read_data_i    : in  std_logic_vector(7 downto 0);
            text_mstr_write_o        : out std_logic;
            text_mstr_write_data_o   : out std_logic_vector(7 downto 0);
            text_mstr_wait_request_i : in  std_logic
        );
    end component text_handler;

    signal write_to_text_handler  : std_logic;
    signal start_text_handler     : std_logic;
    signal text_handler_done      : std_logic;
    signal text_mstr_address      : std_logic_vector(31 downto 0);
    signal text_mstr_read         : std_logic;
    signal text_mstr_read_data    : std_logic_vector(7 downto 0);
    signal text_mstr_write        : std_logic;
    signal text_mstr_write_data   : std_logic_vector(7 downto 0);
    signal text_mstr_wait_request : std_logic;
    signal encoding_size          : std_logic_vector(31 downto 0);

    signal own_mstr_address      : std_logic_vector(31 downto 0);
    signal own_mstr_read         : std_logic;
    signal own_mstr_read_data    : std_logic_vector(7 downto 0);
    signal own_mstr_write        : std_logic;
    signal own_mstr_write_data   : std_logic_vector(7 downto 0);
    signal own_mstr_wait_request : std_logic;

    -- Pointer to an array of 56 pointers, that point to C trings
    -- representing the encoding of each character in our alphabet
    signal CodesAddr : unsigned(31 downto 0);

    -- Pointer to a C string representing the Huffman encoding
    -- tree that must be included in the file
    signal TreeStrAddr : unsigned(31 downto 0);

    -- Pointer to a C string containing the text that should be
    -- compressed
    signal TextAddr : unsigned(31 downto 0);

    -- Address that the encoded file is to be written to
    signal DstAddr : unsigned(31 downto 0);

    signal TotalSize : unsigned(31 downto 0);

    -- Control register for starting and reseting the encoder
    signal Control : std_logic_vector(31 downto 0);

    signal Status : std_logic_vector(31 downto 0);

    signal reset : std_logic;
    signal start : std_logic;
    signal done  : std_logic;

    type state_type is(
        IDLE, TREE_WR_INPUT, TREE_START, TREE_WAIT, TEXT_WR_INPUT, TEXT_START, TEXT_WAIT,
        WR_TOTAL_LEN_1, WR_TOTAL_LEN_1_WAIT, WR_TOTAL_LEN_2, WR_TOTAL_LEN_2_WAIT,
        WR_TOTAL_LEN_3, WR_TOTAL_LEN_3_WAIT, WR_TOTAL_LEN_4, WR_TOTAL_LEN_4_WAIT
    );
    signal State : state_type;

    type master_mux is(NONE, OWN, TREE, TXT);
    signal MasterMux : master_mux;

begin

    tree_h : tree_handler
    port map(
        clk_i                    => clk_i,
        rst_neg_i                => rst_neg_i,
        tree_str_addr_i          => std_logic_vector(TreeStrAddr),
        dst_addr_i               => std_logic_vector(DstAddr),
        write_i                  => write_to_tree_handler,
        start_i                  => start_tree_handler,
        tree_size_o              => tree_description_size,
        done_o                   => tree_handler_done,
        tree_mstr_address_o      => tree_mstr_address,
        tree_mstr_read_o         => tree_mstr_read,
        tree_mstr_read_data_i    => tree_mstr_read_data,
        tree_mstr_write_o        => tree_mstr_write,
        tree_mstr_write_data_o   => tree_mstr_write_data,
        tree_mstr_wait_request_i => tree_mstr_wait_request
    );

    text_h : text_handler
    port map(
        clk_i                    => clk_i,
        rst_neg_i                => rst_neg_i,
        codes_base_addr_i        => std_logic_vector(CodesAddr),
        text_addr_i              => std_logic_vector(TextAddr),
        dst_addr_i               => std_logic_vector(DstAddr),
        header_size_i            => tree_description_size,
        write_i                  => write_to_text_handler,
        start_i                  => start_text_handler,
        done_o                   => text_handler_done,
        encoding_size_o          => encoding_size,
        text_mstr_address_o      => text_mstr_address,
        text_mstr_read_o         => text_mstr_read,
        text_mstr_read_data_i    => text_mstr_read_data,
        text_mstr_write_o        => text_mstr_write,
        text_mstr_write_data_o   => text_mstr_write_data,
        text_mstr_wait_request_i => text_mstr_wait_request
    );

    -- AVALON SLAVE LOGIC FOR CONTROLING THE ENCODER
    ctrl: process(clk_i, rst_neg_i, done)
    begin
        if rst_neg_i = '0' then
            start <= '0';
            reset <= '1';
            slv_read_data_o <= (others => '0');
        elsif rising_edge(clk_i) then
            start <= '0';
            reset <= '0';
            if slv_chip_select_i = '1' then
                if slv_write_i = '1' then
                    case slv_address_i is
                        when "000" => CodesAddr <= unsigned(slv_write_data_i);
                        when "001" => TreeStrAddr <= unsigned(slv_write_data_i);
                        when "010" => TextAddr <= unsigned(slv_write_data_i);
                        when "011" => DstAddr <= unsigned(slv_write_data_i);
                        when "100" => Control <= slv_write_data_i;
                        when others => null;
                    end case;
                elsif slv_read_i = '1' then
                    case slv_address_i is
                        when "101" => slv_read_data_o <= Status;
                        when others => slv_read_data_o <= (others => '0');
                    end case;
                end if;
            end if;

            if Control(0) = '1' then
                reset <= '1';
                Control(0) <= '0';
            elsif Control(1) = '1' then
                start <= '1';
                Control(1) <= '0';
                Status <= (others => '0');
            end if;

            if reset = '1' then
                Control <= (others => '0');
                Status <= (others => '0');
            end if;

            if done = '1' then
                Status(0) <= '1';
            end if;
        end if;
    end process ctrl;

    -- 
    encode: process(clk_i, rst_neg_i)
    begin
        if rst_neg_i = '0' then
            State <= IDLE;
            write_to_tree_handler <= '0';
            start_tree_handler    <= '0';
            MasterMux <= NONE;
            done <= '0';
        elsif rising_edge(clk_i) then
            if reset = '1' then
                State <= IDLE;
            else
                case State is
                    when IDLE =>
                        if start = '1' then
                            State <= TREE_WR_INPUT;
                        end if;
                        done <= '0';
                    WHEN TREE_WR_INPUT =>
                        write_to_tree_handler <= '1';
                        State <= TREE_START;
                    when TREE_START =>
                        MasterMux <= TREE;
                        write_to_tree_handler <= '0';
                        start_tree_handler <= '1';
                        State <= TREE_WAIT;
                    when TREE_WAIT =>
                        start_tree_handler <= '0';
                        if tree_handler_done = '1' then
                            State <= TEXT_WR_INPUT;
                            MasterMux <= TXT;
                        end if;

                    when TEXT_WR_INPUT =>
                        write_to_text_handler <= '1';
                        State <= TEXT_START;

                    when TEXT_START =>
                        write_to_text_handler <= '0';
                        start_text_handler <= '1';
                        State <= TEXT_WAIT;

                    when TEXT_WAIT =>
                        start_text_handler <= '0';
                        if text_handler_done = '1' then
                            MasterMux <= OWN;
                            State <= WR_TOTAL_LEN_1;
                            TotalSize <= 12 + unsigned(tree_description_size) + unsigned(encoding_size);
                        end if;

                    when WR_TOTAL_LEN_1 =>
                        own_mstr_address <= std_logic_vector(DstAddr);
                        own_mstr_write_data <= std_logic_vector(TotalSize(7 downto 0));
                        own_mstr_write <= '1';
                        State <= WR_TOTAL_LEN_1_WAIT;

                    when WR_TOTAL_LEN_1_WAIT =>
                        if own_mstr_wait_request = '0' then
                            own_mstr_write <= '0';
                            State <= WR_TOTAL_LEN_2;
                        end if;

                    when WR_TOTAL_LEN_2 =>
                        own_mstr_address <= std_logic_vector(DstAddr + 1);
                        own_mstr_write_data <= std_logic_vector(TotalSize(15 downto 8));
                        own_mstr_write <= '1';
                        State <= WR_TOTAL_LEN_2_WAIT;

                    when WR_TOTAL_LEN_2_WAIT =>
                        if own_mstr_wait_request = '0' then
                            own_mstr_write <= '0';
                            State <= WR_TOTAL_LEN_3;
                        end if;

                        when WR_TOTAL_LEN_3 =>
                        own_mstr_address <= std_logic_vector(DstAddr+2);
                        own_mstr_write_data <= std_logic_vector(TotalSize(23 downto 16));
                        own_mstr_write <= '1';
                        State <= WR_TOTAL_LEN_3_WAIT;

                    when WR_TOTAL_LEN_3_WAIT =>
                        if own_mstr_wait_request = '0' then
                            own_mstr_write <= '0';
                            State <= WR_TOTAL_LEN_4;
                        end if;

                        when WR_TOTAL_LEN_4 =>
                        own_mstr_address <= std_logic_vector(DstAddr+3);
                        own_mstr_write_data <= std_logic_vector(TotalSize(31 downto 24));
                        own_mstr_write <= '1';
                        State <= WR_TOTAL_LEN_4_WAIT;

                    when WR_TOTAL_LEN_4_WAIT =>
                        if own_mstr_wait_request = '0' then
                            own_mstr_write <= '0';
                            State <= IDLE;
                            done <= '1';
                            MasterMux <= NONE;
                        end if;

                    when others => null;
                end case;
            end if;
        end if;
    end process encode;

    mux_masters: process(
        MasterMux,
        mstr_read_data_i, mstr_wait_request_i,
        tree_mstr_address, tree_mstr_read, tree_mstr_write_data, tree_mstr_write,
        text_mstr_address, text_mstr_read, text_mstr_write, text_mstr_write_data,
        own_mstr_address, own_mstr_read, own_mstr_write, own_mstr_write_data
    )
    begin
        case MasterMux is
            when NONE =>
                mstr_address_o         <= (others => '0');
                mstr_read_o            <= '0';
                mstr_write_o           <= '0';
                mstr_write_data_o      <= (others => '0');
                
            when OWN =>
                mstr_address_o         <= own_mstr_address;
                mstr_read_o            <= own_mstr_read;
                own_mstr_read_data     <= mstr_read_data_i;
                mstr_write_o           <= own_mstr_write;
                mstr_write_data_o      <= own_mstr_write_data;
                own_mstr_wait_request  <= mstr_wait_request_i;

            when TREE =>
                mstr_address_o         <= tree_mstr_address;
                mstr_read_o            <= tree_mstr_read;
                tree_mstr_read_data    <= mstr_read_data_i;
                mstr_write_o           <= tree_mstr_write;
                mstr_write_data_o      <= tree_mstr_write_data;
                tree_mstr_wait_request <= mstr_wait_request_i;

            when TXT =>
                mstr_address_o         <= text_mstr_address;
                mstr_read_o            <= text_mstr_read;
                text_mstr_read_data    <= mstr_read_data_i;
                mstr_write_o           <= text_mstr_write;
                mstr_write_data_o      <= text_mstr_write_data;
                text_mstr_wait_request <= mstr_wait_request_i;
            when others => null;
        end case;
    end process mux_masters;
    
end arch;