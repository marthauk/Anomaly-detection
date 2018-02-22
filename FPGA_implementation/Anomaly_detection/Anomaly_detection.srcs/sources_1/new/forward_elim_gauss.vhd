----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/17/2018 03:09:31 PM
-- Design Name: 
-- Module Name: forward_elim_gauss - Behavioral
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

entity forward_elim_gauss is
  Port (    clk :                           in std_logic;
            reset :                         in std_logic;
            clk_en :                        in std_logic;
            M :                             in matrix_reg_type;
            M_forward_elimination :         out matrix_reg_type); 
end forward_elim_gauss;

architecture Behavioral of forward_elim_gauss is

signal r, r_in : matrix_reg_type; --cointains all registered values 

begin 

--comb: process(M,r,reset)
comb: process(all)
variable v: matrix_reg_type;	
-- temporary variables
--variable A_row_i_temp : matrix_32( 0 to 0, 0 to P_BANDS-1 );
--variable A_j_i_temp :   std_logic_vector(0 to 31);
--variable A_i_i_temp :   std_logic_vector(0 to 31);

begin
    v:= r;
    --v.matrix := M.matrix;
    --v.matrix_inv := M.matrix_inv;
    for i in 0 to P_BANDS-1 loop
        if(M.matrix(i,i) = std_logic_vector(to_unsigned(0,32))) then
                for j in i+1 to P_BANDS-1 loop
                    if(M.matrix(j,j) = std_logic_vector(to_unsigned(0,32))) then
                        for k in 0 to P_BANDS-1 loop	
                        	v.matrix(i,k) := M.matrix(j,k);
                        	v.matrix(j,k) := M.matrix(i,k);
                        end loop;
                    end if;
                end loop;
        end if;
       if (M.matrix(i,i) = std_logic_vector(to_unsigned(0,32))) then
			--matrix is singular, output some kind of error      
       end if;
        for p in i+1 to P_BANDS-1 loop
        	for l in 0 to P_BANDS-1 loop
        		v.matrix(p,l) := std_logic_vector(to_signed(to_integer(signed(M.matrix(p,l)))- to_integer(signed(M.matrix(i,l)))*to_integer(signed(M.matrix(p,i)))/to_integer(signed(M.matrix(i,i))),32));
        		v.matrix_inv(p,l) := std_logic_vector(to_signed(to_integer(signed(M.matrix_inv(p,l)))- to_integer(signed(M.matrix_inv(i,l)))*to_integer(signed(M.matrix(p,i)))/to_integer(signed(M.matrix(i,i))),32));
        	end loop;
        end loop;     
    end loop;
    if (reset ='1') then
       	v.matrix := (others=>(others=>(others=>'0')));
     	v.matrix_inv := (others=>(others=>(others=>'0')));
    end if;
    r_in <= v;
    M_forward_elimination.matrix <= r.matrix;
	M_forward_elimination.matrix_inv <= r.matrix_inv;      
    
end process;

sequential_process: process(clk, clk_en)
begin
    if(rising_edge(clk) and clk_en='1') then
        r <= r_in;
    end if;
end process;



end Behavioral;
