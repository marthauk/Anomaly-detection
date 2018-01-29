----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/29/2018 01:14:20 PM
-- Design Name: 
-- Module Name: correlation - Behavioral
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

entity Correlation is
    -- Generics are used for this correlation matrix module in order for the module to be usable in the future for new types of Hyperspectral imagers
    -- Assingning default values to the variables. k is the size of the kernel, if LRX is to be implemented. Default is  ACAD
    generic ( N_pixels : positive :=    2578;
              p_bands  : positive :=    100;
              k        : positive :=    0);
            
    Port ( M : in matrix (0 to p_bands-1, 0 to N_pixels-1);
           -- pixel_n is the index of the pixel to correlate
           clk : in std_logic; 
           pixel_n : in integer;
           out_corr_M : out matrix (0 to p_bands-1, 0 to p_bands -1));
end Correlation;

architecture Behavioral of Correlation is

signal M_matrix <= M(0 to p_bands-1, 0 to N_pixels-1);
signal pixel_data <= std_logic_vector(pixel_data_size downto 0);
signal M_transposed_matrix : matrix;
begin

-- in Matlab : corr_M = M(:, pixel_n)* M(:, pixel_n).';
    u1_transpose: entity.work.Transpose
        port map( M => M_matrix,
                  M_transpose => M_transposed_matrix,
                  pixel_n => pixel_n,
                  clk => clk);

    p_correlate: process(clk)
        for i in 0 to p_bands-1 loop;
            for j in 0 to p_bands-1 loop;
                out_corr_M(i,j) <= M_matrix(i,pixel_n) * M_transposed_matrix(1,j);
            end loop;
        end loop;    
    end process p_correlate;

        

end Behavioral;
