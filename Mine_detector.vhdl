library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity Mine_detector is
  port (
    clk : in std_logic;
    square_in : in std_logic;
    sensors_out : in std_logic_vector(2 downto 0);
    mine_out : out std_logic
  );
end entity;

architecture behavioral of Mine_detector is
  signal count : unsigned(12 downto 0);
  signal sig_out : std_logic;
begin
    process (clk)
    begin
        if(rising_edge(clk)) then
            if(sensors_out = "000") then 
                sig_out <= '0'; 
            elsif (sig_out = '1') then 
                sig_out <= '1';
            else
                if (count >= 7500) then
                    sig_out <= '1';
                elsif (square_in = '1') then
                    count <= count + 1;
                elsif (square_in = '0') then
                    count <= 0;
                end if;
            end if;
        end if;
    end process;
    mine_out <= sig_out;
end architecture;