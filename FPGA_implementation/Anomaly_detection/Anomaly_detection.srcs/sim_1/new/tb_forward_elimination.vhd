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
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

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

signal 	clk :                           std_logic			:='0';
signal  reset :                         std_logic			:='0';
signal  clk_en :                        std_logic			:='0';

signal M :  							matrix_reg_type := C_MATRIX_REG_TYPE_INIT;
signal M_forward_elimination :  		matrix_reg_type := C_MATRIX_REG_TYPE_INIT;

--signal M :								matrix_reg_type := ((others=>(others=>(others=>'0'))), (others=>(others=>(others=>'0'))));
--signal M_forward_elimination :			matrix_reg_type := ((others=>(others=>(others=>'0'))), (others=>(others=>(others=>'0'))));

--signal  M :                             matrix_reg_type;
--signal  M_forward_elimination :         matrix_reg_type; 

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
      	     M.matrix(0,0)<=std_logic_vector(to_unsigned(1,16));
             M.matrix(0,1)<=std_logic_vector(to_unsigned(3,16));
             M.matrix(0,2)<=std_logic_vector(to_unsigned(1,16));
             M.matrix(1,0)<=std_logic_vector(to_unsigned(2,16));
             M.matrix(1,1)<=std_logic_vector(to_unsigned(3,16));
             M.matrix(1,2)<=std_logic_vector(to_unsigned(2,16));
           
          wait for CLK_PERIOD *300;
      end process stim_proc;
      


end Behavioral;
