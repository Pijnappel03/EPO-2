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
  type ctrl_states is (
    reset_state,
    start,
    cross,
    ctrl_left,
    ctrl_right,
    turn_around_1,
    turn_around_2,
    turn_around_3,
    LineFollow,
    mine,
    station,
    backward,
    end_state
  );
  type lf_states is (
    start,
    forward,
    g_left,
    s_left,
    g_right,
    s_right
  );

  signal ctrl_state, ctrl_new_state : ctrl_states;
  signal lf_state, lf_new_state : lf_states;
  signal count_midpoint : std_logic;
begin
    
    -- state assignments
    process(clk, reset) 
    begin
        if(reset = '1') then
            ctrl_state <= reset_state;
        else
            if (rising_edge(clk)) then
                ctrl_state <= ctrl_new_state;
                lf_state <= lf_new_state;
            end if;
        end if;
    end process;

    process(ctrl_state, lf_state, sensors_out, ctr_mine, ctr_data)
    begin
        case ctrl_state is
            when reset_state =>
                count_reset        <= '1';
                direction_l	       <= '0';
                direction_l_reset  <= '1';
                direction_r        <= '0';
                direction_r_reset  <= '1';
                ctr_mid              <= '0';
                ctr_mine_out             <= '0';
                lf_new_state       <= start;

                if (reset = '0') then
                    ctrl_new_state <= start;
                else
                    
                end if;
            when start =>
                count_reset       <= '0';
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l       <= '1';
                direction_r       <= '0';
                ctr_mid           <= '1';
                ctr_mine_out      <= '0';
                lf_new_state      <= start;

                if (sensors_out = "000") then
                    ctrl_new_state <= cross; 
                else 
                    ctrl_new_state <= start;
                end if;
            when cross =>
                count_reset        <= '0';
                direction_l	       <= '0';
                direction_l_reset  <= '1';
                direction_r        <= '0';
                direction_r_reset  <= '1';
                ctr_mid            <= '0';
                ctr_mine_out       <= '0';
                lf_new_state      <= start;

                -- TODO: add UART codes
                case ctr_data is
                    when "01100000" =>
                        ctrl_new_state <= LineFollow;
                    when "00100000" =>
                        ctrl_new_state <= ctrl_right;
                    when "01000000" =>
                        ctrl_new_state <= ctrl_left;
                    when "00110000" => --Maybe change this code
                        ctrl_new_state <= end_state;
                    when "10000000" =>
                        ctrl_new_state <= turn_around_1;
                    when others =>
                        ctrl_new_state <= cross;
                end case;

            when ctrl_left =>
                count_reset <= '0';
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '0';
                direction_r    <= '0';
                ctr_mid              <= '0';
                ctr_mine_out             <= '0';
                lf_new_state      <= start;

                if (sensors_out = "101") then
                    ctrl_new_state<= LineFollow;
			    else
                    ctrl_new_state <= ctrl_left;
                end if;

            when ctrl_right =>
                count_reset <= '0';
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '1';
                direction_r   <= '1';
                ctr_mid <= '0';
                ctr_mine_out <= '0';
                lf_new_state      <= start;

                if (sensors_out = "101" or sensors_out = "110" or sensors_out = "100") then
                    ctrl_new_state<= LineFollow;
			    else
                    ctrl_new_state <= ctrl_right;
                end if;
                

            when turn_around_1  =>
            -- switch to T2 when 011 or 001
            -- switch to LF when 110 or 100
                count_reset <= '0';
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '1';
                direction_r   <= '1';
                ctr_mid <= '0';
                ctr_mine_out <= '0';
                lf_new_state      <= start;

                if (sensors_out = "111")  then
                    ctrl_new_state <= turn_around_2;
                else
                    ctrl_new_state <= turn_around_1;
                end if;

            when turn_around_2 =>
                count_reset <= '0';
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '1';
                direction_r   <= '1';
                ctr_mid <= '0';
                ctr_mine_out <= '0';

                if (sensors_out = "011" or sensors_out = "001")  then
                    ctrl_new_state <= turn_around_3;
                else
                    ctrl_new_state <= turn_around_2;
                end if;
                    
            when turn_around_3 =>
                count_reset <= '0';
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '1';
                direction_r   <= '1';
                ctr_mid <= '0';
                ctr_mine_out <= '0';

                if (sensors_out = "110" or sensors_out = "100" or sensors_out = "101")  then
                    ctrl_new_state <= LineFollow;
                else
                    ctrl_new_state <= turn_around_3;
                end if;                
                    
            when LineFollow =>
                -- check for all states
                ctr_mid <= '0';
                ctr_mine_out <= '0';
                if (ctr_mine = '1') then
                    ctrl_new_state <= mine;
                    lf_new_state <= start;
                else
                    case lf_state is 
                            when start =>
                                count_reset <= '1';
                                direction_l_reset <= '1';
                                direction_r_reset <= '1';
                                direction_l   <= '1';
                                direction_r   <= '1';
                                if ((sensors_out="101") or (sensors_out="010")) then
                                    lf_new_state <= forward;
                                    ctrl_new_state <= LineFollow;
                                elsif ((sensors_out="111")) then
                                    lf_new_state <= start;
                                    ctrl_new_state <= station;
                                elsif (sensors_out = "000") then
                                    if (count_midpoint = '1') then
                                        count_midpoint <= '0';
                                        ctrl_new_state <= cross;
                                        lf_new_state <= start;
                                    else
                                        count_midpoint <= '1';
                                        ctrl_new_state <= LineFollow;
                                        lf_new_state <= forward;
                                    end if;
                                elsif (sensors_out = "001") then
                                      lf_new_state <= g_left;
                                      ctrl_new_state <= LineFollow;
                                elsif (sensors_out="011") then
                                      lf_new_state<= s_left;
                                      ctrl_new_state <= LineFollow;
                                elsif (sensors_out="100") then 
                                      lf_new_state<= g_right;
                                      ctrl_new_state <= LineFollow;
                                elsif (sensors_out="110") then
                                       lf_new_state<= s_right;
                                       ctrl_new_state <= LineFollow;
                                else 
                                    lf_new_state<= start;
                                    ctrl_new_state <= LineFollow;  
                                end if;
                                
                            
                            when forward =>
                                count_reset       <= '0'; 
                                direction_l_reset <= '0';
                                direction_r_reset <= '0';
                                direction_l   <= '1';
                                direction_r   <= '0'; 
                                ctrl_new_state <= LineFollow;
                                if (unsigned(count_in) >= 1000000) then
                                    lf_new_state<= start;
                                else lf_new_state<= forward;
                                end if; 
                            
                            when g_left =>
                                 count_reset       <= '0';
                                 direction_l_reset <= '1';
                                 direction_r_reset <= '0';
                                 direction_l   <= '0';
                                 direction_r   <= '0';
                                 ctrl_new_state <= LineFollow;
                                 if (unsigned(count_in) >= 1000000) then
                                    lf_new_state<= start;
                                else lf_new_state<= g_left;
                                end if;
                                 
                            when s_left =>
                                 count_reset       <= '0';
                                 direction_l_reset <= '0';
                                 direction_r_reset <= '0';
                                 direction_l   <= '0';
                                direction_r    <= '0';
                                ctrl_new_state <= LineFollow;
                                 if (unsigned(count_in) >= 1000000) then
                                    lf_new_state<= start;
                                 else lf_new_state<= s_left;
                                 end if;
                             
                            when g_right =>
                                 count_reset       <= '0';
                                 direction_l_reset <= '0';
                                 direction_r_reset <= '1';
                                 direction_l   <= '1';
                                 direction_r   <= '0';
                                 ctrl_new_state <= LineFollow;
                                 if (unsigned(count_in) >= 1000000) then
                                    lf_new_state<= start;
                                 else lf_new_state<= g_right;
                                 end if;
                             
                            when s_right =>
                                 count_reset       <= '0';
                                 direction_l_reset <= '0';
                                 direction_r_reset <= '0';
                                 direction_l   <= '1';
                                 direction_r   <= '1';
                                 ctrl_new_state <= LineFollow;
                                 if (unsigned(count_in) >= 1000000) then
                                    lf_new_state<= start;
                                 else lf_new_state<= s_right;
                                 end if;
                            when others =>
                                lf_new_state<= start;
                                ctrl_new_state <= LineFollow;
                        end case;
                    end if;

            when mine =>
                count_reset        <= '0';
                direction_l	       <= '0';
                direction_l_reset  <= '1';
                direction_r        <= '0';
                direction_r_reset  <= '1';
                ctr_mid              <= '0';
                ctr_mine_out             <= '1';
                lf_new_state      <= start;

                ctrl_new_state <= backward;

            when station =>
                count_reset        <= '0';
                direction_l	       <= '0';
                direction_l_reset  <= '1';
                direction_r        <= '0';
                direction_r_reset  <= '1';
                ctr_mid              <= '1';
                ctr_mine_out             <= '0';
                lf_new_state      <= start;

                ctrl_new_state <= backward;

            when backward =>
                    -- add small lf section?
                count_reset <= '0'; 
                ctr_mid <= '0';
                ctr_mine_out <= '0';
                lf_new_state      <= start; 
                case lf_state is
                    when start =>
                        count_reset <= '1';
                        direction_l_reset <= '1';
                        direction_r_reset <= '1';
                        direction_l   <= '1';
                        direction_r   <= '1';
                        if ((sensors_out="101") or (sensors_out="010")) then
                            lf_new_state <= forward;
                        elsif (sensors_out = "001") then
                              lf_new_state  <= g_left;
                        elsif (sensors_out="011") then
                              lf_new_state <= s_left;
                        elsif (sensors_out="100") then 
                              lf_new_state <= g_right;
                        elsif (sensors_out="110") then
                               lf_new_state <= s_right;
                        elsif (sensors_out="000") then  
                            ctrl_new_state<= cross;
                        else 
                            lf_new_state<= start;  
                        end if;
                        
                
                    when forward =>
                        count_reset       <= '0'; 
                        direction_l_reset <= '0';
                        direction_r_reset <= '0';
                        direction_l   <= '0';
                        direction_r   <= '1'; 
                        if (unsigned(count_in) >= 1000000) then
                            lf_new_state<= start;
                        else 
                            lf_new_state<= forward;
                        end if; 
                    
                    when g_left =>
                         count_reset       <= '0';
                         direction_l_reset <= '0';
                         direction_r_reset <= '1';
                         direction_l   <= '0';
                         direction_r   <= '0';
                         if (unsigned(count_in) >= 1000000) then
                            lf_new_state<= start;
                        else 
                            lf_new_state<= g_left;
                        end if;
                         
                    when s_left =>
                         count_reset       <= '0';
                         direction_l_reset <= '0';
                         direction_r_reset <= '0';
                         direction_l   <= '0';
                        direction_r    <= '0';
                         if (unsigned(count_in) >= 1000000) then
                            lf_new_state<= start;
                         else 
                            lf_new_state<= s_left;
                         end if;
        
                    when g_right =>
                         count_reset       <= '0';
                         direction_l_reset <= '1';
                         direction_r_reset <= '0';
                         direction_l   <= '0';
                         direction_r   <= '1';
                         if (unsigned(count_in) >= 1000000) then
                            lf_new_state<= start;
                         else 
                            lf_new_state<= g_right;
                         end if;
        
                    when s_right =>
                         count_reset       <= '0';
                         direction_l_reset <= '0';
                         direction_r_reset <= '0';
                         direction_l   <= '1';
                         direction_r   <= '1';
                         if (unsigned(count_in) >= 1000000) then
                            lf_new_state<= start;
                         else 
                            lf_new_state<= s_right;
                         end if;
        
                end case; 
                   

            when end_state =>
                -- this state only is called when the C code is finised running (celebration dance?)
                count_reset <= '0';
                direction_l_reset <= '1';
                direction_r_reset <= '1';
                direction_l   <= '0';
                direction_r   <= '0';
                ctr_mid <= '0';
                ctr_mine_out <= '0';

                ctrl_new_state<= end_state;

            when others =>
                -- to prevent latches
                ctrl_new_state<= reset_state;
                
            end case;
        end process;

            
end architecture;