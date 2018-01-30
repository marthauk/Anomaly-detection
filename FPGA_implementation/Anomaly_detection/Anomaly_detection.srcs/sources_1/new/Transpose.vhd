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
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.std_logic_UNSIGNED.all;
USE ieee.numeric_std.all;
use IEEE.STD_LOGIC_1164.ALL;

library work;
use work.Common_types_and_functions.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Transpose is
-- pixel_n is index of pixel_looked at
    Port (   pixel_index :        in std_logic_vector(log2(sel(N_PIXELS))-1 downto 0);
           clk :            in std_logic ;
           M :              in  matrix (0 to sel(P_BANDS-1), 0 to sel(N_PIXELS-1));
           M_transpose :    out matrix (0 to 0, 0 to sel(P_BANDS)-1)
           );
end Transpose;

architecture Behavioral of Transpose is

signal M_matrix <= M(0 to P_BANDS-1, 0 to N_PIXELS-1);
--pixel_data <= M_matrix(:,pixel_n);
begin

    p_transpose : process(clk)
        for (i in 0 to P_BANDS-1) loop
            M_transpose(1,i) <= M_matrix(i,to_integer(signed(pixel_index)));                  
        end loop;
    end process p_transpose;


end Behavioral;
 