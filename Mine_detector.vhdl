library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity Mine_detector is
  generic (
    -- NEEDS TUNING
	trig_count : integer := 10 -- (50*10^6/trig_freq)/2
	);
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
					 count <= (others => '0');
            elsif (sig_out = '1') then 
                sig_out <= '1';
            else
                if (count >= trig_count) then
                    sig_out <= '1';
                elsif (square_in = '1') then
                    count <= count + 1;
                elsif (square_in = '0') then
                    count <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    mine_out <= sig_out;
end architecture;
