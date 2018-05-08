-------------------------------------------------------------------------------
-- Title      : Testbench for design "top_last_division"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : top_last_division_tb.vhd
-- Author     :   <Martin@MARTIN-PC>
-- Company    : 
-- Created    : 2018-04-27
-- Last update: 2018-04-27
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-04-27  1.0      Martin	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.Common_types_and_functions.all;
library UNISIM;
use UNISIM.vcomponents.all;
library UNIMACRO;
use unimacro.Vcomponents.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;          --For file operations
use ieee.numeric_std.all;               --For unsigned numbers
--use ieee.math_real.all;                 --For random number generation
use work.math_real.all;
use std.textio.all;


entity top_last_division_tb is

end entity top_last_division_tb;

-------------------------------------------------------------------------------

architecture Behavioral of top_last_division_tb is

  -- component ports
  signal reset_n              : std_logic:='1';
  signal clk_en               : std_logic:='1';
  signal input_last_division  : input_last_division_reg_type;
  signal output_last_division : output_last_division_reg_type;

  -- clock
  signal clk : std_logic := '1';
 signal din_row_i : row_array;
 signal din_inv_row_i : row_array;
  
  file file_VECTORS : text;
  file file_RESULTS : text;
  constant c_WIDTH  : natural := 4;
begin  -- architecture Behavioral

  -- component instantiation
  DUT: entity work.top_last_division
    port map (
      clk                  => clk,
      reset_n              => reset_n,
      clk_en               => clk_en,
      input_last_division  => input_last_division,
      output_last_division => output_last_division);

  -- clock generation
  clk <= not clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
    type t_logic_vector_array is array(0 to P_BANDS-1) of std_logic_vector(31 downto 0);
-- Contains one row of matrix data
    variable v_ILINE         : line;
    variable v_data_read     : t_logic_vector_array;
    variable v_OLINE         : line;
    variable row_counter     : integer := 0;
    variable element_counter : integer := 0;
    variable test            : std_logic_vector(7 downto 0);
    variable v_SPACE         : character;
    variable din_1           : row_array;
    variable din_2           : row_array;
    variable line_in         : std_logic_vector(PIXEL_DATA_WIDTH*2*P_BANDS-1 downto 0);
    variable line_counter    : integer := 0;
  begin

    file_open(file_VECTORS, "input_matrix_negative_divisor.txt", read_mode);
    while not endfile(file_VECTORS) loop
      readline(file_VECTORS, v_ILINE);
      while element_counter <= P_BANDS-1 loop
        hread(v_ILINE, v_data_read(element_counter));
        read(v_ILINE, v_SPACE);
        element_counter := element_counter+1;
      end loop;
      for k in 0 to P_BANDS-1 loop
        if line_counter <= 0 then
          din_1(k) :=signed(v_data_read(k));
        elsif line_counter =1 then
          din_2(k) :=signed(v_data_read(k));
        end if;
      end loop;
      line_counter    := line_counter+1;
      element_counter := 0;
    end loop;
    din_row_i <= din_1;
    din_inv_row_i <= din_2;
    wait for 10 ns;
    input_last_division.row_i <= din_row_i;
    input_last_division.inv_row_i <= din_inv_row_i;
    input_last_division.valid_data <='1';
    input_last_division.state_reg.state <= STATE_LAST_DIVISION;
    input_last_division.index_i <=2;
    input_last_division.flag_write_to_even_row <='1';
    input_last_division.write_address_even <= 1;
    input_last_division.write_address_odd <=1;
    wait for 1000 ns;
  end process WaveGen_Proc;

  

end architecture Behavioral;


