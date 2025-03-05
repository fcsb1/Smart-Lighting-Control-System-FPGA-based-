library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity led_control_system is
    Port ( 
        sw : in std_logic_vector (15 downto 0);    -- switch input pt debug (constraints file)
        led : out std_logic_vector (15 downto 0);  -- LED output
        clk : in  STD_LOGIC;
        JA : inout  STD_LOGIC_VECTOR (7 downto 0); --7 downto 4= row, 3 downto 0=col
        nc : out  STD_LOGIC;                     -- mosi/not connected
        cs : out STD_LOGIC;                      -- Chip Select pentru SPI
        sck : out STD_LOGIC;                     -- Serial Clock pentru SPI
        sdo : in  STD_LOGIC;                     -- Serial Data Output (MISO) de la ALS
        pwm_out: out std_logic                  --ledul fizic conectat in exteriorul placii
    );
end led_control_system;


architecture Behavioral of led_control_system is

component pmodALS is
    Port ( 
        clk : in  STD_LOGIC;                     -- Ceasul principal
        nc : out  STD_LOGIC;                     -- mosi/not connected
        cs : out STD_LOGIC;                      -- Chip Select pentru SPI
        sck : out STD_LOGIC;                     -- Serial Clock pentru SPI
        sdo : in  STD_LOGIC;                     -- Serial Data Output (MISO) de la ALS
        senz_data : out STD_LOGIC_VECTOR (7 downto 0)  -- valoarea citita de senzor pe 8 biti
    );
end component;

signal counter_pwm: std_logic_vector(7 downto 0):=(others=>'0');
signal old_als_data: std_logic_vector(7 downto 0):=(others=>'0');
signal als_data: std_logic_vector(7 downto 0);
signal pwm_new: std_logic;
signal pwm_old: std_logic;

begin    

ja(3 downto 0)<="0000";--citim de pe toate coloanele    

    -- Procesul PWM
process(clk)
    begin
        if rising_edge(clk) then
            counter_pwm <= counter_pwm + 1; -- Incrementam contorul PWM
            
            -- Comparam contorul PWM cu pragul pentru a decide valoarea iesirii PWM
            if counter_pwm < als_data then --pt debug
                pwm_new <= '1'; -- Daca contorul este mai mic decat pragul, semnalul este pe 1
            else
                pwm_new <= '0'; -- Daca nu, semnalul este pe 0
            end if;
            
            if counter_pwm < old_als_data then
                pwm_old <= '1'; -- Daca contorul este mai mic decat pragul, semnalul este pe 1
            else
                pwm_old <= '0'; -- Daca nu, semnalul este pe 0
            end if;
            
        end if;
end process;
        
 --proces pt actualizarea intensitatii ledului
process (clk)
begin
 if rising_edge(clk) then 
     if ja(7)='0' then 
         old_als_data<=als_data;
     else
         old_als_data<=old_als_data;
         
     end if;
 end if;
 
end process;
    
als: pmodALS port map(clk,nc,cs,sck,sdo,als_data);
    
led(11)<=pwm_new;--led ce nu trebuie actualizat pt debug
led(13)<=pwm_old;--ledul principal
pwm_out<=pwm_old;--ledul exterior
led (7 downto 0)<=als_data;--val intensitatii luminii primita de la senzor
      
end Behavioral;
