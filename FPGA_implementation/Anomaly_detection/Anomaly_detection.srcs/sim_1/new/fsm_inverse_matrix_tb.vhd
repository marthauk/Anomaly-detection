-------------------------------------------------------------------------------
-- Title      : Testbench for design "fsm_inverse_matrix"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : fsm_inverse_matrix_tb.vhd
-- Author     :   <Martin@MARTIN-PC>
-- Company    : 
-- Created    : 2018-03-08
-- Last update: 2018-03-08
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-03-08  1.0      Martin  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
library work;
use work.Common_types_and_functions.all;

-------------------------------------------------------------------------------

entity fsm_inverse_matrix_tb is

end entity fsm_inverse_matrix_tb;

-------------------------------------------------------------------------------

architecture Behavioral of fsm_inverse_matrix_tb is

  -- component ports
  signal reset           : std_logic:='1';
  signal clk             : std_logic;
  signal clk_en          : std_logic;
  signal start_inversion : std_logic;
  signal drive           : std_logic_vector(2 downto 0);
  signal state_reg       : reg_state_type;

  -- clock

begin  -- architecture Behavioral

  -- component instantiation
  DUT : entity work.fsm_inverse_matrix
    port map (
      reset           => reset,
      clk             => clk,
      clk_en          => clk_en,
      start_inversion => start_inversion,
      drive           => drive,
      state_reg       => state_reg);

  -- clock generation
  clk <= not clk after 5 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin

    reset           <= '1';
    wait for 20 ns;
    reset           <= '0';
    wait for 10 ns;
    clk_en          <= '1';
    start_inversion <= '1';
    wait for 10 ns;
    start_inversion <= '0';
    wait for 30 ns;
    drive <= STATE_FORWARD_ELIMINATION_FINISHED;
    wait for 30 ns;
    drive <= STATE_BACKWARD_ELIMINATION_FINISHED;
    wait for 30 ns;
    drive <= STATE_IDENTITY_MATRIX_BUILDING_FINISHED;
    wait for 200ns;

  end process WaveGen_Proc;



end architecture Behavioral;

