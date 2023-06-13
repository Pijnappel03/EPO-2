library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity eightbitmemory is
    port(   register_input       :in std_logic_vector(8 downto 0);
            clk         :in std_logic;
				    reset			: in std_logic;

            enable	: in std_logic;
            register_output      :out std_logic_vector(8 downto 0)
    );
end entity eightbitmemory;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity mux is
  port (
    ex_in_port : in std_logic_vector(8 downto 0);
    in_in_port : in std_logic_vector(8 downto 0);
    enable : in std_logic;

    out_port : out std_logic_vector(8 downto 0);
  );
end entity;

architecture behavioral of eightbitmemory is
  component mux is
    port (
      ex_in_port : in std_logic_vector(8 downto 0);
      in_in_port : in std_logic_vector(8 downto 0);
      enable : in std_logic;
  
      out_port : out std_logic_vector(8 downto 0);
    );
  end component;

  signal fl_in_sig : std_logic_vector(8 downto 0);
  signal fl_out_sig : std_logic_vector(8 downto 0);
begin  
    process(clk)
    begin    
        if(rising_edge(clk)) then
				  if (reset = '1') then
				  	fl_out_sig <= "000000000";
          else
            fl_out_sig <= fl_in_sig;
        end if;    
    
    end process;
    
    process (enable, ex_in_port)
    begin
      case enable
        when '1' then
          out_port <= ex_in_port;
        when '0' then
          out_port <= in_in_port;
        when others then
          out_port <= "000000000";

    end process;

    MX: mux port map (
            ex_in_port <= register_input;
            in_in_port <= fl_out_sig;
            enable <= enable;

            fl_in_sig <= out_port;
    );
    
    register_output <= fl_out_sig;

end architecture behavioral;
