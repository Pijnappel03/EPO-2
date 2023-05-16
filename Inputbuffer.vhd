library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity inputbuffer is
    port(
        sensor_l_in         :in std_logic;
        sensor_m_in         :in std_logic; 
        sensor_r_in         :in std_logic;
        clk                 :in std_logic;
        sensors_out         :out std_logic_vector(2 downto 0)
    );
end entity inputbuffer;

architecture structural of inputbuffer is
    component threebitregister is
        port(   input       :in std_logic_vector(2 downto 0);
                clk         :in std_logic;

                output      :out std_logic_vector(2 downto 0)
        );
    end component threebitregister;

    signal input, inter, output     :std_logic_vector(2 downto 0);

begin
    input(2)        <= sensor_l_in ;     
    input(1)        <= sensor_m_in ;     
    input(0)        <= sensor_r_in ; 

    sensors_out     <= output;
    
    R1: threebitregister port map(
        input   =>      input,
        clk     =>      clk,
        output  =>      inter
    );

    R2: threebitregister port map(
        input   =>      inter,
        clk     =>      clk,
        output  =>      output
    );

    

end architecture structural;
