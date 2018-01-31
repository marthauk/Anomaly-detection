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
USE ieee.numeric_std.all;


library work;
use work.Common_types_and_functions.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Correlation is
    Port ( M : in matrix (0 to P_BANDS-1, 0 to N_PIXELS-1);
           clk : in std_logic;
           pixel_index :        in std_logic_vector(log2(N_PIXELS)-1 downto 0);
           out_corr_M : out matrix_32 (0 to P_BANDS-1, 0 to P_BANDS-1)
           );
end Correlation;

architecture Behavioral of Correlation is

signal M_transposed_matrix : matrix(0 to 0, 0 to P_BANDS-1);
signal A_factor            : std_logic_vector(15 downto 0);
signal B_factor            : std_logic_vector(15 downto 0);
signal P_output            : std_logic_vector(31 downto 0);

COMPONENT mult_gen_0
  PORT (
    CLK : IN STD_LOGIC;
    A : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    B : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    CE : IN STD_LOGIC;
    P : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
END COMPONENT;

begin

    u1_transpose: entity work.Transpose
        port map( M => M,
                  M_transpose => M_transposed_matrix,
                  pixel_index => pixel_index,
                  clk => clk
                  );

    p_correlate: process(clk)
        begin
        for i in 0 to P_BANDS-1 loop
            for j in 0 to P_BANDS-1 loop
                --mult <= std_logic_vector(to_signed(to_integer(signed(M(i,to_integer(unsigned(pixel_index)))))* to_integer((signed(M_transposed_matrix(0,j)))),16));
                -- elements of out_corr need maybe to be of size 31:0, due to the product A[15:0]*B[15:0] may be 32 bit. 
                --out_corr_M(i,j)<= std_logic_vector(to_signed(to_integer(signed(M(i,to_integer(unsigned(pixel_index)))))* to_integer((signed(M_transposed_matrix(0,j)))),16));
                A_factor <= M(i,to_integer(unsigned(pixel_index)));
                B_factor <= M_transposed_matrix(0,j);
                -- maybe indexes need to be i-1 and j-1. 
                out_corr_M(i,j) <= P_output;
                --out_corr_M(i,j) <= 
                --out_corr_M(i,j) <= signed(M(i,to_integer(unsigned(pixel_index)))))* (signed(M_transposed_matrix(1,j)));
            end loop;
       end loop;    
    end process p_correlate;
    
multiplier : mult_gen_0
      PORT MAP (
        CLK => clk,
        A => A_factor,
        B => B_factor,
        CE => CE,
        P => P_output
      );
        

end Behavioral;
