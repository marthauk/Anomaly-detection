-------------------------------------------------------------------------------
-- Title      : Testbench for design "inverse_matrix"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : inverse_matrix_tb.vhd
-- Author     :   <Martin@MARTIN-PC>
-- Company    : 
-- Created    : 2018-03-08
-- Last update: 2018-03-15
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

use STD.textio.all;
use ieee.std_logic_textio.all;

library work;
use work.Common_types_and_functions.all;
-------------------------------------------------------------------------------

entity inverse_matrix_tb is

end entity inverse_matrix_tb;

-------------------------------------------------------------------------------

architecture behavioral of inverse_matrix_tb is

  -- component ports
  signal reset           : std_logic;
  signal clk_en          : std_logic;
  signal clk             : std_logic := '1';
  signal start_inversion : std_logic;
  signal M_corr          : matrix_reg_type;
  signal M_inv           : matrix_reg_type;

  -- Testbench Internal Signals
  -----------------------------------------------------------------------------
  file file_VECTORS : text;
  file file_RESULTS : text;
  constant c_WIDTH : natural := 4;

begin  -- architecture behavioral

  -- component instantiation
  DUT : entity work.inverse_matrix
    port map (
      reset           => reset,
      clk_en          => clk_en,
      clk             => clk,
      start_inversion => start_inversion,
      M_corr          => M_corr,
      M_inv           => M_inv);

  -- clock generation
  clk <= not clk after 10 ns;

  -- waveform generation
  ---------------------------------------------------------------------------
  -- This procedure reads the file input_vectors.txt which is located in the
  -- simulation project area.
  -- It will read the data in and send it to the ripple-adder component
  -- to perform the operations.  The result is written to the
  -- output_results.txt file, located in the same directory.
  ---------------------------------------------------------------------------
  process
    type t_logic_vector_array is array(0 to P_BANDS-1) of std_logic_vector(31 downto 0);
-- Contains one row of matrix data
    variable v_ILINE     : line;
    variable v_data_read : t_logic_vector_array;
    variable v_OLINE     : line;
    variable row_counter : integer:=0 ;
    variable element_counter : integer:=0 ;
    variable test : std_logic_vector(7 downto 0);

    variable v_SPACE : character;

  begin

    file_open(file_VECTORS, "input_matrix.txt", read_mode);
    file_open(file_RESULTS, "output_inv_matrix.txt", write_mode);

    while not endfile(file_VECTORS) loop
      readline(file_VECTORS, v_ILINE);
      --readline(file_VECTORS, v_ILINE);
      --read(v_ILINE, v_ADD_TERM1);
    --  HREAD(v_ILINE,test );
      --read(v_ILINE, v_SPACE);           -- read in the space character
      --read(v_ILINE, v_ADD_TERM2);
      --for i in 0 to P_BANDS-1 loop
        --hread(v_ILINE, v_data_read(1));
      while element_counter<= P_BANDS-1 loop
        hread(v_ILINE, v_data_read(element_counter));
        read(v_ILINE, v_SPACE);
        element_counter := element_counter+1;
        end loop;

      for k in 0 to P_BANDS-1 loop
        M_corr.matrix(row_counter,k) <= std_logic_vector(v_data_read(k));
        end loop;
        element_counter := 0;
        row_counter := row_counter +1 ;

      --write(v_OLINE, w_SUM, right, c_WIDTH);
      --writeline(file_RESULTS, v_OLINE);
    end loop;

    --wait for 60 ns;
    file_close(file_VECTORS);
    --file_close(file_RESULTS);

    wait;
  end process;

  WaveGen_Proc : process
  begin
    -- insert signal assignments here

    reset           <= '1';
    wait for 20 ns;
    reset           <= '0';
    wait for 10 ns;
    clk_en          <= '1';
    start_inversion <= '1';

    -- M_corr.matrix(0, 0) <= std_logic_vector(to_unsigned(1, 32));
    -- M_corr.matrix(0, 1) <= std_logic_vector(to_unsigned(3, 32));
    -- M_corr.matrix(0, 2) <= std_logic_vector(to_unsigned(1, 32));

    -- M_corr.matrix(1, 0) <= std_logic_vector(to_unsigned(2, 32));
    -- M_corr.matrix(1, 1) <= std_logic_vector(to_unsigned(3, 32));
    -- M_corr.matrix(1, 2) <= std_logic_vector(to_unsigned(2, 32));

    -- M_corr.matrix(2, 0) <= std_logic_vector(to_unsigned(6, 32));
    -- M_corr.matrix(2, 1) <= std_logic_vector(to_unsigned(8, 32));
    -- M_corr.matrix(2, 2) <= std_logic_vector(to_unsigned(7, 32));
    -- -- 

    -- M.matrix_inv(0, 0) <= std_logic_vector(to_unsigned(1, 32));
    -- M.matrix_inv(0, 1) <= std_logic_vector(to_unsigned(0, 32));
    -- M.matrix_inv(0, 2) <= std_logic_vector(to_unsigned(0, 32));
    -- M.matrix_inv(1, 0) <= std_logic_vector(to_unsigned(0, 32));
    -- M.matrix_inv(1, 1) <= std_logic_vector(to_unsigned(1, 32));
    -- M.matrix_inv(1, 2) <= std_logic_vector(to_unsigned(0, 32));
    -- M.matrix_inv(2, 0) <= std_logic_vector(to_unsigned(0, 32));
    -- M.matrix_inv(2, 1) <= std_logic_vector(to_unsigned(0, 32));
    -- M.matrix_inv(2, 2) <= std_logic_vector(to_unsigned(1, 32));
    wait for 10 ns;
    start_inversion <= '0';
    wait for 100000000 ns;

  end process WaveGen_Proc;



-------------------------------------------------------------------------------

-------------------------------------------------------------------------------


end architecture behavioral;

-------------------------------------------------------------------------------







