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

    out_port : out std_logic_vector(8 downto 0)
  );
end entity;

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity flipflop is
  port (
    clk   : in std_logic;
    reset : in std_logic;
    fl_in : in std_logic_vector(8 downto 0);
    fl_out : out std_logic_vector(8 downto 0)
  );
end entity;

architecture behavioral of flipflop is

  begin  
    process(clk)
    begin    
        if(rising_edge(clk)) then
				  if (reset = '1') then
				  	fl_out <= "000000000";
          else
            fl_out <= fl_in;
          end if;
        end if;    
    end process;

end architecture behavioral;

architecture behavioral  of mux is
  
begin
  process (enable, ex_in_port)
  begin
    case enable is
      when '1' =>
        out_port <= ex_in_port;
      when '0' =>
        out_port <= in_in_port;
      when others =>
        out_port <= "000000000";
    end case;

  end process;
end architecture;

architecture struct of eightbitmemory is
  component mux is
    port (
      ex_in_port : in std_logic_vector(8 downto 0);
      in_in_port : in std_logic_vector(8 downto 0);
      enable : in std_logic;
  
      out_port : out std_logic_vector(8 downto 0)
    );
  end component;

  component flipflop is
    port (
      clk : in std_logic;
      reset : in std_logic;
      fl_in : in std_logic_vector(8 downto 0);
      fl_out : out std_logic_vector(8 downto 0)
    );
  end component;

  signal fl_out_sig, fl_in_sig : std_logic_vector(8 downto 0);

begin

  FL : flipflop port map (
    clk => clk,
    reset => reset,
    fl_in => fl_in_sig,
    fl_out => fl_out_sig
  );

  MX: mux port map (
    ex_in_port => register_input,
    in_in_port => fl_out_sig,
    enable => enable,

    out_port => fl_in_sig
);

  register_output <= fl_out_sig;

end architecture;