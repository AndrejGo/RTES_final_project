library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity text_handler is
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
end text_handler;

architecture arch of text_handler is

    -- TEXT HANDLER MULTIPLEXING SIGNALS
    signal text_mstr_address      : std_logic_vector(31 downto 0);
    signal text_mstr_read         : std_logic;
    signal text_mstr_read_data    : std_logic_vector(7 downto 0);
    signal text_mstr_write        : std_logic;
    signal text_mstr_write_data   : std_logic_vector(7 downto 0);
    signal text_mstr_wait_request : std_logic;

    component letter_indexer is
        port (
            letter_i : in  std_logic_vector(7 downto 0);
            index_o  : out std_logic_vector(5 downto 0)
        );
    end component letter_indexer;

    component code_reader is
        port (
            clk_i         : in  std_logic;
            rst_neg_i     : in  std_logic; -- negated signal
    
            code_addr_i : in  std_logic_vector(31 downto 0);
            start_i     : in  std_logic;
    
            done_o      : out std_logic;
            length_o    : out std_logic_vector(5 downto 0);
            bit_rep_o   : out std_logic_vector(63 downto 0);

            -- Avalon master signals
            code_read_mstr_address_o      : out std_logic_vector(31 downto 0);
            code_read_mstr_read_o         : out std_logic;
            code_read_mstr_read_data_i    : in  std_logic_vector(7 downto 0);
            code_read_mstr_write_o        : out std_logic;
            code_read_mstr_write_data_o   : out std_logic_vector(7 downto 0);
            code_read_mstr_wait_request_i : in  std_logic
        );
    end component code_reader;

    -- CODE_READER signals
    signal Char                        : std_logic_vector(7 downto 0);
    signal CodeIndex                   : std_logic_vector(5 downto 0);
    signal StartCodeReader             : std_logic;
    signal CodeReaderDone              : std_logic;
    signal CodeLength                  : std_logic_vector(5 downto 0);
    signal CodeRepresentation          : std_logic_vector(63 downto 0);
    signal code_read_mstr_address      : std_logic_vector(31 downto 0);
    signal code_read_mstr_read         : std_logic;
    signal code_read_mstr_read_data    : std_logic_vector(7 downto 0);
    signal code_read_mstr_write        : std_logic;
    signal code_read_mstr_write_data   : std_logic_vector(7 downto 0);
    signal code_read_mstr_wait_request : std_logic;

    component code_writer is
        port (
            clk_i         : in  std_logic;
            rst_neg_i     : in  std_logic; -- negated signal
    
            dst_addr_i : in  std_logic_vector(31 downto 0);
            code_i     : in  std_logic_vector(63 downto 0);
            code_len_i : in  std_logic_vector(5 downto 0);
            write_i    : in  std_logic;
            start_i    : in  std_logic;
    
            done_o      : out std_logic;
            encoding_size_o   : out std_logic_vector(31 downto 0);

            -- Avalon master signals
            code_write_mstr_address_o      : out std_logic_vector(31 downto 0);
            code_write_mstr_read_o         : out std_logic;
            code_write_mstr_read_data_i    : in  std_logic_vector(7 downto 0);
            code_write_mstr_write_o        : out std_logic;
            code_write_mstr_write_data_o   : out std_logic_vector(7 downto 0);
            code_write_mstr_wait_request_i : in  std_logic
        );
    end component code_writer;

    -- CODE_WRITER signals
    signal CodeWriterDst               : std_logic_vector(31 downto 0);
    signal WriteCodeWriter             : std_logic;
    signal StartCodeWriter             : std_logic;
    signal CodeWriterDone              : std_logic;
    signal WrCodeLength                 : std_logic_vector(5 downto 0);
    signal WrCodeRepresentation         : std_logic_vector(63 downto 0);
    signal code_write_mstr_address      : std_logic_vector(31 downto 0);
    signal code_write_mstr_read         : std_logic;
    signal code_write_mstr_read_data    : std_logic_vector(7 downto 0);
    signal code_write_mstr_write        : std_logic;
    signal code_write_mstr_write_data   : std_logic_vector(7 downto 0);
    signal code_write_mstr_wait_request : std_logic;

    -- Pointer to an array of 56 pointers that point to
    -- C strings representing the bits used to encode
    -- characters
    signal CodesBaseAddr : unsigned(31 downto 0);

    -- LETTER_INDEXER signals
    signal CurrCodeAddr  : std_logic_vector(31 downto 0);

    -- OTHER SIGNALS
    -- Source address of the text to be encoded
    signal TextAddr : unsigned(31 downto 0);
    -- Offset for the text address
    signal TextOffset    : unsigned(31 downto 0);
    -- Address that the encoded file is to be written to
    signal DstAddr : unsigned(31 downto 0);
    -- Size of header in the output file
    signal HeaderSize : unsigned(31 downto 0);

    type state_type is(
        IDLE,
        SET_RD_ADDR, READ_WAIT, CHECK_END,
        READ_CODE, READ_CODE_START, READ_CODE_WAIT, WRITE_CODE, WRITE_CODE_WAIT,
        ADD_PADDING, WAIT_PADDING,
        WR_LEN_1, WR_LEN_1_WAIT, WR_LEN_2, WR_LEN_2_WAIT, WR_LEN_3, WR_LEN_3_WAIT, WR_LEN_4, WR_LEN_4_WAIT
    );
    signal State : state_type;

    type master_mux is(NONE, TEXT_HANDLER, CODE_RD, CODE_WR);
    signal MasterMux : master_mux;
begin

    li : letter_indexer
    port map(
        letter_i => std_logic_vector(Char),
        index_o  => CodeIndex
    );

    cr : code_reader
    port map(
        clk_i                         => clk_i,
        rst_neg_i                     => rst_neg_i,
        code_addr_i                   => CurrCodeAddr,
        start_i                       => StartCodeReader,
        done_o                        => CodeReaderDone,
        length_o                      => CodeLength,
        bit_rep_o                     => CodeRepresentation,
        code_read_mstr_address_o      => code_read_mstr_address,
        code_read_mstr_read_o         => code_read_mstr_read,
        code_read_mstr_read_data_i    => code_read_mstr_read_data,
        code_read_mstr_write_o        => code_read_mstr_write,
        code_read_mstr_write_data_o   => code_read_mstr_write_data,
        code_read_mstr_wait_request_i => code_read_mstr_wait_request
    );

    cw : code_writer
    port map(
        clk_i                          => clk_i,
        rst_neg_i                      => rst_neg_i,
        dst_addr_i                     => CodeWriterDst,
        code_i                         => WrCodeRepresentation,
        code_len_i                     => WrCodeLength,
        write_i                        => WriteCodeWriter,
        start_i                        => StartCodeWriter,
        done_o                         => CodeWriterDone,
        encoding_size_o                => encoding_size_o,
        code_write_mstr_address_o      => code_write_mstr_address,
        code_write_mstr_read_o         => code_write_mstr_read,
        code_write_mstr_read_data_i    => code_write_mstr_read_data,
        code_write_mstr_write_o        => code_write_mstr_write,
        code_write_mstr_write_data_o   => code_write_mstr_write_data,
        code_write_mstr_wait_request_i => code_write_mstr_wait_request
    );

    encode_text: process(clk_i, rst_neg_i)
    begin
        if rst_neg_i = '0' then
            done_o <= '0';
            State <= IDLE;
            MasterMux <= NONE;

            text_mstr_address    <= (others => '0');
            text_mstr_read       <= '0';
            text_mstr_write      <= '0';
            text_mstr_write_data <= (others => '0');

            StartCodeReader <= '0';
            WriteCodeWriter <= '0';
            StartCodeWriter <= '0';
        elsif rising_edge(clk_i) then
            if write_i = '1' then
                CodesBaseAddr <= unsigned(codes_base_addr_i);
                TextAddr      <= unsigned(text_addr_i);
                DstAddr       <= unsigned(dst_addr_i);
                TextOffset    <= (others => '0');
                CurrCodeAddr  <= (others => '0');
                HeaderSize    <= unsigned(header_size_i);
            else
                case State is
                    when IDLE =>
                        if start_i = '1' then
                            State <= SET_RD_ADDR;
                            MasterMux <= TEXT_HANDLER;

                            -- Initialize CodeWriter
                            CodeWriterDst <= std_logic_vector(DstAddr + 12 + HeaderSize);
                            WriteCodeWriter <= '1'; 
                        else
                            done_o <= '0';
                            StartCodeReader <= '0';
                            WriteCodeWriter <= '0';
                            StartCodeWriter <= '0';
                        end if;
                    
                    -- READ A CHARACTER FROM THE TEXT
                    when SET_RD_ADDR =>
                        text_mstr_address <= std_logic_vector(TextAddr + TextOffset);
                        text_mstr_read <= '1';
                        WriteCodeWriter <= '0';
                        State <= READ_WAIT;

                    when READ_WAIT =>
                        -- Wait for the read to complete
                        if text_mstr_wait_request = '0' then
                            -- Read the 8 bits into a local signal
                            Char <= text_mstr_read_data;
                            text_mstr_read <= '0';
                            State <= CHECK_END;
                        end if;

                    -- CHECK IF THE CHARACTER IS '\0'
                    when CHECK_END =>
                        -- Check if we reached the end of the string
                        if Char = "00000000" then
                            State <= ADD_PADDING;
                        else
                            TextOffset <= TextOffset + 1;
                            State <= READ_CODE;
                            MasterMux <= CODE_RD;
                        end if;

                    -- PASS CODE_READER THE ADDRESS OF THE ADDRESS OF THE CODE
                    -- At this point, leter_indexer already calculated the index
                    when READ_CODE =>
                        CurrCodeAddr <= std_logic_vector(CodesBaseAddr + unsigned(CodeIndex)*4);
                        State <= READ_CODE_START;

                    when READ_CODE_START =>
                        StartCodeReader <= '1';
                        State <= READ_CODE_WAIT;

                    when READ_CODE_WAIT =>
                        if CodeReaderDone = '1' then
                            State <= WRITE_CODE;
                            MasterMux <= CODE_WR;
                            WrCodeRepresentation <= CodeRepresentation;
                            WrCodeLength <= CodeLength;
                        end if;
                        StartCodeReader <= '0';
                    
                    when WRITE_CODE =>
                        StartCodeWriter <= '1';
                        State <= WRITE_CODE_WAIT;

                    when WRITE_CODE_WAIT =>
                        StartCodeWriter <= '0';
                        if CodeWriterDone = '1' then
                            State <= SET_RD_ADDR;
                            MasterMux <= TEXT_HANDLER;
                        end if;
                        
                    when ADD_PADDING =>
                        WrCodeRepresentation <= (others => '0');
                        WrCodeLength <= "001000";
                        StartCodeWriter <= '1';
                        MasterMux <= CODE_WR;
                        State <= WAIT_PADDING;

                    when WAIT_PADDING =>
                        StartCodeWriter <= '0';
                        if CodeWriterDone = '1' then
                            State <= WR_LEN_1;
                            MasterMux <= TEXT_HANDLER;
                        end if;

                    when WR_LEN_1 =>
                        -- Write the length of the uncompressed text to mem[DstAddr + 8]
                        text_mstr_address <= std_logic_vector(DstAddr + 8);
                        text_mstr_write_data <= std_logic_vector(TextOffset(7 downto 0));
                        text_mstr_write <= '1';
                        State <= WR_LEN_1_WAIT;

                    when WR_LEN_1_WAIT =>
                        if text_mstr_wait_request = '0' then
                            text_mstr_write <= '0';
                            State <= WR_LEN_2;
                        end if;

                    when WR_LEN_2 =>
                        -- Write the length of the uncompressed text to mem[DstAddr + 8]
                        text_mstr_address <= std_logic_vector(DstAddr + 9);
                        text_mstr_write_data <= std_logic_vector(TextOffset(15 downto 8));
                        text_mstr_write <= '1';
                        State <= WR_LEN_2_WAIT;

                    when WR_LEN_2_WAIT =>
                        if text_mstr_wait_request = '0' then
                            text_mstr_write <= '0';
                            State <= WR_LEN_3;
                        end if;

                    when WR_LEN_3 =>
                        -- Write the length of the uncompressed text to mem[DstAddr + 8]
                        text_mstr_address <= std_logic_vector(DstAddr + 10);
                        text_mstr_write_data <= std_logic_vector(TextOffset(23 downto 16));
                        text_mstr_write <= '1';
                        State <= WR_LEN_3_WAIT;

                    when WR_LEN_3_WAIT =>
                        if text_mstr_wait_request = '0' then
                            text_mstr_write <= '0';
                            State <= WR_LEN_4;
                        end if;

                    when WR_LEN_4 =>
                        -- Write the length of the uncompressed text to mem[DstAddr + 8]
                        text_mstr_address <= std_logic_vector(DstAddr + 11);
                        text_mstr_write_data <= std_logic_vector(TextOffset(31 downto 24));
                        text_mstr_write <= '1';
                        State <= WR_LEN_4_WAIT;

                    when WR_LEN_4_WAIT =>
                        if text_mstr_wait_request = '0' then
                            text_mstr_write <= '0';
                            done_o <= '1';
                            State <= IDLE;
                        end if;

                    when others => null;
                end case;
            end if;

        end if;
    end process encode_text;

    mux_masters: process(
        text_mstr_address, text_mstr_read, text_mstr_read_data_i, text_mstr_write, text_mstr_write_data, text_mstr_wait_request_i,
        code_read_mstr_address, code_read_mstr_read, code_read_mstr_write, code_read_mstr_write_data,
        code_write_mstr_address, code_write_mstr_read, code_write_mstr_write, code_write_mstr_write_data
    )
    begin
        case MasterMux is
            when NONE =>
                text_mstr_address_o    <= (others => '0');
                text_mstr_read_o       <= '0';
                text_mstr_write_o      <= '0';
                text_mstr_write_data_o <= (others => '0');

            when TEXT_HANDLER =>
                text_mstr_address_o        <= text_mstr_address;
                text_mstr_read_o           <= text_mstr_read;
                text_mstr_read_data        <= text_mstr_read_data_i;
                text_mstr_write_o          <= text_mstr_write;
                text_mstr_write_data_o     <= text_mstr_write_data;
                text_mstr_wait_request     <= text_mstr_wait_request_i;

            when CODE_RD =>
                text_mstr_address_o         <= code_read_mstr_address;
                text_mstr_read_o            <= code_read_mstr_read;
                code_read_mstr_read_data    <= text_mstr_read_data_i;
                text_mstr_write_o           <= code_read_mstr_write;
                text_mstr_write_data_o      <= code_read_mstr_write_data;
                code_read_mstr_wait_request <= text_mstr_wait_request_i;

            when CODE_WR =>
                text_mstr_address_o         <= code_write_mstr_address;
                text_mstr_read_o            <= code_write_mstr_read;
                code_write_mstr_read_data    <= text_mstr_read_data_i;
                text_mstr_write_o           <= code_write_mstr_write;
                text_mstr_write_data_o      <= code_write_mstr_write_data;
                code_write_mstr_wait_request <= text_mstr_wait_request_i;

            when others => null;
        end case;
    end process mux_masters;

end arch;
