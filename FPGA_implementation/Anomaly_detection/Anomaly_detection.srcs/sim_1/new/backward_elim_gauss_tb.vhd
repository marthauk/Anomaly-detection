-------------------------------------------------------------------------------
-- Title      : Testbench for design "backward_elim_gauss"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : backward_elim_gauss_tb.vhd
-- Author     :   <Martin@MARTIN-PC>
-- Company    : 
-- Created    : 2018-02-25
-- Last update: 2018-02-25
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-02-25  1.0      Martin  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;

-------------------------------------------------------------------------------

entity backward_elim_gauss_tb is

end entity backward_elim_gauss_tb;

-------------------------------------------------------------------------------

architecture behavioral of backward_elim_gauss_tb is

  -- component ports
  signal clk               : std_logic:='0';
  signal reset             : std_logic;
  signal clk_en            : std_logic;
  signal row               : row_reg_type;
  signal backward_elim_row : row_reg_type;


begin  -- architecture behavioral

  -- component instantiation
  DUT : entity work.backward_elim_gauss
    port map (
      clk               => clk,
      reset             => reset,
      clk_en            => clk_en,
      row               => row,
      backward_elim_row => backward_elim_row);

  -- clock generation
  clk <= not clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    reset<= '1';
    clk_en <='1';
    wait for 20 ns;

    row.row_j(0, 0) <= std_logic_vector(to_unsigned(5, 32));
    row.row_j(0, 1) <= std_logic_vector(to_unsigned(7, 32));
    row.row_j(0, 2) <= std_logic_vector(to_unsigned(3, 32));

    row.row_i(0, 0) <= std_logic_vector(to_unsigned(2, 32));
    row.row_i(0, 1) <= std_logic_vector(to_unsigned(4, 32));
    row.row_i(0, 2) <= std_logic_vector(to_unsigned(2, 32));
    
    row.inv_row_j(0, 0) <= std_logic_vector(to_unsigned(5, 32));
    row.inv_row_j(0, 1) <= std_logic_vector(to_unsigned(7, 32));
    row.inv_row_j(0, 2) <= std_logic_vector(to_unsigned(3, 32));
     
    row.inv_row_i(0, 0) <= std_logic_vector(to_unsigned(2, 32));
    row.inv_row_i(0, 1) <= std_logic_vector(to_unsigned(4, 32));
    row.inv_row_i(0, 2) <= std_logic_vector(to_unsigned(2, 32));

    row.a_j_i <= std_logic_vector(to_unsigned(3,32));
    row.a_i_i <= std_logic_vector(to_unsigned(2,32));


    reset <= '0';
    row.valid_data <= '1';
    
              wait until Clk = '1';
  wait for 400 ns;
              end process WaveGen_Proc;



              end architecture behavioral;

-------------------------------------------------------------------------------

              configuration backward_elim_gauss_tb_behavioral_cfg of backward_elim_gauss_tb is
                              for behavioral
                                            end for;
                                            end backward_elim_gauss_tb_behavioral_cfg;

-------------------------------------------------------------------------------
