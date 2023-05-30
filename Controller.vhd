library IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

entity controller is
  port (
        sensors_out	        : in std_logic_vector (2 downto 0); 
	    clk	                : in std_logic;
	    reset	   	        : in std_logic;
        count_in    	    : in std_logic_vector (19 downto 0);
        ctr_mine            : in std_logic;
        ctr_data            : in std_logic_vector (7 downto 0);
        
	    count_reset         : out std_logic;
        direction_l	        : out std_logic;	
        direction_l_reset   : out std_logic;
        direction_r         : out std_logic;
        direction_r_reset   : out std_logic;
        ctr_mine_out        : out std_logic;
        ctr_mid             : out std_logic

  );
end controller;

architecture behavioral of controller is
    type control_state is (start_midpoint, forward, crosspoint, s_left, s_right, reverse);
    signal state, new_state                                                                     : control_state;
    signal count_r, direction_ll, direction_rr, direction_l_resett, direction_r_resett          : std_logic;
    signal count_point                                                                          : integer; -- Count signal
    signal mid_s, mine_s                                                                        : std_logic; -- Inter signal to ctr_mid

begin
    direction_l <= direction_ll;
    direction_r <= direction_rr;
    count_reset <= count_r;
    direction_l_reset <= direction_l_resett;
    direction_r_reset <= direction_r_resett;

    ctr_mid <= mid_s;
    ctr_mine_out <= mine_s;

    process (clk, reset)
    begin
        if (rising_edge (clk)) then
            if (reset = '1') then
                state <= start_midpoint; 
            else
                state <= new_state;
            end if;
        end if;
    end process;

    process (state, count_in, sensors_out)
    begin
        case state is

            when start_midpoint => 
                count_r       <= '0'; 
                direction_l_resett <= '0';
                direction_r_resett <= '0';
                direction_ll   <= '1';
                direction_rr   <= '0';
                mid_s <= '1'; 
                mine_s <= '0';
					 count_point <= 1;
                if (ctr_mine = '1') then 
                    new_state<= reverse;
                    mine_s <= '1';
                else 
		            new_state<= forward;  
                end if;

                when forward => 
                count_r       <= '0'; 
                direction_l_resett <= '0';
                direction_r_resett <= '0';
                direction_ll   <= '1';
                direction_rr   <= '0'; 
                mid_s <= '0';
                mine_s <= '0';
                if (sensors_out="111") then
                    mid_s <= '1'; 
                    new_state<= reverse; 
                elsif (sensors_out="000") then
                    count_point <= count_point + 1;
                    if (count_point mod 2) = 0 then
                        new_state <= crosspoint;
                    else
                        new_state <= start_midpoint;
                    end if;
                end if;
            
            when crosspoint => 
            count_r       <= '0';
            direction_l_resett <= '1';
            direction_r_resett <= '1';
            direction_ll   <= '0';
            direction_rr    <= '0';
            mid_s <= '0';
            mine_s <= '0';
            if (ctr_data = "01100000") then
                    new_state <= forward;
            elsif (ctr_data = "00100000") then
                    new_state <= s_right;
            elsif (ctr_data = "01000000") then
                    new_state <= s_left;
            elsif (ctr_data = "00000000") then 
            end if;

            when s_left =>
                 count_r       <= '0';
                 direction_l_resett <= '0';
                 direction_r_resett <= '0';
                 direction_ll   <= '0';
                direction_rr    <= '0';
                mid_s <= '0';
                mine_s <= '0';
			    new_state<= forward;

            when s_right =>
                 count_r       <= '0';
                 direction_l_resett <= '0';
                 direction_r_resett <= '0';
                 direction_ll   <= '1';
                 direction_rr   <= '1';
                 mid_s <= '0';
                 mine_s <= '0';
			    new_state<= forward;
            
            when reverse => --terwijl die achteruit rijdt ontvangt ie info
                count_r       <= '0'; 
                direction_l_resett <= '0';
                direction_r_resett <= '0';
                direction_ll   <= '0';
                direction_rr   <= '1'; 
                mid_s <= '0';
                mine_s <= '0';
                if (sensors_out="000") then     
                    new_state<= crosspoint;
                end if;      

        end case;

     end process;

end architecture behavioral;


