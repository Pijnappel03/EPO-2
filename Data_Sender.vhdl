library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity out_buff is
  port (
		regin : in    std_logic_vector(7 downto 0);
		regout : out    std_logic_vector(7 downto 0)
  );
end entity;

architecture Behavioral of out_buff is
  
begin
  process(regin)
  begin
    regout <= regin;
  end process;
end architecture;


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity Data_Sender is
  port (
        clk : in std_logic;
        reset : in std_logic;
    -- tx
        DS_out_UART_in : out std_logic_vector(7 downto 0);
        buffer_empty : in std_logic;
        write : out std_logic;
    -- rx
        DS_in_UART_out : in std_logic_vector(7 downto 0);
        data_ready : in std_logic;
        read : out std_logic;
    -- user in
        DS_in_mine : in std_logic;
        DS_in_mid : in std_logic;
        DS_out : out std_logic_vector(7 downto 0)
  );
end entity;


architecture behavioral of Data_Sender is
    component out_buff is
		port (
			regin : in    std_logic_vector(7 downto 0);
		  regout : out    std_logic_vector(7 downto 0)
		);
	end component;

  type transmitter_state is (
    tx_idle,
    tx_hold_mine,
    tx_hold_cross,
    tx_mine,
    tx_cross
  );

  type reciever_state is (
    rx_idle,
    rx_toBuff
  );

  signal tx_state, tx_new : transmitter_state;
  signal rx_state, rx_new : reciever_state;
  signal data : std_logic_vector(7 downto 0);
begin

  -- assign states (clk process)
  process(clk)
  begin
    if(rising_edge(clk)) then
      tx_state <= tx_new;
      rx_state <= rx_new;
    end if;
  end process;

  -- tx state comb
  process(tx_state, DS_in_mid, DS_in_mine, reset)
  begin
    if (reset = '1') then
      tx_new <= tx_idle;
    else 
      case tx_state is
        when tx_idle =>
          write <= '0';
          DS_out_UART_in <= "00000001";
          if(DS_in_mid = '1') then
            tx_new <= tx_hold_cross;
          elsif(DS_in_mine = '1') then
            tx_new <= tx_hold_mine;     
          else
            tx_new <= tx_idle;
          end if;

        when tx_hold_mine =>
          DS_out_UART_in <= "00000001";
          if(buffer_empty = '0') then
            tx_new <= tx_mine;
          else
            tx_new <= tx_hold_mine;
          end if;

        when tx_hold_cross =>
          DS_out_UART_in <= "00000001";
          if(buffer_empty = '0') then
            tx_new <= tx_cross;
          else
            tx_new <= tx_hold_cross;
          end if;

        when tx_mine =>
          DS_out_UART_in <= "00100000";
          write <= '1';
          tx_new <= tx_idle;

        when tx_cross =>
          DS_out_UART_in <= "01000000";
          write <= '1';
          tx_new <= tx_idle;

          when others =>
            tx_new <= tx_idle;

      end case;
    end if;

  end process;

  -- RX combinatorial

  process(rx_state, data_ready)
  begin
    if (reset = '1') then
      rx_new <= rx_idle;
    else 
      case rx_state is
        when rx_idle =>
          if (data_ready = '1') then
            rx_new <= rx_toBuff;
          else 
            rx_new <= rx_idle;
          end if;
          read <= '0';
        when rx_toBuff =>
          data <= DS_in_UART_out;
          read <= '1';
      end case;
    end if;
  end process;

  REG: out_buff port map(regin => data, regout => DS_out);
end architecture;
