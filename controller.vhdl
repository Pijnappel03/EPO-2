LIBRARY IEEE; 
USE IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.all;

entity controller is
  port (
        sensors_out	        : in 	std_logic_vector (2 downto 0); 
	    clk	                : in 	std_logic;
	    reset	   	        : in 	std_logic;
        count_in    	    : in    std_logic_vector (19 downto 0);
        
	    count_reset         : out    std_logic;
        direction_l	        : out std_logic;	
        direction_l_reset   : out std_logic;
        direction_r         : out std_logic;
        direction_r_reset   : out std_logic
  ) ;
end controller ;

architecture behavioral of controller is
    component eightbitregister is
        port(   register_input       :in std_logic_vector(7 downto 0);
                clk                  :in std_logic;

                register_output      :out std_logic_vector(7 downto 0)
        );
    end component eightbitregister;

    type control_state is (start_midpoint, forward, crosspoint, s_left, s_right, reverse);
    signal  state, new_state : control_state;
    signal count_r, direction_ll, direction_rr, direction_l_resett, direction_r_resett  : std_logic;
    signal count_point, data_in, data_out : std_logic;
    signal DS_in_mine_s, DS_in_cross_s :std_logic;
    signal register_input_s, register_output_s :std_logic;

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
                state <= start_midpoint;
                count_point <= '1'; 
            else
                state <= new_state;
            end if;
        end if;
    end process;

    process (state, count_in, sensors_out, data_in, data_out)
    begin
        case state is

            when start_midpoint => 
                count_r       <= '0'; 
                direction_l_resett <= '0';
                direction_r_resett <= '0';
                direction_ll   <= '1';
                direction_rr   <= '0';
                DS_in_cross_s <= '1'; 
                register_input_s <= data_in; --data_in van C wordt gestoken in de register
                if (mijn = '1') then --mijn signal onbekend
                    DS_in_mine_s <= '1';
                    new_state<= reverse;
                else 
                    DS_in_mine_s <= '0';
		            new_state<= forward;  
                end if;

                when forward => 
                count_r       <= '0'; 
                direction_l_resett <= '0';
                direction_r_resett <= '0';
                direction_ll   <= '1';
                direction_rr   <= '0'; 
                DS_in_cross_s <= '0';
                DS_in_mine_s <= '0';
                if (sensors_out="111") then
                    DS_in_cross_s <= '1'; 
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
            data_out <= register_output_s; --signaal wordt uit register gehaald
            if (data_out = "01100000") then
                    new_state <= forward;
            elsif (data_out = "00100000") then
                    new_state <= s_right;
            elsif (data_out = "01000000") then
                    new_state <= s_left;
            elsif (data_out = "00000000") then 
                count_r       <= '0';
                direction_l_resett <= '1';
                direction_r_resett <= '1';
                direction_ll   <= '0';
                direction_rr    <= '0';
                DS_in_cross_s <= '0';
                DS_in_mine_s <= '0';
            end if;

            when s_left =>
                 count_r       <= '0';
                 direction_l_resett <= '0';
                 direction_r_resett <= '0';
                 direction_ll   <= '0';
                direction_rr    <= '0';
                DS_in_cross_s <= '0';
                DS_in_mine_s <= '0';
			    new_state<= forward;

            when s_right =>
                 count_r       <= '0';
                 direction_l_resett <= '0';
                 direction_r_resett <= '0';
                 direction_ll   <= '1';
                 direction_rr   <= '1';
                 DS_in_cross_s <= '0';
                 DS_in_mine_s <= '0';
			    new_state<= forward;
            
            when reverse => --terwijl die achteruit rijdt ontvangt ie info
                count_r       <= '0'; 
                direction_l_resett <= '0';
                direction_r_resett <= '0';
                direction_ll   <= '0';
                direction_rr   <= '1'; 
                DS_in_cross_s <= '0';
                DS_in_mine_s <= '0';
                register_input_s <= data_in;
                if (sensors_out="000") then     
                    new_state<= crosspoint;
                end if;      

        end case;

     end process;

end architecture ; -- arch

