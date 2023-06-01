LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

entity controller is
  port (
        sensors_out	: in 	std_logic_vector (2 downto 0); 
	clk	        : in 	std_logic;
	reset	   	: in 	std_logic;
        count_in    	: in    std_logic_vector (19 downto 0);
        
	count_reset : out    std_logic;
        direction_l	      : out std_logic;	
        direction_l_reset : out std_logic;
        direction_r       : out std_logic;
        direction_r_reset : out std_logic
  ) ;
end controller ;

architecture behavioral of controller is
    type control_state is ( start, forward, g_left, s_left, g_right, s_right);
    signal  state, new_state : control_state;
    signal count_r, direction_ll, direction_rr, direction_l_resett, direction_r_resett  : std_logic;
begin
    direction_l <= direction_ll;
    direction_r <= direction_rr;
    count_reset <= count_r;
    direction_l_reset <= direction_l_resett;
    direction_r_reset <= direction_r_resett;

    process (clk, reset)
    begin
        if (rising_edge (clk)) then
            if (reset = '1') then
                state <= start;
            else
                state <= new_state;
            end if;
        end if;
    end process;

    process ( state, count_in, sensors_out)
    begin
        case state is
        
            when start =>
                count_r <= '1';
                direction_l_resett <= '1';
                direction_r_resett <= '1';
                direction_ll   <= '1';
                direction_rr   <= '1';
                if ((sensors_out="111") or (sensors_out="101") or (sensors_out="010") or (sensors_out="000")) then
                    new_state <= forward;
                elsif (sensors_out = "001") then
                      new_state <= g_left;
                elsif (sensors_out="011") then
                      new_state<= s_left;
		        elsif (sensors_out="100") then 
                      new_state<= g_right;
		        elsif (sensors_out="110") then
                       new_state<= s_right;
		        else new_state<= start;  
                end if;
                
        
            when forward =>
                count_r       <= '0'; 
                direction_l_resett <= '0';
                direction_r_resett <= '0';
                direction_ll   <= '1';
                direction_rr   <= '0'; 
                if (unsigned(count_in) >= 1000000) then
			        new_state<= start;
			    else new_state<= forward;
		        end if; 
            
            when g_left =>
                 count_r       <= '0';
                 direction_l_resett <= '1';
                 direction_r_resett <= '0';
                 direction_ll   <= '0';
                 direction_rr   <= '0';
                 if (unsigned(count_in) >= 1000000) then
			        new_state<= start;
			    else new_state<= g_left;
                end if;
                 
            when s_left =>
                 count_r       <= '0';
                 direction_l_resett <= '0';
                 direction_r_resett <= '0';
                 direction_ll   <= '0';
                direction_rr    <= '0';
                 if (unsigned(count_in) >= 1000000) then
			        new_state<= start;
			     else new_state<= s_left;
                 end if;

            when g_right =>
                 count_r       <= '0';
                 direction_l_resett <= '0';
                 direction_r_resett <= '1';
                 direction_ll   <= '1';
                 direction_rr   <= '0';
                 if (unsigned(count_in) >= 1000000) then
			        new_state<= start;
			     else new_state<= g_right;
                 end if;

            when s_right =>
                 count_r       <= '0';
                 direction_l_resett <= '0';
                 direction_r_resett <= '0';
                 direction_ll   <= '1';
                 direction_rr   <= '1';
                 if (unsigned(count_in) >= 1000000) then
			        new_state<= start;
			     else new_state<= s_right;
                 end if;

        end case;

     end process;

end architecture ; -- arch