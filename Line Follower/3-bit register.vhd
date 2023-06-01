library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity threebitregister is
    port(   input       :in std_logic_vector(2 downto 0);
            clk         :in std_logic;
    
            output      :out std_logic_vector(2 downto 0)
    );
end entity threebitregister;

architecture behavioral of threebitregister is

begin  
    process(clk)
    begin    
        if(rising_edge(clk)) then
            output <= input;
        end if;    
    
        end process;
end architecture behavioral;
