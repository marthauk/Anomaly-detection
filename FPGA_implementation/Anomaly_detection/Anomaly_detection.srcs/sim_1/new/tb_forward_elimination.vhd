----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/19/2018 02:14:49 PM
-- Design Name: 
-- Module Name: tb_forward_elimination - Behavioral
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
library work;
use work.Common_types_and_functions.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tb_forward_elimination is
--  Port ( );
end tb_forward_elimination;

architecture Behavioral of tb_forward_elimination is
component forward_elim_gauss is
  Port (    clk :                           in std_logic;
            reset :                         in std_logic;
            clk_en :                        in std_logic;
            M :                             in matrix_reg_type;
            M_forward_elimination :         out matrix_reg_type); 
end component;

signal 	clk :                           std_logic;
signal  reset :                         std_logic;
signal  clk_en :                        std_logic;
signal  M :                             matrix_reg_type;
signal  M_forward_elimination :         matrix_reg_type; 

constant CLK_PERIOD : time := 10 ns;

begin
dut : forward_elim_gauss port map(
           clk => clk,
           reset=> reset,
           clk_en => clk_en,
           M => M,
           M_forward_elimination=> M_forward_elimination
           );

    -- clock process definition( clock with 50% duty cycle defined here)
    clk_process: process
    begin 
        clk <='0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process clk_process;           
    
  stim_proc: process
      begin
          clk_en <= '1';
          reset <='1';
          wait for CLK_PERIOD * 2;
          reset<='0';        
          wait for CLK_PERIOD *2;
          --for i in 0 to P_BANDS-1 loop
            --for j in 0 to N_PIXELS-1 loop   
            -- M(i,j) <= std_logic_vector(to_unsigned(j,16));
       
  
             reset <= '1';
             --pixel_index <= pixel_index + std_logic_vector(to_unsigned(1,log2(N_PIXELS)));
     --      end loop;
       --   end loop;
          wait for CLK_PERIOD *300;
      end process stim_proc;
      


end Behavioral;
