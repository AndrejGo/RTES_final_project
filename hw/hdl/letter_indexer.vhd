library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity letter_indexer is
    port (
        letter_i : in  std_logic_vector(7 downto 0);
        index_o  : out std_logic_vector(5 downto 0)
    );
end letter_indexer;

-- 56 allowed letters
--char letters[] = {
--    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
--    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
--    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
--    'Y', 'Z', 
--    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
--    'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
--    'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
--    'y', 'z', 
--    ' ', ',', '.', '\n'
--};

architecture arch of letter_indexer is

begin
    proc: process(letter_i)
    begin
        case letter_i is
            when X"41" => index_o <= "000000"; -- A
            when X"42" => index_o <= "000001"; -- B
            when X"43" => index_o <= "000010"; -- C
            when X"44" => index_o <= "000011"; -- D
            when X"45" => index_o <= "000100"; -- E
            when X"46" => index_o <= "000101"; -- F
            when X"47" => index_o <= "000110"; -- G
            when X"48" => index_o <= "000111"; -- H
            when X"49" => index_o <= "001000"; -- I
            when X"4a" => index_o <= "001001"; -- J
            when X"4b" => index_o <= "001010"; -- K
            when X"4c" => index_o <= "001011"; -- L
            when X"4d" => index_o <= "001100"; -- M
            when X"4e" => index_o <= "001101"; -- N
            when X"4f" => index_o <= "001110"; -- O
            when X"50" => index_o <= "001111"; -- P
            when X"51" => index_o <= "010000"; -- Q
            when X"52" => index_o <= "010001"; -- R
            when X"53" => index_o <= "010010"; -- S
            when X"54" => index_o <= "010011"; -- T
            when X"55" => index_o <= "010100"; -- U
            when X"56" => index_o <= "010101"; -- V
            when X"57" => index_o <= "010110"; -- W
            when X"58" => index_o <= "010111"; -- X
            when X"59" => index_o <= "011000"; -- Y
            when X"5a" => index_o <= "011001"; -- Z
            when X"61" => index_o <= "011010"; -- a
            when X"62" => index_o <= "011011"; -- b
            when X"63" => index_o <= "011100"; -- c
            when X"64" => index_o <= "011101"; -- d
            when X"65" => index_o <= "011110"; -- e
            when X"66" => index_o <= "011111"; -- f
            when X"67" => index_o <= "100000"; -- g
            when X"68" => index_o <= "100001"; -- h
            when X"69" => index_o <= "100010"; -- i
            when X"6a" => index_o <= "100011"; -- j
            when X"6b" => index_o <= "100100"; -- k
            when X"6c" => index_o <= "100101"; -- l
            when X"6d" => index_o <= "100110"; -- m
            when X"6e" => index_o <= "100111"; -- n
            when X"6f" => index_o <= "101000"; -- o
            when X"70" => index_o <= "101001"; -- p
            when X"71" => index_o <= "101010"; -- q
            when X"72" => index_o <= "101011"; -- r
            when X"73" => index_o <= "101100"; -- s
            when X"74" => index_o <= "101101"; -- t
            when X"75" => index_o <= "101110"; -- u
            when X"76" => index_o <= "101111"; -- v
            when X"77" => index_o <= "110000"; -- w
            when X"78" => index_o <= "110001"; -- x
            when X"79" => index_o <= "110010"; -- y
            when X"7a" => index_o <= "110011"; -- z
            when X"20" => index_o <= "110100"; -- <space>
            when X"2c" => index_o <= "110101"; -- ,
            when X"2e" => index_o <= "110110"; -- .
            when X"0a" => index_o <= "110111"; -- \n
            when others => index_o <= "000000";
        end case;
    end process proc;

end arch;

