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

entity corr_tb is
--  Port ( );
end corr_tb;

architecture Behavioral of corr_tb is

-- device under test
component Correlation is 
port( M :               in matrix (0 to P_BANDS-1, 0 to N_PIXELS-1);
      clk :             in std_logic;
      reset :           in std_logic;
      pixel_index :     in std_logic_vector(log2(N_PIXELS) downto 0);
      out_corr_M :      inout matrix_32 (0 to P_BANDS-1, 0 to P_BANDS-1);
      clk_en :          in std_logic;
      corr_finished:    inout std_logic
      );
 end component;
-- inputs 

 signal M:              matrix(0 to P_BANDS-1, 0 to N_PIXELS-1);
 signal clk :           std_logic := '0';
 signal clk_en :           std_logic := '1';
 signal pixel_index :   std_logic_vector(log2(N_PIXELS) downto 0):= (others=>'0') ;
 signal ready   :       std_logic:='0';
 signal reset :         std_logic:='0';
 --outputs
signal out_corr_M :    matrix_32(0 to P_BANDS-1, 0 to P_BANDS-1);
signal corr_finished_s : std_logic ;--:='0';


constant CLK_PERIOD : time := 10 ns;
begin

    dut : Correlation port map(
           clk => clk,
           reset=> reset,
           clk_en => clk_en,
           M => M,
           pixel_index=> pixel_index,
           out_corr_M => out_corr_M,
           corr_finished=> corr_finished_s
           );

    -- clock process definition( clock with 50% duty cycle defined here)
    clk_process: process
    begin 
        clk <='0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process clk_process;           

    -- stimulus process
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
        M(0,0)<=std_logic_vector(to_unsigned(1,16));
        M(0,1)<=std_logic_vector(to_unsigned(3,16));
        M(0,2)<=std_logic_vector(to_unsigned(1,16));
        M(1,0)<=std_logic_vector(to_unsigned(2,16));
        M(1,1)<=std_logic_vector(to_unsigned(3,16));
        M(1,2)<=std_logic_vector(to_unsigned(2,16));

           ready <= '1';
           --pixel_index <= pixel_index + std_logic_vector(to_unsigned(1,log2(N_PIXELS)));
   --      end loop;
     --   end loop;
        wait for CLK_PERIOD *300;
    end process stim_proc;
    
   process(clk)
    begin
        if rising_edge(clk) and ready ='1'  then
            if (to_integer(unsigned(pixel_index)) < N_PIXELS-1) then
                pixel_index <=pixel_index + 1;
            end if;
        end if;
    end process;
end Behavioral;
