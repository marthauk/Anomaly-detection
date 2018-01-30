----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/30/2018 10:54:04 AM
-- Design Name: 
-- Module Name: Correlation_testbench - Behavioral
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

entity Correlation_testbench is
--  Port ( );
end Correlation_testbench;

architecture Behavioral of Correlation_testbench is

-- device under test
component Correlation is 
port( M :           in matrix (0 to P_BANDS-1, 0 to N_PIXELS-1);
      clk :         in std_logic;
      pixel_index : in std_logic_vector(log2(N_PIXELS)-1 downto 0);
      out_corr_M :  out matrix (0 to P_BANDS-1, 0 to P_BANDS-1)
      );
 end component;
-- inputs 

 signal M:              matrix(0 to P_BANDS-1, 0 to N_PIXELS-1);
 signal clk :           std_logic := '0';
 signal pixel_index :   std_logic_vector(log2(N_PIXELS)-1 downto 0);
 
 --outputs
signal out_corr_M :    matrix(0 to P_BANDS-1, 0 to P_BANDS-1);

constant CLK_PERIOD : time := 10 ns;
begin

    dut : Correlation port map(
           clk => clk,
           M => M,
           pixel_index=> pixel_index,
           out_corr_M => out_corr_M
           );
           


end Behavioral;
