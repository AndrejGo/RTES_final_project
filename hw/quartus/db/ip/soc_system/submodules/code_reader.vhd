library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity code_reader is
    port (
        clk_i         : in  std_logic;
        rst_neg_i     : in  std_logic; -- negated signal

        -- Address of address of the code
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
end code_reader;

architecture arch of code_reader is

    signal Addr     : unsigned(31 downto 0);
    signal CodeAddr : std_logic_vector(31 downto 0);
    signal Offset   : unsigned(31 downto 0);
    signal CodeReg  : std_logic_vector(63 downto 0);

    type state_type is(
        IDLE,
        RD_CODE_ADDR_1, RD_CODE_ADDR_1_WAIT, RD_CODE_ADDR_2, RD_CODE_ADDR_2_WAIT,
        RD_CODE_ADDR_3, RD_CODE_ADDR_3_WAIT, RD_CODE_ADDR_4, RD_CODE_ADDR_4_WAIT,
        SET_RD_ADDR, READ_WAIT, INCREMENT, LAST
    );
    signal State : state_type;
begin

    read_code: process(clk_i, rst_neg_i)
    begin
        if rst_neg_i = '0' then
            done_o <= '0';
            State <= IDLE;

            CodeReg <= (others => '0');

            code_read_mstr_address_o     <= (others => '0');
            code_read_mstr_read_o        <= '0';
            code_read_mstr_write_o       <= '0';
            code_read_mstr_write_data_o  <= (others => '0');
        elsif rising_edge(clk_i) then
            case State is
                when IDLE =>
                    if start_i = '1' then
                        Addr <= unsigned(code_addr_i);
                        Offset <= (others => '0');
                        State <= RD_CODE_ADDR_1;
                    else
                        done_o <= '0';
                        CodeReg <= (others => '0');
                        code_read_mstr_address_o     <= (others => '0');
                        code_read_mstr_read_o        <= '0';
                        code_read_mstr_write_o       <= '0';
                        code_read_mstr_write_data_o  <= (others => '0');
                    end if;
                
                when RD_CODE_ADDR_1 =>
                    code_read_mstr_address_o <= std_logic_vector(Addr);
                    code_read_mstr_read_o <= '1';
                    State <= RD_CODE_ADDR_1_WAIT;

                when RD_CODE_ADDR_1_WAIT =>
                    if code_read_mstr_wait_request_i = '0' then
                        CodeAddr(7 downto 0) <= code_read_mstr_read_data_i;
                        code_read_mstr_read_o <= '0';
                        State <= RD_CODE_ADDR_2;
                    end if;

                when RD_CODE_ADDR_2 =>
                    code_read_mstr_address_o <= std_logic_vector(Addr + 1);
                    code_read_mstr_read_o <= '1';
                    State <= RD_CODE_ADDR_2_WAIT;

                when RD_CODE_ADDR_2_WAIT =>
                    if code_read_mstr_wait_request_i = '0' then
                        CodeAddr(15 downto 8) <= code_read_mstr_read_data_i;
                        code_read_mstr_read_o <= '0';
                        State <= RD_CODE_ADDR_3;
                    end if;

                when RD_CODE_ADDR_3 =>
                    code_read_mstr_address_o <= std_logic_vector(Addr + 2);
                    code_read_mstr_read_o <= '1';
                    State <= RD_CODE_ADDR_3_WAIT;

                when RD_CODE_ADDR_3_WAIT =>
                    if code_read_mstr_wait_request_i = '0' then
                        CodeAddr(23 downto 16) <= code_read_mstr_read_data_i;
                        code_read_mstr_read_o <= '0';
                        State <= RD_CODE_ADDR_4;
                    end if;

                when RD_CODE_ADDR_4 =>
                    code_read_mstr_address_o <= std_logic_vector(Addr + 3);
                    code_read_mstr_read_o <= '1';
                    State <= RD_CODE_ADDR_4_WAIT;

                when RD_CODE_ADDR_4_WAIT =>
                    if code_read_mstr_wait_request_i = '0' then
                        CodeAddr(31 downto 24) <= code_read_mstr_read_data_i;
                        code_read_mstr_read_o <= '0';
                        State <= SET_RD_ADDR;
                    end if;
                    
                when SET_RD_ADDR =>
                    -- Read a character (1 byte)
                    code_read_mstr_address_o <= std_logic_vector(unsigned(CodeAddr) + Offset);
                    code_read_mstr_read_o <= '1';
                    State <= READ_WAIT;

                when READ_WAIT =>
                    -- Wait for the read to complete
                    if code_read_mstr_wait_request_i = '0' then
                        code_read_mstr_read_o <= '0';
                        -- Read the 8 bits into a local signal
                        if code_read_mstr_read_data_i = "00110000" then
                            CodeReg(63 - to_integer(Offset)) <= '0';
                            Offset <= Offset + 1;
                            State <= SET_RD_ADDR;
                        elsif code_read_mstr_read_data_i = "00110001" then
                            CodeReg(63 - to_integer(Offset)) <= '1';
                            Offset <= Offset + 1;
                            State <= SET_RD_ADDR;
                        else
                            State <= LAST;
                        end if;
                    end if;

                when LAST =>
                    length_o <= std_logic_vector(Offset(5 downto 0));
                    bit_rep_o <= CodeReg;
                    done_o <= '1';
                    State <= IDLE;

                when others => null;
            end case;

        end if;
    end process read_code;

end arch;
