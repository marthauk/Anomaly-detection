-------------------------------------------------------------------------------
-- Title      : Testbench for design "shiftregister_four_pixels"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : shiftregister_four_pixels_tb.vhd
-- Author     :   <Martin@MARTIN-PC>
-- Company    : 
-- Created    : 2018-04-09
-- Last update: 2018-04-09
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-04-09  1.0      Martin  Created
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
-------------------------------------------------------------------------------

entity shiftregister_four_pixels_tb is

end entity shiftregister_four_pixels_tb;

-------------------------------------------------------------------------------

architecture Behavioral of shiftregister_four_pixels_tb is

  -- component ports
  signal din     : std_logic_vector (63 downto 0);
  signal valid   : std_logic := '1';
  signal clk_en  : std_logic := '1';
  signal reset_n : std_logic := '1';
  signal shift_counter : std_logic_vector (log2(P_BANDS*PIXEL_DATA_WIDTH/64) downto 0);
  signal dout    : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH -1 downto 0);

  -- clock
  signal clk : std_logic := '1';

begin  -- architecture Behavioral

  -- component instantiation
  DUT : entity work.shiftregister_four_pixels
    port map (
      din     => din,
      valid   => valid,
      clk     => clk,
      clk_en  => clk_en,
      shift_counter => shift_counter,
      reset_n => reset_n,
      dout    => dout);

  -- clock generation
  clk <= not clk after 5 ns;

  -- waveform generation
  WaveGen_Proc : process
    variable seed1, seed2 : positive;   -- Seed values for random generator 
    variable rand         : real;  -- Random real-number value in range 0 to 1.0
    variable int_rand     : integer;  -- Random integer value in range 0..4095 
    variable stim         : std_logic_vector(63 downto 0);  -- Random 64-bit stimulus
    variable delay        : integer := P_BANDS*PIXEL_DATA_WIDTH/64;  -- NUMBER of shiftregister
                                            -- elements/datawidth. Delay in
                                            -- clock cycles
  -- data_rate bus from cube DMA
  begin
    -- insert signal assignments here
    for i in 0 to delay - 1 loop

      UNIFORM(seed1, seed2, rand);      -- generate random number 
      int_rand := integer(TRUNC(rand *256.0));  -- Convert to integer in range of 0 to 255
                                                --, find integer part 
      stim     := std_logic_vector(to_unsigned(int_rand, stim'length));  -- convert to                                                                   --std_logic_vector
      -- Address and data input
      din      <= stim;
      wait for 10 ns;
    end loop;
    valid <= '0';
    wait for 1000ns;
  end process WaveGen_Proc;



end architecture Behavioral;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
