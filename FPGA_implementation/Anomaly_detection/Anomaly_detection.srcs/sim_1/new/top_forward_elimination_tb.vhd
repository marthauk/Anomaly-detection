-------------------------------------------------------------------------------
-- Title      : Testbench for design "top_forward_elimination"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : top_forward_elimination_tb.vhd
-- Author     :   <Martin@MARTIN-PC>
-- Company    : 
-- Created    : 2018-03-06
-- Last update: 2018-03-06
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-03-06  1.0      Martin	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.Common_types_and_functions.all;

-------------------------------------------------------------------------------

entity top_forward_elimination_tb is

end entity top_forward_elimination_tb;

-------------------------------------------------------------------------------

architecture behavioral of top_forward_elimination_tb is

  -- component ports
  signal clk            : std_logic:= '1';
  signal reset          : std_logic;
  signal clk_en         : std_logic;
  signal M              : matrix_reg_type;
  signal M_forward_elim : matrix_reg_type;

  -- clock

begin  -- architecture behavioral

  -- component instantiation
  DUT: entity work.top_forward_elimination
    port map (
      clk            => clk,
      reset          => reset,
      clk_en         => clk_en,
      M              => M,
      M_forward_elim => M_forward_elim);

  -- clock generation
  Clk <= not Clk after 5 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here


    reset <= '1';
    wait for 20 ns;
    reset <= '0';
    wait for 10 ns;
    clk_en<='1';
    M.state_reg.state <= STATE_FORWARD_ELIMINATION;
    M.state_reg.fsm_start_signal <= START_FORWARD_ELIMINATION;
    M.state_reg.drive <= STATE_IDLE_DRIVE;
    M.valid_matrix_data <= '1';
    
    M.matrix(0, 0) <= std_logic_vector(to_unsigned(1, 32));
    M.matrix(0, 1) <= std_logic_vector(to_unsigned(3, 32));
    M.matrix(0, 2) <= std_logic_vector(to_unsigned(1, 32));
    
    M.matrix(1, 0) <= std_logic_vector(to_unsigned(2, 32));
    M.matrix(1, 1) <= std_logic_vector(to_unsigned(3, 32));
    M.matrix(1, 2) <= std_logic_vector(to_unsigned(2, 32));

    M.matrix(2, 0) <= std_logic_vector(to_unsigned(6, 32));
    M.matrix(2, 1) <= std_logic_vector(to_unsigned(8, 32));
    M.matrix(2, 2) <= std_logic_vector(to_unsigned(7, 32));
    -- 

    M.matrix_inv(0, 0) <= std_logic_vector(to_unsigned(1, 32));
    M.matrix_inv(0, 1) <= std_logic_vector(to_unsigned(0, 32));
    M.matrix_inv(0, 2) <= std_logic_vector(to_unsigned(0, 32));
    M.matrix_inv(1, 0) <= std_logic_vector(to_unsigned(0, 32));
    M.matrix_inv(1, 1) <= std_logic_vector(to_unsigned(1, 32));
    M.matrix_inv(1, 2) <= std_logic_vector(to_unsigned(0, 32));
    M.matrix_inv(2, 0) <= std_logic_vector(to_unsigned(0, 32));
    M.matrix_inv(2, 1) <= std_logic_vector(to_unsigned(0, 32));
    M.matrix_inv(2, 2) <= std_logic_vector(to_unsigned(1, 32));
    wait for 10 ns;
    M.state_reg.fsm_start_signal <= STATE_IDLE_DRIVE;
    wait for 300 ns;
  end process WaveGen_Proc;

  

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
  

end architecture behavioral;

-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
