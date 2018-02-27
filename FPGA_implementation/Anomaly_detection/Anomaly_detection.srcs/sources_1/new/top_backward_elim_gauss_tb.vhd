-------------------------------------------------------------------------------
-- Title      : Testbench for design "top_backward_elim_gauss"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : top_backward_elim_gauss_tb.vhd<sources_1>
-- Author     :   <Martin@MARTIN-PC>
-- Company    : 
-- Created    : 2018-02-26
-- Last update: 2018-02-26
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-02-26  1.0      Martin	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity top_backward_elim_gauss_tb is

end entity top_backward_elim_gauss_tb;

-------------------------------------------------------------------------------

architecture Behavirol of top_backward_elim_gauss_tb is

  -- component ports
  signal clk    : std_logic;
  signal reset  : std_logic;
  signal clk_en : std_logic;
  signal M      : matrix_reg_type;

  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture Behavirol

  -- component instantiation
  DUT: entity work.top_backward_elim_gauss
    port map (
      clk    => clk,
      reset  => reset,
      clk_en => clk_en,
      M      => M);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here

    wait until Clk = '1';
  end process WaveGen_Proc;

  

end architecture Behavirol;

-------------------------------------------------------------------------------

configuration top_backward_elim_gauss_tb_Behavirol_cfg of top_backward_elim_gauss_tb is
  for Behavirol
  end for;
end top_backward_elim_gauss_tb_Behavirol_cfg;

-------------------------------------------------------------------------------
