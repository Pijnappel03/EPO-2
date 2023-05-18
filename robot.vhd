library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity robot is
    port (
        clk             : in std_logic;
        reset           : in std_logic;
        
        sensor_l_in     : in std_logic;  
        sensor_m_in     : in std_logic;       
        sensor_r_in     : in std_logic;

        motor_l_pwm     : out std_logic;
        motor_r_pwm     : out std_logic;       
        
        mine_square_in  : in std_logic;
        ro_rx              : out std_logic; 
        ro_tx              : out std_logic
    );
end entity robot;

architecture structural of robot is
    component motorcontrol is
        port (
        reset			: in	std_logic;
        direction		: in	std_logic;
        count_in		: in	std_logic_vector (19 downto 0);
        pwm			    : out	std_logic :='1'
        );
    end component motorcontrol;

    component inputbuffer is
        port(
            sensor_l_in         : in std_logic;
            sensor_m_in         : in std_logic; 
            sensor_r_in         : in std_logic;
            clk                 : in std_logic;
            sensors_out         : out std_logic_vector(2 downto 0)
        );
    end component inputbuffer;
    
    component controller is
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
    end component controller;

    component timebase is
        port(
            clk                     : in std_logic;
            reset                   : in std_logic;
            count_out               : out std_logic_vector(19 downto 0)
        );
    end component timebase;

    component eightbitregister is
        port(   register_input      :in std_logic_vector(7 downto 0);
            clk                     :in std_logic;
    
            register_output         :out std_logic_vector(7 downto 0)
    );
    end component eightbitregister;

    component Data_sender is
        port (
            clk             : in std_logic;
            reset           : in std_logic;
        -- tx
            DS_out_UART_in  : out std_logic_vector(7 downto 0);
            buffer_empty    : in std_logic;
            write           : out std_logic;
        -- rx
            DS_in_UART_out  : in std_logic_vector(7 downto 0);
            data_ready      : in std_logic;
            read            : out std_logic;
        -- user in
            DS_in_mine      : in std_logic;
            DS_in_mid       : in std_logic;
            DS_out          : out std_logic_vector(7 downto 0)
      );
    end component Data_sender;

    component Mine_detector is
        generic (
            trig_count      : integer := 2700 -- (50*10^6/trig_freq)/2
            );
          port (
            clk             : in std_logic;
            square_in       : in std_logic;
            sensors_out     : in std_logic_vector(2 downto 0);
            
            mine_out        : out std_logic
          );
    end component Mine_detector;

    component uart is
        port (
            clk             : in  std_logic;
            reset           : in  std_logic;
    
            rx              : in  std_logic;
            tx              : out std_logic;
    
            data_in         : in  std_logic_vector (7 downto 0);
            buffer_empty    : out std_logic;
            write           : in  std_logic;
    
            data_out        : out std_logic_vector (7 downto 0);
            data_ready      : out std_logic;
            read            : in  std_logic
        );
    end component uart;

    signal direction_ll, direction_l_resett, direction_rr, direction_r_resett       : std_logic;
    signal count                                                                    : std_logic_vector(19 downto 0);
    signal reset_counter                                                            : std_logic;                         
    --Internal reset for counter and such
    signal sensors_out                                                              : std_logic_vector(2 downto 0);
    signal mine_detect_ctr, mine_detect_ds                                          : std_logic; 
    signal data_in, data_out                                                        : std_logic;
    signal ds_in_mid_s, read_s, data_ready_s, buffer_empty_s, write_s               : std_logic;
    signal ds_out_uart_in_s, DS_in_UART_out_s                                       : std_logic_vector(7 downto 0); 

 
begin
    -- external signal handling
        reset_counter <= reset;

    CRT: controller port map(
                                sensors_out     	=> sensors_out,                           
                                clk     		    => clk,
                                reset             	=> reset,
                                count_in     		=> count,
                                ctr_mine            => mine_detect_ctr,
                                ctr_data            => data_out,

                                count_reset     	=> reset_counter,
                                direction_l     	=> direction_ll,
                                direction_l_reset   => direction_l_resett,
                                direction_r     	=> direction_rr,
                                direction_r_reset   => direction_r_resett,
                                ctr_mine_out        => mine_detect_ds,
                                ctr_mid             => ds_in_mid_s
    );

    REG: eightbitregister port map(
                                clk                 => clk,
                                register_input      => data_in,
                                register_output     => data_out
    );

    DS: data_sender port map(      
                                clk                 => clk,
                                reset               => reset_counter,
                            -- tx          =>
                                DS_out_UART_in      =>  ds_out_uart_in_s,
                                buffer_empty        =>  buffer_empty_s,
                                write               =>  write_s,
                            -- rx      =>
                                DS_in_UART_out      =>  DS_in_UART_out_s,   
                                data_ready          =>  data_ready_s,
                                read                =>  read_s,
                            -- user in     =>
                                DS_in_mine          =>  mine_detect_ds,
                                DS_in_mid           =>  ds_in_mid_s,
                                DS_out              =>  data_in
    );    

    MD: Mine_detector port map (
                                clk                =>  clk,
                                square_in          =>  mine_square_in,
                                sensors_out        =>  sensors_out,

                                mine_out           =>  mine_detect_ctr
    );

    MCL: motorcontrol port map(
                                reset               => direction_l_resett,
                                direction           => direction_ll,
                                count_in            => count,
                                pwm                 => motor_l_pwm
    );

    MCR: motorcontrol port map(
                                reset               => direction_r_resett,
                                direction           => direction_rr,
                                count_in            => count,
                                pwm                 => motor_r_pwm
    );

    IB: inputbuffer port map(
                                sensor_l_in         => sensor_l_in,
                                sensor_m_in         => sensor_m_in,
                                sensor_r_in         => sensor_r_in,
                                clk                 => clk,
                                sensors_out         => sensors_out
    );

    TB: timebase port map(
                                clk                 => clk,
                                reset               => reset_counter,
                                count_out           => count
    );

    ua : UART port map(
                                clk                 => clk,
                                reset               => reset_counter,

                                rx                  =>  ro_rx,
                                tx                  =>  ro_tx,

                                data_in             => ds_out_uart_in_s,
                                buffer_empty        => buffer_empty_s,
                                write               => write_s,

                                data_out            => DS_in_UART_out_s,
                                data_ready          => data_ready_s,
                                read                => read_s
    );
    
    
end architecture structural;
