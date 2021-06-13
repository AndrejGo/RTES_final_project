library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tree_handler is
    port (
        clk_i         : in  std_logic;
        rst_neg_i     : in  std_logic; -- negated signal

        tree_str_addr_i     : in  std_logic_vector(31 downto 0);
        dst_addr_i          : in  std_logic_vector(31 downto 0);
        write_i             : in  std_logic;
        start_i             : in  std_logic;
        done_o              : out std_logic;
        tree_size_o         : out std_logic_vector(31 downto 0);

        -- Avalon master signals
        tree_mstr_address_o      : out std_logic_vector(31 downto 0);
        tree_mstr_read_o         : out std_logic;
        tree_mstr_read_data_i    : in  std_logic_vector(7 downto 0);
        tree_mstr_write_o        : out std_logic;
        tree_mstr_write_data_o   : out std_logic_vector(7 downto 0);
        tree_mstr_wait_request_i : in  std_logic
    );
end tree_handler;

architecture arch of tree_handler is

    -- Pointer to a C string representing the Huffman encoding
    -- tree that must be included in the file
    signal TreeStrAddr : unsigned(31 downto 0);

    -- Address that the encoded file is to be written to
    signal DstAddr : unsigned(31 downto 0);

    signal Offset : unsigned(31 downto 0);
    signal Char   : std_logic_vector(7 downto 0);

    type state_type is(
        IDLE,
        SET_RD_ADDR, READ_WAIT, CHECK_END,
        SET_WR_ADDR, WRITE_CHAR, WRITE_WAIT, INCREMENT,
        WR_LEN_1, WR_LEN_1_WAIT, WR_LEN_2, WR_LEN_2_WAIT,
        WR_LEN_3, WR_LEN_3_WAIT, WR_LEN_4, WR_LEN_4_WAIT,
        WRITE_WAIT_EXTRA
    );
    signal State : state_type;
begin

    copy_tree: process(clk_i, rst_neg_i)
    begin
        if rst_neg_i = '0' then
            done_o <= '0';
            State <= IDLE;

            tree_mstr_address_o     <= (others => '0');
            tree_mstr_read_o        <= '0';
            tree_mstr_write_o       <= '0';
            tree_mstr_write_data_o  <= (others => '0');
        elsif rising_edge(clk_i) then
            if write_i = '1' then
                TreeStrAddr <= unsigned(tree_str_addr_i);
                DstAddr <= unsigned(dst_addr_i);
                Offset <= (others => '0');
            else
                case State is
                    when IDLE =>
                        if start_i = '1' then
                            State <= SET_RD_ADDR;
                        end if;
                        done_o <= '0';
                    
                    when SET_RD_ADDR =>
                        -- Read a character (1 byte) at mem[TreeStrAddr + Offset]
                        tree_mstr_address_o <= std_logic_vector(TreeStrAddr + Offset);
                        tree_mstr_read_o <= '1';
                        State <= READ_WAIT;

                    when READ_WAIT =>
                        -- Wait for the read to complete
                        if tree_mstr_wait_request_i = '0' then
                            -- Read the 8 bits into a local signal
                            Char <= tree_mstr_read_data_i;
                            tree_mstr_read_o <= '0';
                            State <= CHECK_END;
                        end if;

                    when CHECK_END =>
                        -- Check if we reached the end of the string
                        if Char = "00000000" then
                            State <= WR_LEN_1;
                        else
                            State <= SET_WR_ADDR;
                        end if;

                    when SET_WR_ADDR =>
                        -- Write the character to mem[DstAddr + 12 + Offset]
                        tree_mstr_address_o <= std_logic_vector(DstAddr + 12 + Offset);
                        tree_mstr_write_data_o <= Char;
                        --tree_mstr_write_data_o <= X"ff";
                        tree_mstr_write_o <= '1';
                        State <= WRITE_WAIT_EXTRA;

                    when WRITE_WAIT_EXTRA => 
                        State <= WRITE_WAIT;

                    when WRITE_WAIT =>
                        -- Wait for the write to complete
                        if tree_mstr_wait_request_i = '0' then
                            tree_mstr_write_o <= '0';
                            State <= INCREMENT;
                        end if;

                    when INCREMENT =>
                        -- Increment Offset
                        Offset <= Offset + 1;
                        State <= SET_RD_ADDR;

                    when WR_LEN_1 =>
                        -- Write the length of the tree representation to mem[DstAddr + 4]
                        tree_mstr_address_o <= std_logic_vector(DstAddr + 4);
                        tree_mstr_write_data_o <= std_logic_vector(Offset(7 downto 0));
                        tree_mstr_write_o <= '1';
                        State <= WR_LEN_1_WAIT;

                    when WR_LEN_1_WAIT =>
                        if tree_mstr_wait_request_i = '0' then
                            tree_mstr_write_o <= '0';
                            State <= WR_LEN_2;
                        end if;

                    when WR_LEN_2 =>
                        -- Write the length of the tree representation to mem[DstAddr + 4]
                        tree_mstr_address_o <= std_logic_vector(DstAddr + 5);
                        tree_mstr_write_data_o <= std_logic_vector(Offset(15 downto 8));
                        tree_mstr_write_o <= '1';
                        State <= WR_LEN_2_WAIT;

                    when WR_LEN_2_WAIT =>
                        if tree_mstr_wait_request_i = '0' then
                            tree_mstr_write_o <= '0';
                            State <= WR_LEN_3;
                        end if;

                    when WR_LEN_3 =>
                        -- Write the length of the tree representation to mem[DstAddr + 4]
                        tree_mstr_address_o <= std_logic_vector(DstAddr + 6);
                        tree_mstr_write_data_o <= std_logic_vector(Offset(23 downto 16));
                        tree_mstr_write_o <= '1';
                        State <= WR_LEN_3_WAIT;

                    when WR_LEN_3_WAIT =>
                        if tree_mstr_wait_request_i = '0' then
                            tree_mstr_write_o <= '0';
                            State <= WR_LEN_4;
                        end if;

                    when WR_LEN_4 =>
                        -- Write the length of the tree representation to mem[DstAddr + 4]
                        tree_mstr_address_o <= std_logic_vector(DstAddr + 7);
                        tree_mstr_write_data_o <= std_logic_vector(Offset(31 downto 24));
                        tree_mstr_write_o <= '1';
                        State <= WR_LEN_4_WAIT;

                    when WR_LEN_4_WAIT =>
                        if tree_mstr_wait_request_i = '0' then
                            tree_mstr_write_o <= '0';
                            done_o <= '1';
                            tree_size_o <= std_logic_vector(Offset);
                            State <= IDLE;
                        end if;

                    when others => null;
                end case;
            end if;

        end if;
    end process copy_tree;

end arch;
