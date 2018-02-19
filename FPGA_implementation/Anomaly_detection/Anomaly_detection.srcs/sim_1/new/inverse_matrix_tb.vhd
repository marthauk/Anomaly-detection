----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/17/2018 10:58:07 AM
-- Design Name: 
-- Module Name: inverse_matrix_tb - Behavioral
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

entity inverse_matrix_tb is
--  Port ( );
end inverse_matrix_tb;

architecture Behavioral of inverse_matrix_tb is

component inverse_matrix is 
Port ( M_corr :             in matrix_32 (0 to P_BANDS-1, 0 to P_BANDS-1);
           start_inversion :    in std_logic;
           reset :              in std_logic;
           clk_en:              in std_logic;
           clk :                in std_logic;
           --inouts
           ctrl_inversion :     inout std_logic_vector( 1 downto 0);
           M_inv :              inout matrix_32( 0 to P_BANDS-1, 0 to P_BANDS-1)
    );
end component;
-- inputs
signal M_corr:              matrix_32(0 to P_BANDS-1, 0 to P_BANDS-1);
signal start_inversion:     std_logic := '0';
signal reset :              std_logic:='0';
signal clk :                std_logic := '0';
signal clk_en :             std_logic := '1';

--inouts
signal ctrl_inversion : std_logic_vector(1 downto 0) :=(others=>'0');
signal M_inv :    matrix_32(0 to P_BANDS-1, 0 to P_BANDS-1);


constant CLK_PERIOD : time := 10 ns;

begin
dut : inverse_matrix port map(
           clk => clk,
           reset=> reset,
           clk_en => clk_en,
           M_corr => M_corr,
           M_inv=> M_inv,
           start_inversion=>start_inversion,
           ctrl_inversion=> ctrl_inversion
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
