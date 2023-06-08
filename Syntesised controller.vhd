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
        ctr_mid             : out std_logic;
		  
		  DEB_led : out std_logic_vector(4 downto 0);
		  led_DEB :out std_logic_vector(1 downto 0)

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
begin
    
	 led_DEB(1) <= ctr_mine;
	 
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

    process(clk,ctrl_state, lf_state, sensors_out, ctr_mine, ctr_data, reset, count_in)
		variable stupidcount : integer;
    begin
        case ctrl_state is
            when reset_state =>
					DEB_led <= "00001";
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
                    ctrl_new_state <= reset_state;
                end if;
			
            when start =>
					DEB_led <= "00010";
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
					DEB_led <= "00011";
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
                        ctrl_new_state <= LineFollow1;
                    when "00100000" =>
                        ctrl_new_state <= ctrl_right;
                    when "01000000" =>
                        ctrl_new_state <= ctrl_left;
                    when "00110000" =>
                        ctrl_new_state <= end_state;
                    when "10000000" =>
                        ctrl_new_state <= turn_around_1;
                    when others =>
                        ctrl_new_state <= cross;
                end case;

            when ctrl_left =>
					DEB_led <= "00100";
                count_reset <= '0';
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '0';
                direction_r    <= '0';
                ctr_mid              <= '0';
                ctr_mine_out             <= '0';
					  
                lf_new_state      <= start;

                if (sensors_out = "110" or sensors_out = "100") then
                    ctrl_new_state<= LineFollow1;
			    else
                    ctrl_new_state <= ctrl_left;
                end if;

            when ctrl_right =>
					DEB_led <= "00101";
                count_reset <= '0';
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '1';
                direction_r   <= '1';
                ctr_mid <= '0';
                ctr_mine_out <= '0';
					  
                lf_new_state      <= start;

                if (sensors_out = "010" or sensors_out = "001") then
                    ctrl_new_state<= LineFollow1;
			    else
                    ctrl_new_state <= ctrl_right;
                end if;
                

            when turn_around_1  =>
					DEB_led <= "00110";
					led_DEB(0) <= '0';
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
					DEB_led <= "00111";
                count_reset <= '0';
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '1';
                direction_r   <= '1';
                ctr_mid <= '0';
                ctr_mine_out <= '0';
					  
			    lf_new_state      <= start;

                if (sensors_out = "011" or sensors_out = "001")  then
                    ctrl_new_state <= turn_around_3;
                else
                    ctrl_new_state <= turn_around_2;
                end if;
                    
            when turn_around_3 =>
					DEB_led <= "01000";
                count_reset <= '0';
                direction_l_reset <= '0';
                direction_r_reset <= '0';
                direction_l   <= '1';
                direction_r   <= '1';
                ctr_mid <= '0';
                ctr_mine_out <= '0';
					  
					 lf_new_state      <= start;

                if (sensors_out = "110" or sensors_out = "100" or sensors_out = "101")  then
                    ctrl_new_state <= LineFollow1;
                else
                    ctrl_new_state <= turn_around_3;
                end if;

			when stupidstate1 =>
							DEB_led <= "11111";
                     lf_new_state<= start;
							ctr_mid <= '1';
							ctr_mine_out <='0'; 
							count_reset       <= '0';
                     direction_l_reset <= '0';
                     direction_r_reset <= '0';
                     direction_l   <= '1';
                     direction_r   <= '0';
								
							if (stupidcount >= 75000000) then 
								ctrl_new_state <= LineFollow1;
								stupidcount := 0;
							else
								ctrl_new_state <= stupidstate1;
								stupidcount := stupidcount + 1;
							end if;				
							                   
            when LineFollow1 =>
                -- check for all states
                ctr_mine_out <= '0';
					 ctr_mid <= '0';
                if (ctr_mine = '1') then
                    ctrl_new_state <= mine;
                    lf_new_state <= start;
						  count_reset <= '0';
                    direction_l_reset <= '1';
                    direction_r_reset <= '1';
                    direction_l   <= '1';
                    direction_r   <= '1';
						  lf_new_state <= start;
                else
                    case lf_state is 
                            when start =>
										DEB_led <= "01001";
                                count_reset <= '1';
                                direction_l_reset <= '1';
                                direction_r_reset <= '1';
                                direction_l   <= '1';
                                direction_r   <= '1';
                                if ((sensors_out="101") or (sensors_out="010")) then
                                    lf_new_state <= forward;
                                    ctrl_new_state <= LineFollow1;
                                elsif ((sensors_out="111")) then
                                    lf_new_state <= forward;
                                    ctrl_new_state <= LineFollow1;
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
										DEB_led <= "01010";
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
										DEB_led <= "01011";
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
										DEB_led <= "01100";
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
										DEB_led <= "01101";
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
										DEB_led <= "01110";
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
										DEB_led <= "01111";
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
							DEB_led <= "11110";
                     lf_new_state<= start;
							ctr_mid <= '1';
							ctr_mine_out <='0';
							count_reset       <= '0';
                     direction_l_reset <= '0';
                     direction_r_reset <= '0';
                     direction_l   <= '1';
                     direction_r   <= '0';
										  
							if (stupidcount >= 75000000) then 
								ctrl_new_state <= LineFolllow2;
								stupidcount := 0;
							else
								ctrl_new_state <= stupidstate2;
								stupidcount := stupidcount + 1;
							end if;				
							        
				
				when LineFollow2=>
					ctr_mid <= '0';
					ctr_mine_out <= '0';
					led_DEB(0) <= '1';
					case lf_state is 
                            when start =>
										DEB_led <= "01001";
                                count_reset <= '1';
                                direction_l_reset <= '1';
                                direction_r_reset <= '1';
                                direction_l   <= '1';
                                direction_r   <= '1';
                                if ((sensors_out="101") or (sensors_out="010")) then
                                    lf_new_state <= forward;
                                    ctrl_new_state <= LineFollow2;
                                elsif ((sensors_out="111")) then
                                    lf_new_state <= forward;
                                    ctrl_new_state <= LineFollow2;
                                elsif (sensors_out = "000") then
										  
			
												ctrl_new_state <= cross;
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
										DEB_led <= "01010";
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
										DEB_led <= "01011";
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
										DEB_led <= "01100";
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
										DEB_led <= "01101";
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
										DEB_led <= "01110";
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
										DEB_led <= "01111";
                                 count_reset       <= '0';
                                 direction_l_reset <= '1';
                                 direction_r_reset <= '1';
                                 direction_l   <= '0';
                                 direction_r   <= '0';
                                lf_new_state<= start;
                                ctrl_new_state <= LineFollow2;
                        end case;

            when mine =>
					DEB_led <= "10000";
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
					DEB_led <= "10001";
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
					DEB_led <= "10010";
                    -- add small lf section?
                ctr_mid <= '0';
                ctr_mine_out <= '0';
					  
                case lf_state is
                    when start =>
                        count_reset <= '1';
                        direction_l_reset <= '1';
                        direction_r_reset <= '1';
                        direction_l   <= '1';
                        direction_r   <= '1';
								
                        if ((sensors_out="101") or (sensors_out="010") or (sensors_out="111")) then
                            lf_new_state <= forward;
									 ctrl_new_state <= backward;
                        elsif (sensors_out = "001") then
                              lf_new_state  <= g_left;
										ctrl_new_state <= backward;
										ctrl_new_state <= backward;
                        elsif (sensors_out="011") then
                              lf_new_state <= s_left;
										ctrl_new_state <= backward;
                        elsif (sensors_out="100") then 
                              lf_new_state <= g_right;
										ctrl_new_state <= backward;
                        elsif (sensors_out="110") then
                               lf_new_state <= s_right;
										 ctrl_new_state <= backward;
                        elsif (sensors_out="000") then  
										ctrl_new_state<= cross;
                        else 
                            lf_new_state<= start;  
									 ctrl_new_state <= backward;
                        end if;
                        
                
                    when forward =>
                        count_reset       <= '0'; 
                        direction_l_reset <= '0';
                        direction_r_reset <= '0';
                        direction_l   <= '0';
                        direction_r   <= '1'; 
								ctrl_new_state <= backward;
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
								 ctrl_new_state <= backward;
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
								ctrl_new_state <= backward;
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
								 ctrl_new_state <= backward;
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
								 ctrl_new_state <= backward;
                         if (unsigned(count_in) >= 1000000) then
                            lf_new_state<= start;
                         else 
                            lf_new_state<= s_right;
                         end if;
							when others =>
								DEB_led <= "10011";
                                 count_reset       <= '0';
                                 direction_l_reset <= '1';
                                 direction_r_reset <= '1';
                                 direction_l   <= '0';
                                 direction_r   <= '0';
                                lf_new_state<= start;
                                ctrl_new_state <= backward;
        
                end case; 
                   

            when end_state =>
					DEB_led <= "10100";
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
					 DEB_led <= "10101";
                lf_new_state <= start;
                count_reset <= '0';
                direction_l_reset <= '1';
                direction_r_reset <= '1';
                direction_l   <= '0';
                direction_r   <= '0';
                ctr_mid <= '0';
                ctr_mine_out <= '0';
					  

                
            end case;
        end process;

            
end architecture;
