library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pmodALS is
    Port ( 
        clk : in  STD_LOGIC;                     -- Ceasul principal
        nc : out  STD_LOGIC;                     -- mosi/not connected
        cs : out STD_LOGIC;                      -- Chip Select pentru SPI
        sck : out STD_LOGIC;                     -- Serial Clock pentru SPI
        sdo : in  STD_LOGIC;                     -- Serial Data Output (MISO) de la ALS
        senz_data : out STD_LOGIC_VECTOR (7 downto 0)  -- LEDuri pentru afisarea valorii de lumina
    );
end pmodALS;


architecture Behavioral of pmodAlS is
    -- Constants
    constant CLK_DIV : integer := 49;       -- pt a avea 2 Mhz trebe sa impartim la 50 (sa numaram pana la 49)

    -- Signals
    signal counter_clk : integer range 0 to CLK_DIV + 1 := 0; -- clock divider counter
    signal clk2mhz : STD_LOGIC := '0'; 
    signal cs_int : STD_LOGIC := '1';                     -- pt activarea senzorului
    signal data_als : STD_LOGIC_VECTOR(15 downto 0) := (others => '0'); -- registru in care retinem bitii cititi de la senzor
    signal biti_cititi : integer range 0 to 16 := 0;        --de la senzor

begin

    -- Clock Generation
    process(clk)
    begin
        if rising_edge(clk) then
            if counter_clk = CLK_DIV then
                counter_clk <= 0;
                clk2mhz <= not clk2mhz;
            else
                counter_clk <= counter_clk + 1;
            end if;
        end if;
    end process;

    -- SPI Communication Process
process(clk2mhz)

begin

if rising_edge(clk2mhz) then
    if cs_int='0' then
        if biti_cititi < 15  then -- citim MISO
            data_als(14-biti_cititi) <= SDO;
            biti_cititi <= biti_cititi + 1;
        else
            cs_int <= '1'; -- Deselect the sensor
            biti_cititi <= 0;
        end if;
             
     else      
        cs_int <= '0'; -- Start new communication
    end if;
end if;
    
end process;


   
sck <= clk2mhz;                                     -- SPI clock output
cs <= cs_int;                                       -- Chip select output
senz_data <= data_als(11 downto 4) when cs_int='1'; -- Extract the 8-bit light value (bits 4-11)
--senz_data(0)<=cs_int;  
--senz_data(1)<=clk2mhz;  
--senz_data(2)<=sdo;  

end Behavioral;
