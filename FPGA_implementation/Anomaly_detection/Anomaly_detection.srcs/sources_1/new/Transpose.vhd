----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/29/2018 01:22:56 PM
-- Design Name: 
-- Module Name: Transpose - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Common_types_and_functions.all

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Transpose is
 
    Port ( 
           -- pixel_n is index of pixel_looked at
           pixel_n :        in integer;
           clk :            in std_logic ;
           M :              in  matrix (0 to p_bands-1, 0 to N_pixels-1);
           M_transpose :    out matrix (1, 0 to p_bands -1);
           );
end Transpose;

architecture Behavioral of Transpose is

signal M_matrix <= M(0 to p_bands-1, 0 to N_pixels-1);

--pixel_data <= M_matrix(:,pixel_n);
begin

    p_transpose : process
        for i in 0 to p_bands-1 loop;
            M_transpose(1,i) <= M_matrix(i,pixel_n);                  
        end loop;
    end process p_transpose;


end Behavioral;
