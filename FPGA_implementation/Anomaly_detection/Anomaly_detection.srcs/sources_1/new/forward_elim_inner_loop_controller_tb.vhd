-------------------------------------------------------------------------------
-- Title      : Testbench for design "forward_elim_inner_loop_controller"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : forward_elim_inner_loop_controller_tb.vhd
-- Author     :   <Martin@MARTIN-PC>
-- Company    : 
-- Created    : 2018-04-20
-- Last update: 2018-04-20
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-04-20  1.0      Martin  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.Common_types_and_functions.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;
library UNIMACRO;
use unimacro.Vcomponents.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;          --For file operations
use ieee.numeric_std.all;               --For unsigned numbers
use work.math_real.all;
use std.textio.all;
-------------------------------------------------------------------------------

entity forward_elim_inner_loop_controller_tb is

end entity forward_elim_inner_loop_controller_tb;

-------------------------------------------------------------------------------

architecture Beavioral of forward_elim_inner_loop_controller_tb is

  -- component ports
  signal reset_n             : std_logic;
  signal clk_en              : std_logic:='1';
  signal input_forward_elim  : input_elimination_reg_type;
  signal output_forward_elim : output_forward_elimination_reg_type;

  -- clock
  signal clk : std_logic := '1';

begin  -- architecture Beavioral

  -- component instantiation
  DUT : entity work.forward_elim_inner_loop_controller
    port map (
      clk                 => clk,
      reset_n             => reset_n,
      clk_en              => clk_en,
      input_forward_elim  => input_forward_elim,
      output_forward_elim => output_forward_elim);

  -- clock generation
  clk <= not clk after 5 ns;

  -- waveform generation
  WaveGen_Proc : process
    variable seed1, seed2 : positive;   -- Seed values for random generator 
    variable rand         : real;  -- Random real-number value in range 0 to 1.0
    variable rand2        : real;  -- Random real-number value in range 0 to 1.0
    variable int_rand     : integer;  -- Random integer value in range 0..4095 
    variable int_rand2    : integer;
    variable stim         : std_logic_vector(31 downto 0);  -- Random 16-bit stimulus
    variable stim2        : std_logic_vector(31 downto 0);  -- Random 16-bit stimulus

  begin
    -- insert signal assignments here
    for i in 0 to P_BANDS-1 loop
      UNIFORM(seed1, seed2, rand);      -- generate random number 
      UNIFORM(seed1, seed2, rand2);
      int_rand                    := integer(TRUNC(rand *256.0));  -- Convert to integer in range of 0 to 255
      int_rand2                   := integer(TRUNC(rand2 *256.0));  -- Convert to integer in range of 0 to 255
      stim                        := std_logic_vector(to_unsigned(int_rand, stim'length));  -- convert to                                                                   --std_logic_vector
      stim2                       := std_logic_vector(to_unsigned(int_rand2, stim'length));  -- convert to                                                                   --std_logic_vector
      input_forward_elim.row_j(i) <= signed(stim);
      input_forward_elim.row_i(i) <= signed(stim2);
      input_forward_elim.inv_row_i(i) <= signed(stim);
      input_forward_elim.inv_row_j(i) <= signed(stim2);
    end loop;
    input_forward_elim.state_reg.state <= STATE_FORWARD_ELIMINATION;
    input_forward_elim.state_reg.forward_elim_state_signal <= STATE_FORWARD_ELIM;
    input_forward_elim.index_i         <= 0;
    input_forward_elim.index_j         <= 1;
    input_forward_elim.valid_data      <= '1';
    reset_n<='1';



    wait for 1000ns;
  end process WaveGen_Proc;



end architecture Beavioral;

------------------------------------------------------------------------------
