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

        int_count_ctrl      : in std_logic_vector (31 downto 0);
        int_reset_ctrl      : out std_logic;

        treasure_sw         : in std_logic;
        
	    count_reset         : out std_logic;
        direction_l	        : out std_logic;	
        direction_l_reset   : out std_logic;
        direction_r         : out std_logic;
        direction_r_reset   : out std_logic;
        ctr_mine_out        : out std_logic;
        ctr_mid             : out std_logic;
		  
		  DEB_led : out std_logic_vector(7 downto 0);
          DIR_led : out std_logic_vector(7 downto 0)      

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
	stupidstate1,
    LineFollow1,
	stupidstate2,
	LineFollow2,
    stupidstate3,
    mine,
    station,
    backward,
    backward_station,
	 stupidstate4,
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
begin
     DEB_led(0) <= ctr_mine;
	 DEB_led(1) <= ctr_mine;
     DEB_led(2) <= ctr_mine;
	 DEB_led(3) <= ctr_mine;
     DEB_led(4) <= ctr_mine;
	 DEB_led(5) <= ctr_mine;
     DEB_led(6) <= ctr_mine;
	 DEB_led(7) <= ctr_mine;
	 
    -- state assignments
    process(clk, reset)
    begin
        if(reset = '1') then
            ctrl_state <= reset_state;
            lf_state <= start;
        else
            if (rising_edge(clk)) then
                ctrl_state <= ctrl_new_state;
                lf_state <= lf_new_state;
            end if;
        end if;
    end process;

    process(clk, ctr_data)
    begin
        case ctr_data is
                    when "01100000" =>
                        DIR_led <= "00111100";
                    when "00100000" =>
                        DIR_led <= "00000111";
                    when "01000000" =>
                        DIR_led <= "11100000";
                    when "00110000" =>
                        DIR_led <= "11111111";
                    when "10000000" =>
                        DIR_led <= "11000011";
                    when others =>
                        DIR_led <= "11011011"; 
                end case;
    end process;


    process(clk,ctrl_state, lf_state, sensors_out, ctr_mine, ctr_data, reset, count_in)
    begin
        case ctrl_state is
            when reset_state =>
					
                count_reset        <= '1';
                direction_l	       <= '0';
                direction_l_reset  <= '1';
                direction_r        <= '0';
                direction_r_reset  <= '1';
                ctr_mid              <= '0';
                ctr_mine_out        <= '0';
                lf_new_state       <= start;
					 int_reset_ctrl <= '1';

                if (reset = '0') then
                    ctrl_new_state <= start;
                else
                    ctrl_new_state <= reset_state;
                end if;
			
            when start =>
					
                count_reset        <= '1';
                direction_l	       <= '0';
                direction_l_reset  <= '1';
                direction_r        <= '0';
                direction_r_reset  <= '1';
                ctr_mid              <= '0';
                ctr_mine_out        <= '0';
                lf_new_state       <= start;
					 int_reset_ctrl <= '1';
					case ctr_data is
                    when "01100000" =>
                        ctrl_new_state <= LineFollow2;
                        int_reset_ctrl <= '1';
                    when "00100000" =>
                        ctrl_new_state <= LineFollow2;
                        int_reset_ctrl <= '1';
                    when "01000000" =>
                        ctrl_new_state <= LineFollow2;
                        int_reset_ctrl <= '1';
                    when "00110000" =>
                        ctrl_new_state <= LineFollow2;
                        int_reset_ctrl <= '1';
                    when "10000000" =>
                        ctrl_new_state <= LineFollow2;
                        int_reset_ctrl <= '1';
                    when others =>
                        ctrl_new_state <= start;
                        int_reset_ctrl <= '1';
                end case;
			-- 		
            --     count_reset       <= '0';
            --     direction_l_reset <= '0';
            --     direction_r_reset <= '0';
            --     direction_l       <= '1';
            --     direction_r       <= '0';
            --     ctr_mid           <= '1';
            --     ctr_mine_out      <= '0';
					  
            --     lf_new_state      <= start;

            --     if (sensors_out = "000") then
            --         ctrl_new_state <= cross; 
            --     else 
            --         ctrl_new_state <= start;
            --     end if;
            when cross =>
					
                count_reset        <= '0';
                direction_l	       <= '0';
                direction_l_reset  <= '1';
                direction_r        <= '0';
                direction_r_reset  <= '1';
                ctr_mid            <= '0';
                ctr_mine_out       <= '0';
					  
                lf_new_state      <= start;

                case ctr_data is
                    when "01100000" =>
                        ctrl_new_state <= stupidstate1;
                        int_reset_ctrl <= '1';
                    when "00100000" =>
                        ctrl_new_state <= ctrl_right;
                        int_reset_ctrl <= '1';
                    when "01000000" =>
                        ctrl_new_state <= ctrl_left;
                        int_reset_ctrl <= '1';
                    when "00110000" =>
                        ctrl_new_state <= end_state;
                        int_reset_ctrl <= '1';
                    when "10000000" =>
                        ctrl_new_state <= turn_around_1;
                        int_reset_ctrl <= '1';
                    when others =>
                        ctrl_new_state <= cross;
                        int_reset_ctrl <= '1';
                end case;

            when ctrl_left =>
					
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '0';
                direction_r    <= '0';
                ctr_mid              <= '0';
                ctr_mine_out             <= '0';
                lf_new_state      <= start;

                if (unsigned(count_in) >= 1000000) then
                    count_reset <= '1';
                else
                    count_reset <= '0';
                end if;

                if (unsigned(int_count_ctrl) >= 31250000 and (sensors_out = "101" or sensors_out = "100" or sensors_out = "110")) then 
					ctrl_new_state <= LineFollow1;
					int_reset_ctrl <= '1';
				else
					ctrl_new_state <= ctrl_left;
					int_reset_ctrl <= '0';
				end if;	

                -- if (unsigned(int_count_ctrl) <= 31250000 or (sensors_out = "111")) then 
				-- 	ctrl_new_state <= ctrl_left;
				-- 	int_reset_ctrl <= '0';
				-- else
				-- 	ctrl_new_state <= LineFollow1;
				-- 	int_reset_ctrl <= '1';
				-- end if;	

            when ctrl_right =>
					
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '1';
                direction_r   <= '1';
                ctr_mid <= '0';
                ctr_mine_out <= '0';
                int_reset_ctrl <= '1';
                lf_new_state      <= start;

                if (unsigned(count_in) >= 1000000) then
                    count_reset <= '1';
                else
                    count_reset <= '0';
                end if;

                if (unsigned(int_count_ctrl) >= 31250000 and (sensors_out = "101" or sensors_out = "001" or sensors_out = "011")) then 
					ctrl_new_state <= LineFollow1;
					int_reset_ctrl <= '1';
				else
					ctrl_new_state <= ctrl_right;
					int_reset_ctrl <= '0';
				end if;	

                -- if (unsigned(int_count_ctrl) <= 31250000 or (sensors_out = "111")) then 
				-- 	ctrl_new_state <= ctrl_right;
				-- 	int_reset_ctrl <= '0';
				-- else
				-- 	ctrl_new_state <= LineFollow1;
				-- 	int_reset_ctrl <= '1';
				-- end if;	
                

            when turn_around_1  =>
            -- switch to T2 when 011 or 001
            -- switch to LF when 110 or 100
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '1';
                direction_r   <= '1';
                ctr_mid <= '0';
                ctr_mine_out <= '0';
					  
                lf_new_state      <= start;

                if (unsigned(count_in) >= 1000000) then
                    count_reset <= '1';
                else
                    count_reset <= '0';
                end if;

                if (unsigned(int_count_ctrl) >= 75000000 and (sensors_out = "101" or sensors_out = "001" or sensors_out="011")) then 
					ctrl_new_state <= LineFollow1;
					int_reset_ctrl <= '1';
				else
					ctrl_new_state <= turn_around_1;
					int_reset_ctrl <= '0';
				end if;	

            -- when turn_around_2 =>
			-- 		
            --     direction_l_reset <= '0';
            --     direction_r_reset <= '0';
            --     direction_l   <= '1';
            --     direction_r   <= '1';
            --     ctr_mid <= '0';
            --     ctr_mine_out <= '0';
            --     int_reset_ctrl <= '1';
			--     lf_new_state      <= start;

            --     if (unsigned(count_in) >= 1000000) then
            --         count_reset <= '1';
            --     else
            --         count_reset <= '0';
            --     end if;

            --     if (sensors_out = "011" or sensors_out = "001")  then
            --         ctrl_new_state <= turn_around_3;
            --     else
            --         ctrl_new_state <= turn_around_2;
            --     end if;
                    
            -- when turn_around_3 =>
			-- 		
            --     direction_l_reset <= '0';
            --     direction_r_reset <= '0';
            --     direction_l   <= '1';
            --     direction_r   <= '1';
            --     ctr_mid <= '0';
            --     ctr_mine_out <= '0';
            --     int_reset_ctrl <= '1';
					  
			-- 		 lf_new_state      <= start;
                
            --     if (unsigned(count_in) >= 1000000) then
            --         count_reset <= '1';
            --     else
            --         count_reset <= '0';
            --     end if;

            --     if (sensors_out = "110" or sensors_out = "100" or sensors_out = "101")  then
            --         ctrl_new_state <= stupidstate1;
            --     else
            --         ctrl_new_state <= turn_around_3;
            --     end if;

			when stupidstate1 =>
							
                lf_new_state<= start;
				ctr_mid <= '0';
				ctr_mine_out <='0'; 
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '1';
                direction_r   <= '0';

                if (unsigned(count_in) >= 1000000) then
                    count_reset <= '1';
                else
                    count_reset <= '0';
                end if;
								
				if (unsigned(int_count_ctrl) >= 12500000) then 
					ctrl_new_state <= LineFollow1;
					int_reset_ctrl <= '1';
				else
					ctrl_new_state <= stupidstate1;
					int_reset_ctrl <= '0';
				end if;				
							                   
            when LineFollow1 =>
                -- check for all states
				ctr_mid <= '0';
                int_reset_ctrl <= '1';
                if (ctr_mine = '1') then
                    ctrl_new_state <= mine;
                    lf_new_state <= start;
					count_reset <= '0';
                    direction_l_reset <= '1';
                    direction_r_reset <= '1';
                    direction_l   <= '1';
                    direction_r   <= '1';
                    ctr_mine_out <= '1';
					lf_new_state <= start;
                else
                    ctr_mine_out <= '0';
                    case lf_state is 
                            when start =>
										
                                count_reset <= '1';
                                direction_l_reset <= '1';
                                direction_r_reset <= '1';
                                direction_l   <= '1';
                                direction_r   <= '1';
                                if ((sensors_out="101") or (sensors_out="010")) then
                                    lf_new_state <= forward;
                                    ctrl_new_state <= LineFollow1;
                                elsif ((sensors_out="111")) then
                                    lf_new_state <= start;
                                    ctrl_new_state <= station;
                                elsif (sensors_out = "000") then
										  
												lf_new_state <= start;
												ctrl_new_state <= stupidstate2;
												
                                elsif (sensors_out = "001") then
                                      lf_new_state <= g_left;
                                      ctrl_new_state <= LineFollow1;
												  ctr_mid <= '0';
                                elsif (sensors_out="011") then
                                      lf_new_state<= s_left;
                                      ctrl_new_state <= LineFollow1;
												  ctr_mid <= '0';
                                elsif (sensors_out="100") then 
                                      lf_new_state<= g_right;
                                      ctrl_new_state <= LineFollow1;
												  ctr_mid <= '0';
                                elsif (sensors_out="110") then
                                       lf_new_state<= s_right;
                                       ctrl_new_state <= LineFollow1;
                                else 
                                    lf_new_state<= start;
                                    ctrl_new_state <= LineFollow1;  						
                                end if;
                                
                            
                            when forward =>
										
                                count_reset       <= '0'; 
                                direction_l_reset <= '0';
                                direction_r_reset <= '0';
                                direction_l   <= '1';
                                direction_r   <= '0'; 
                                ctrl_new_state <= LineFollow1;
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
                                 ctrl_new_state <= LineFollow1;
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
                                ctrl_new_state <= LineFollow1;
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
                                 ctrl_new_state <= LineFollow1;
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
                                 ctrl_new_state <= LineFollow1;
                                 if (unsigned(count_in) >= 1000000) then
                                    lf_new_state<= start;
                                 else lf_new_state<= s_right;
                                 end if;
                            when others =>
										
                                 count_reset       <= '0';
                                 direction_l_reset <= '1';
                                 direction_r_reset <= '1';
                                 direction_l   <= '0';
                                 direction_r   <= '0';
                                lf_new_state<= start;
                                ctrl_new_state <= LineFollow1;
                        end case;
                    end if;
						  
				when stupidstate2 =>
							
                    lf_new_state<= start;
                    ctr_mid <= '1';
                    ctr_mine_out <='0'; 
                    direction_l_reset <= '0';
                    direction_r_reset <= '0';
                    direction_l   <= '1';
                    direction_r   <= '0';

                    if (unsigned(count_in) >= 1000000) then
                        count_reset <= '1';
                    else
                        count_reset <= '0';
                    end if;
                                    
                    if (unsigned(int_count_ctrl) >= 25000000) then 
                        ctrl_new_state <= LineFollow2;
                        int_reset_ctrl <= '1';
                    else
                        ctrl_new_state <= stupidstate2;
                        int_reset_ctrl <= '0';
                    end if;
							        
				
				when LineFollow2=>
					ctr_mid <= '0';
                    int_reset_ctrl <= '1';
                    if (ctr_mine = '1') then
                        ctrl_new_state <= mine;
                        lf_new_state <= start;
				    	count_reset <= '0';
                        direction_l_reset <= '1';
                        direction_r_reset <= '1';
                        direction_l   <= '1';
                        direction_r   <= '1';
                        ctr_mine_out <= '1';
				    	lf_new_state <= start;
                    else
                        ctr_mine_out <= '0';
					    case lf_state is 
                                when start =>
                        
                                    count_reset <= '1';
                                    direction_l_reset <= '1';
                                    direction_r_reset <= '1';
                                    direction_l   <= '1';
                                    direction_r   <= '1';
                                    if ((sensors_out="101") or (sensors_out="010")) then
                                        lf_new_state <= forward;
                                        ctrl_new_state <= LineFollow2;
                                    elsif ((sensors_out="111")) then
                                        lf_new_state <= start;
                                        ctrl_new_state <= station;
                                    elsif (sensors_out = "000") then
                                    
                                    
					    							ctrl_new_state <= stupidstate3;
					    							lf_new_state <= start;
                                    
                                    
                                    elsif (sensors_out = "001") then
                                          lf_new_state <= g_left;
                                          ctrl_new_state <= LineFollow2;
                                    elsif (sensors_out="011") then
                                          lf_new_state<= s_left;
                                          ctrl_new_state <= LineFollow2;
                                    elsif (sensors_out="100") then 
                                          lf_new_state<= g_right;
                                          ctrl_new_state <= LineFollow2;
                                    elsif (sensors_out="110") then
                                           lf_new_state<= s_right;
                                           ctrl_new_state <= LineFollow2;
                                    else 
                                        lf_new_state<= start;
                                        ctrl_new_state <= LineFollow2;  					
                                    end if;

                                
                                when forward =>
                                
                                    count_reset       <= '0'; 
                                    direction_l_reset <= '0';
                                    direction_r_reset <= '0';
                                    direction_l   <= '1';
                                    direction_r   <= '0'; 
                                    ctrl_new_state <= LineFollow2;
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
                                     ctrl_new_state <= LineFollow2;
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
                                    ctrl_new_state <= LineFollow2;
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
                                     ctrl_new_state <= LineFollow2;
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
                                     ctrl_new_state <= LineFollow2;
                                     if (unsigned(count_in) >= 1000000) then
                                        lf_new_state<= start;
                                     else lf_new_state<= s_right;
                                     end if;

                                when others =>
                                 
                                     count_reset       <= '0';
                                     direction_l_reset <= '1';
                                     direction_r_reset <= '1';
                                     direction_l   <= '0';
                                     direction_r   <= '0';
                                    lf_new_state<= start;
                                    ctrl_new_state <= LineFollow2;
                            end case;
                        end if;

                when stupidstate3 =>
                        
                    lf_new_state<= start;
                    ctr_mid <= '0';
                    ctr_mine_out <='0'; 
                    direction_l_reset <= '0';
                    direction_r_reset <= '0';
                    direction_l   <= '1';
                    direction_r   <= '0';

                    if (unsigned(count_in) >= 1000000) then
                        count_reset <= '1';
                    else
                        count_reset <= '0';
                    end if;

                    if (unsigned(int_count_ctrl) >= 18750000) then 
                        ctrl_new_state <= cross;
                        int_reset_ctrl <= '1';
                    else
                        ctrl_new_state <= stupidstate3;
                        int_reset_ctrl <= '0';
                    end if;

            when mine =>
					
                count_reset        <= '0';
                direction_l	       <= '0';
                direction_l_reset  <= '1';
                direction_r        <= '0';
                direction_r_reset  <= '1';
                ctr_mid              <= '0';
                ctr_mine_out             <= '1';
                int_reset_ctrl <= '1';
                lf_new_state      <= start;

                if treasure_sw = '1' then
                    if (unsigned(int_count_ctrl) >= 200000000) then 
                        ctrl_new_state <= backward;
                        int_reset_ctrl <= '1';
                    else
                        ctrl_new_state <= mine;
                        int_reset_ctrl <= '0';
                    end if;
                else
                    ctrl_new_state <= backward;
                end if;  

            when station =>
					
                count_reset        <= '0';
                direction_l	       <= '0';
                direction_l_reset  <= '1';
                direction_r        <= '0';
                direction_r_reset  <= '1';
                ctr_mid              <= '1';
                ctr_mine_out             <= '0';
                int_reset_ctrl <= '1';
					  
                lf_new_state      <= start;

                ctrl_new_state <= backward_station;

            when backward =>
					
                    -- add small lf section?
                lf_new_state<= start;
                ctr_mid <= '0';
                ctr_mine_out <='0'; 
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '0';
                direction_r   <= '1';

                if (unsigned(count_in) >= 1000000) then
                    count_reset <= '1';
                else
                    count_reset <= '0';
                end if;

                if (unsigned(int_count_ctrl) >= 12500000 and sensors_out = "000") then 
                    ctrl_new_state <= stupidstate4;
                    int_reset_ctrl <= '1';
                else
                    ctrl_new_state <= backward;
                    int_reset_ctrl <= '0';
                end if;
					  
                -- case lf_state is
                --     when start =>
                --         count_reset <= '1';
                --         direction_l_reset <= '1';
                --         direction_r_reset <= '1';
                --         direction_l   <= '1';
                --         direction_r   <= '1';
								
                --         if ((sensors_out="101") or (sensors_out="010") or (sensors_out="111")) then
                --             lf_new_state <= forward;
				-- 					 ctrl_new_state <= backward;
                --         elsif (sensors_out = "001") then
                --               lf_new_state  <= g_left;
				-- 						ctrl_new_state <= backward;
				-- 						ctrl_new_state <= backward;
                --         elsif (sensors_out="011") then
                --               lf_new_state <= s_left;
				-- 						ctrl_new_state <= backward;
                --         elsif (sensors_out="100") then 
                --               lf_new_state <= g_right;
				-- 						ctrl_new_state <= backward;
                --         elsif (sensors_out="110") then
                --                lf_new_state <= s_right;
				-- 						 ctrl_new_state <= backward;
                --         elsif (sensors_out="000") then  
				-- 						ctrl_new_state<= stupidstate3;
                --         else 
                --             lf_new_state<= start;  
				-- 					 ctrl_new_state <= backward;
                --         end if;
                        
                
                --     when forward =>
                --         count_reset       <= '0'; 
                --         direction_l_reset <= '0';
                --         direction_r_reset <= '0';
                --         direction_l   <= '0';
                --         direction_r   <= '1'; 
				-- 				ctrl_new_state <= backward;
                --         if (unsigned(count_in) >= 1000000) then
                --             lf_new_state<= start;
                --         else 
                --             lf_new_state<= forward;
                --         end if; 
                    
                --     when g_left =>
                --          count_reset       <= '0';
                --          direction_l_reset <= '0';
                --          direction_r_reset <= '1';
                --          direction_l   <= '0';
                --          direction_r   <= '0';
				-- 				 ctrl_new_state <= backward;
                --          if (unsigned(count_in) >= 1000000) then
                --             lf_new_state<= start;
                --         else 
                --             lf_new_state<= g_left;
                --         end if;
                         
                --     when s_left =>
                --          count_reset       <= '0';
                --          direction_l_reset <= '0';
                --          direction_r_reset <= '0';
                --          direction_l   <= '0';
                --         direction_r    <= '0';
				-- 				ctrl_new_state <= backward;
                --          if (unsigned(count_in) >= 1000000) then
                --             lf_new_state<= start;
                --          else 
                --             lf_new_state<= s_left;
                --          end if;
        
                --     when g_right =>
                --          count_reset       <= '0';
                --          direction_l_reset <= '1';
                --          direction_r_reset <= '0';
                --          direction_l   <= '0';
                --          direction_r   <= '1';
				-- 				 ctrl_new_state <= backward;
                --          if (unsigned(count_in) >= 1000000) then
                --             lf_new_state<= start;
                --          else 
                --             lf_new_state<= g_right;
                --          end if;
        
                --     when s_right =>
                --          count_reset       <= '0';
                --          direction_l_reset <= '0';
                --          direction_r_reset <= '0';
                --          direction_l   <= '1';
                --          direction_r   <= '1';
				-- 				 ctrl_new_state <= backward;
                --          if (unsigned(count_in) >= 1000000) then
                --             lf_new_state<= start;
                --          else 
                --             lf_new_state<= s_right;
                --          end if;
				-- 			when others =>
				-- 				
                --                  count_reset       <= '0';
                --                  direction_l_reset <= '1';
                --                  direction_r_reset <= '1';
                --                  direction_l   <= '0';
                --                  direction_r   <= '0';
                --                 lf_new_state<= start;
                --                 ctrl_new_state <= backward;
        
                -- end case; 

                when backward_station =>

                    lf_new_state<= start;
                    ctr_mid <= '1';
                    ctr_mine_out <='0'; 
                    direction_l_reset <= '0';
                    direction_r_reset <= '0';
                    direction_l   <= '0';
                    direction_r   <= '1';

                    if (unsigned(count_in) >= 1000000) then
                        count_reset <= '1';
                    else
                        count_reset <= '0';
                    end if;

                    if (unsigned(int_count_ctrl) >= 12500000 and sensors_out = "000") then 
                        ctrl_new_state <= stupidstate4;
                        int_reset_ctrl <= '1';
                    else
                        ctrl_new_state <= backward;
                        int_reset_ctrl <= '0';
                    end if;
					  
					 
				when stupidstate4 =>
							
                lf_new_state<= start;
				ctr_mid <= '0';
				ctr_mine_out <='0'; 
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '1';
                direction_r   <= '0';

                if (unsigned(count_in) >= 1000000) then
                    count_reset <= '1';
                else
                    count_reset <= '0';
                end if;
								
				if (unsigned(int_count_ctrl) >= 18750000) then 
					ctrl_new_state <= cross;
					int_reset_ctrl <= '1';
				else
					ctrl_new_state <= stupidstate4;
					int_reset_ctrl <= '0';
				end if;				
                   

            when end_state =>
					
                -- this state only is called when the C code is finised running (celebration dance?)
                count_reset <= '1';
                direction_l_reset <= '1';
                direction_r_reset <= '1';
                direction_l   <= '0';
                direction_r   <= '0';
                ctr_mid <= '0';
                ctr_mine_out <= '0';
                int_reset_ctrl <= '1';
                lf_new_state <= start;					  

                ctrl_new_state<= end_state;

            when others =>
                -- to prevent latches
                ctrl_new_state<= reset_state;
					 
                lf_new_state <= start;
                count_reset <= '1';
                direction_l_reset <= '1';
                direction_r_reset <= '1';
                direction_l   <= '0';
                direction_r   <= '0';
                ctr_mid <= '0';
                ctr_mine_out <= '0';
                int_reset_ctrl <= '1';  
                
            end case;
        end process;

            
end architecture;
