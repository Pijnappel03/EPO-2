library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity motorcontrol is
    port (
        reset			: in	std_logic;
        direction		: in	std_logic;
        count_in		: in	std_logic_vector (19 downto 0);
        pwm			: out	std_logic
    );
end entity motorcontrol;

architecture behavioral of motorcontrol is
    begin
        process(count_in, direction, reset)
        begin
            if (reset = '1') then
                pwm <= '0';
            elsif (direction = '1') then
                if(unsigned(count_in) > 100000) then
                    pwm <= '0';
                else
                pwm <= '1';
                end if;
            else
                if(unsigned(count_in) > 50000) then
                    pwm <= '0';
                else
                	pwm <= '1';
                end if;
            end if;
        end process;
 end architecture behavioral;
