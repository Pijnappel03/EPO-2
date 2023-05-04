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
        DS_in_cross : in std_logic;
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
    tx_hold_ack,
    tx_mine,
    tx_cross,
    tx_ack,
    tx_wait_ack_mine,
    tx_wait_ack_cross
  );

  type reciever_state is (
    rx_idle,
    rx_read,
    rx_toBuff
  );

  signal ack_send : std_logic;
  signal ack_rec : std_logic;
  signal tx_state, tx_new : transmitter_state;
  signal rx_state, rx_new : reciever_state;
  signal count_cross : std_logic;
  signal count_ack : unsigned(12 downto 0); 
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
  process(tx_state, DS_in_cross, DS_in_mine, ack_send, reset)
  begin
    if (reset = '1') then
      tx_new <= tx_idle;
    else 
      case tx_state is
        when tx_idle =>
          if(rising_edge(DS_in_cross)) then
            tx_new <= tx_hold_cross;
          elsif(rising_edge(DS_in_mine)) then
            tx_new <= tx_hold_mine;     
          elsif(ack_send = '1') then
            tx_new <= tx_hold_ack;
          else
            tx_new <= tx_idle;
          end if;

        when tx_hold_mine =>
          if(buffer_empty = '0') then
            tx_new <= tx_mine;
          else
            tx_new <= tx_hold_mine;
          end if;

        when tx_hold_cross =>
          if (count_cross = '1') then
            count_cross <= '0';
            if(buffer_empty = '0') then
              tx_new <= tx_cross;
            else
              tx_new <= tx_hold_cross;
            end if;
          else 
            count_cross <= '1';
            tx_new <= tx_idle;
          end if;

        when tx_hold_ack =>
          if(buffer_empty = '0') then
            tx_new <= tx_ack;
          else
            tx_new <= tx_hold_ack;
          end if;

        when tx_mine =>
          DS_out_UART_in <= "01000000";
          write <= '1';
          tx_new <= tx_wait_ack_mine;

        when tx_cross =>
          DS_out_UART_in <= "10000000";
          write <= '1';
          tx_new <= tx_wait_ack_cross;

        when tx_ack =>
          DS_out_UART_in <= "00010000";
          write <= '1';
          tx_new <= tx_idle;
          ack_send <= '0';

        when tx_wait_ack_mine =>
          write <= '0';
          if(count_ack = 4000)then
            tx_new <= tx_wait_ack_mine;
            count_ack <= count_ack + 1;
          elsif (count_ack = 4000) then
            tx_new <= tx_hold_mine;
          else
            count_ack <= "0";
            tx_new <= tx_wait_ack_mine;
          end if;

        when tx_wait_ack_cross =>
          write <= '0';
          if(count_ack = 4000)then
            if(ack_rec = '1') then
              count_ack <= "0";
              ack_rec <= '0';
              tx_new <= tx_idle;
            else
              tx_new <= tx_wait_ack_cross;
              count_ack <= count_ack + 1;
            end if;
          elsif (count_ack = 4000) then
            tx_new <= tx_hold_cross;
          else
            count_ack <= "0";
            tx_new <= tx_wait_ack_cross;
          end if;

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
            rx_new <= rx_read;
          else 
            rx_new <= rx_idle;
          end if;
        when rx_read =>
          if (DS_in_UART_out = "00010000") then
            ack_rec <= '1';
            rx_new <= rx_idle;
          else
            rx_new <= rx_toBuff;
          end if;
        when rx_toBuff =>
          data <= DS_in_UART_out;
          read <= '1';
      end case;
    end if;
  end process;

  REG: out_buff port map(regin => data, regout => DS_out);
end architecture;