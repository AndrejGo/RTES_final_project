library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity code_writer is
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
end code_writer;

architecture arch of code_writer is

    signal Code       : std_logic_vector(63 downto 0);
    signal CodeLen    : unsigned(5 downto 0);
    signal WIP_Reg    : std_logic_vector(63 downto 0);
    signal WIP_Idx    : integer;
    signal DstAddr   : unsigned(31 downto 0);
    signal DstOffset : unsigned(31 downto 0);

    type state_type is(
        IDLE,
        ADD_CODE, WRITE_CODE, WRITE_CODE_WAIT, DONE,
        WRITE_CODE_EXTRA_1
    );
    signal State : state_type;
begin

    read_code: process(clk_i, rst_neg_i)
    begin
        if rst_neg_i = '0' then
            done_o <= '0';
            State <= IDLE;

            WIP_Reg <= (others => '0');
            WIP_Idx <= 63;

            code_write_mstr_address_o     <= (others => '0');
            code_write_mstr_read_o        <= '0';
            code_write_mstr_write_o       <= '0';
            code_write_mstr_write_data_o  <= (others => '0');

            encoding_size_o <= (others => '0');
        elsif rising_edge(clk_i) then
            case State is
                when IDLE =>
                    if write_i = '1' then
                        DstAddr <= unsigned(dst_addr_i);
                        DstOffset <= (others => '0');
                        WIP_Reg <= (others => '0');
                        WIP_Idx <= 63;
                    elsif start_i = '1' then
                        Code <= code_i;
                        CodeLen <= unsigned(code_len_i);
                        State <= ADD_CODE;
                    else
                        done_o <= '0';
                        code_write_mstr_address_o     <= (others => '0');
                        code_write_mstr_read_o        <= '0';
                        code_write_mstr_write_o       <= '0';
                        code_write_mstr_write_data_o  <= (others => '0');
                    end if;
                
                when ADD_CODE =>
                    for i in 0 to 63 loop

                        if i < to_integer(CodeLen) then
                            WIP_Reg(WIP_Idx - i) <= Code(63 - i);
                        end if;
                        
                    end loop;
                    WIP_Idx <= WIP_Idx - to_integer(CodeLen);
                    State <= WRITE_CODE;

                when WRITE_CODE =>
                    -- Check if we have at least 8 bits
                    if WIP_Idx < 56 then
                        code_write_mstr_address_o <= std_logic_vector(DstAddr + DstOffset);
                        code_write_mstr_write_data_o <= WIP_Reg(63 downto 56);
                        code_write_mstr_write_o <= '1';
                        State <= WRITE_CODE_EXTRA_1;
                    else
                        State <= DONE;
                    end if;

                when WRITE_CODE_EXTRA_1 =>
                    State <= WRITE_CODE_WAIT;

                when WRITE_CODE_WAIT =>
                    if code_write_mstr_wait_request_i = '0' then
                        code_write_mstr_write_o <= '0';
                        DstOffset <= DstOffset + 1;
                        -- Shift bits by 8
                        for i in WIP_Reg'high downto WIP_Reg'low + 8 loop
                            WIP_Reg(i) <= WIP_Reg(i-8);
                        end loop;
                        -- Increment Index
                        WIP_Idx <= WIP_Idx + 8;
                        State <= WRITE_CODE;
                    end if;

                when DONE =>
                    encoding_size_o <= std_logic_vector(DstOffset);
                    done_o <= '1';
                    State <= IDLE;

                when others => null;
            end case;

        end if;
    end process read_code;

end arch;
