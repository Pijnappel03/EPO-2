library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity eightbitregister is
    port(   register_input       :in std_logic_vector(7 downto 0);
            clk         :in std_logic;
    
            register_output      :out std_logic_vector(7 downto 0)
    );
end entity eightbitregister;

architecture behavioral of eightbitregister is

begin  
    process(clk)
    begin    
        if(rising_edge(clk)) then
            register_output <= register_input;
        end if;    
    
        end process;
end architecture behavioral;
