library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity robot is
    port (
        clk             :in std_logic;
        reset           :in std_logic;
        
        sensor_l_in     :in std_logic;  
        sensor_m_in     :in std_logic;       
        sensor_r_in     :in std_logic;

        motor_l_pwm     :out std_logic;
        motor_r_pwm     :out std_logic       
        
    );
end entity robot;

architecture structural of robot is
    component motorcontrol is
        port (
        reset			: in	std_logic;
        direction		: in	std_logic;
        count_in		: in	std_logic_vector (19 downto 0);
        pwm			: out	std_logic :='1'
        );
    end component motorcontrol;

    component inputbuffer is
        port(
            sensor_l_in         :in std_logic;
            sensor_m_in         :in std_logic; 
            sensor_r_in         :in std_logic;
            clk                 :in std_logic;
            sensors_out         :out std_logic_vector(2 downto 0)
        );
    end component inputbuffer;
    
    component controller is
        port (
        sensors_out	: in 	std_logic_vector (2 downto 0); 
	clk	        : in 	std_logic;
	reset	    	: in 	std_logic;
        count_in    	: in    std_logic_vector (19 downto 0);
        count_reset 	: out    std_logic;

        direction_l	      : out std_logic;	
        direction_l_reset : out std_logic;
        direction_r       : out std_logic;
        direction_r_reset : out std_logic
        );
    end component controller;

    component timebase is
        port(
            clk         :in std_logic;
            reset       :in std_logic;
            count_out   :out std_logic_vector(19 downto 0)
        );
    end component timebase;

    signal direction_ll, direction_l_resett, direction_rr, direction_r_resett        :std_logic;
    signal count                            :std_logic_vector(19 downto 0);
    signal reset_counter                          :std_logic;                         --Internal reset for counter and such
    signal sensors_out                      :std_logic_vector(2 downto 0);

begin

    MCL: motorcontrol port map(
                                reset           =>  direction_l_resett,
                                direction       =>  direction_ll,
                                count_in        =>  count,
                                pwm             =>  motor_l_pwm
    );

    MCR: motorcontrol port map(
                                reset           =>  direction_r_resett,
                                direction       =>  direction_rr,
                                count_in        =>  count,
                                pwm             =>  motor_r_pwm
    );

    IB: inputbuffer port map(
                                sensor_l_in     =>  sensor_l_in,
                                sensor_m_in     =>  sensor_m_in,
                                sensor_r_in     =>  sensor_r_in,
                                clk             =>  clk,
                                sensors_out     =>  sensors_out
    );

    CT: controller port map(
                                clk     		=>  clk,
                                reset             	=>  reset,
                                count_in     		=>  count,
                                count_reset     	=>  reset_counter,
                                direction_l     	=>  direction_ll,
                                direction_l_reset       =>  direction_l_resett,
                                direction_r     	=>  direction_rr,
                                direction_r_reset     	=>  direction_r_resett,
				sensors_out     	=>  sensors_out
    );

    TB: timebase port map(
                                clk             => clk,
                                reset           => reset_counter,
                                count_out       => count
    );
end architecture structural;
