library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity Mine_detector is
  generic (
	  Base_Count : integer := 2600 -- to limit the ammount of signed bits needed
  );
  port (
    clk : in std_logic;
    reset : in std_logic;
    square_in : in std_logic;
    sensors_out : in std_logic_vector(2 downto 0);
    register_output : in std_logic_vector (8 downto 0);

    mine_out : out std_logic;
    register_input : out std_logic_vector(8 downto 0);
    register_enable : out std_logic
  );
end entity;

architecture behavioral of Mine_detector is
  type MD_state is (
    reset_state,
    setup,
    running
  );
  signal state, new_state : MD_state;
  signal count : unsigned(12 downto 0);
  signal sig_out : std_logic;
begin
    process (clk)
    begin
        if(rising_edge(clk)) then
          if (reset = '1') then
            state <= reset_state;
          else
            state <= new_state;
          end if;
        end if;
    end process;

    process (state, new_state)
    begin
      case state is
        when reset_state =>
          sig_out <= '0';
          register_enable <= '0';
          count <= (others => '0');
          register_input <= (others => '0');
          if (reset = '1') then
            new_state <= reset_state;
          else
            new_state <= setup;
          end if;
        
          -- setup the trigger count needed at any battery level
        when setup =>
          sig_out <= '0';
          if(square_in = '1') then 
            count <= count + 1;
            new_state <= setup;
            register_enable <= '0';
          elsif (square_in = '0') then
            register_input <= signed(count - base_count);
            register_enable <= '1';
            new_state <= running;
          else
            register_input <= (others => '0');
            count <= (others => '0');
            register_enable <= '0';
            new_state <= reset_state;
          end if;
        end case;

        when running =>
          register_enable <= '0';
          register_input <= (others => '0');
          new_state <= running;
          if(sensors_out = "000") then 
            sig_out <= '0'; 
            count <= (others => '0');
          elsif (sig_out = '1') then 
              sig_out <= '1';
              count <= (others => '0');
          else
              if (count = base_count + signed(register_output) + 25) then
                  sig_out <= '1';
              elsif (square_in = '1') then
                  count <= count + 1;
              else
                  count <= (others => '0');
              end if;
          end if;
        end case;

    end process;

    mine_out <= sig_out;
end architecture;
