----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/07/2018 02:19:19 PM
-- Design Name: 
-- Module Name: inverse_matrix - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.all;


library work;
use work.Common_types_and_functions.all;
use work.gauss_jordan_pkg.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- This entity is the top-level for computing the inverse of a matrix
-- It uses the two-step method, as described by Jiri Gaisler, with one modification;
-- added initialization process
entity inverse_matrix is
    Port ( M_corr :             in matrix_32 (0 to P_BANDS-1, 0 to P_BANDS-1);
           -- maybe generic ?
           start_inversion :    in std_logic;
           reset :              in std_logic;
           clk_en:              in std_logic;
           clk :                in std_logic;
           state :              in reg_state_type;
           ctrl_inversion :     inout std_logic_vector( 1 downto 0);
           M_inv :              inout matrix_32( 0 to P_BANDS-1, 0 to P_BANDS-1)
    );
    
end inverse_matrix;

architecture Behavioral of inverse_matrix is
signal M_identity_matrix : matrix_32 (0 to P_BANDS-1, 0 to P_BANDS-1);

signal r, r_in : matrix_32(0 to P_BANDS-1, 0 to P_BANDS-1);

begin

init:process    -- Initialization process; only to be runned once
begin
    M_identity_matrix <= (others=>(others=>(others=>'0')));
    for i in 0 to P_BANDS-1 loop
        M_identity_matrix(i,i) <= std_logic_vector(to_unsigned(1,32));
    end loop;
    wait;
 end process;


comb: process(state)       -- combinatorial process
begin
end process;




regs: process(clk, reset)
    begin
    if(reset = '1' ) then 
        ctrl_inversion <= (others=>'0');
        M_inv <= M_identity_matrix;
    elsif(clk_en ='1') then
        
    end if;

end process; 

end Behavioral;
