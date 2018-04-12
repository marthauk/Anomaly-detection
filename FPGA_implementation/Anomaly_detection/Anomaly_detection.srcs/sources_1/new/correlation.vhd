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
           reset:   in std_logic;
           clk_en : in std_logic;
           pixel_index :        in std_logic_vector(log2(N_PIXELS) downto 0);
           out_corr_M : inout matrix_32 (0 to P_BANDS-1, 0 to P_BANDS-1);
           corr_finished: inout std_logic          
           );
end Correlation;

architecture Behavioral of Correlation is

signal M_transposed_matrix : matrix(0 to 0, 0 to P_BANDS-1);
signal M_pixel           : matrix (0 to P_BANDS-1, 0 to 0);

begin
-- transpose calculates the transpose of a matrix
    u1_transpose: entity work.Transpose
        port map( M => M,
                  M_transpose => M_transposed_matrix,
                  pixel_index => pixel_index,
                  clk => clk,
                  clk_en => clk_en
                  );
    p_correlate: process(clk,reset)
    variable count_signal_finish : integer:=0;
        begin
        if reset ='1' then
            out_corr_M <=(others=>(others=>(others=>'0')));
            corr_finished <='0';
            count_signal_finish := 0;
        elsif clk_en = '1' and rising_edge(clk) and corr_finished ='0' then
            for i in 0 to P_BANDS-1 loop
                for j in 0 to P_BANDS-1 loop
                    M_pixel(i,0)<=M(i,to_integer(unsigned(pixel_index)));
                    out_corr_M(i,j) <= std_logic_vector(to_signed(to_integer(signed(out_corr_M(i,j))) + to_integer(signed(M_pixel(i,0)))* to_integer(signed(M_transposed_matrix(0,j))),32));                
                end loop;
            end loop;
            if (to_integer(unsigned(pixel_index))>= N_PIXELS-1) and count_signal_finish>=1 then
                corr_finished <= '1';
            elsif (to_integer(unsigned(pixel_index))>= N_PIXELS-1) then 
                count_signal_finish := count_signal_finish +1;
            end if;
        end if;    
    end process p_correlate;
 

end Behavioral;
