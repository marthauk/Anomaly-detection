-------------------------------------------------------------------------------
-- Title      : Testbench for design "acad_correlation"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : acad_correlation_tb.vhd
-- Author     :   <Martin@MARTIN-PC>
-- Company    : 
-- Created    : 2018-04-10
-- Last update: 2018-04-13
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-04-10  1.0      Martin  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use ieee.numeric_std.all;

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

entity acad_correlation_tb is

end entity acad_correlation_tb;

-------------------------------------------------------------------------------

architecture Behavioral of acad_correlation_tb is

  -- component ports
  signal din     : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH-1 downto 0);
  signal valid   : std_logic;
  signal clk_en  : std_logic;
  signal reset_n : std_logic;
  signal dout    : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2-1 downto 0);
  signal writes_done_on_column : std_logic_vector(log2(P_BANDS/2) downto 0);
  signal write_state :std_logic;
  signal valid_out : std_logic;
  -- clock
  signal clk : std_logic := '1';

begin  -- architecture Behavioral

  -- component instantiation
  DUT : entity work.acad_correlation
    port map (
      din     => din,
      valid   => valid,
      clk     => clk,
      clk_en  => clk_en,
      reset_n => reset_n,
      dout    => dout,
      valid_out => valid_out,
      writes_done_on_column => writes_done_on_column
            );

  -- clock generation
  clk <= not clk after 5 ns;



  -- waveform generation
  WaveGen_Proc : process
    variable seed1, seed2 : positive;   -- Seed values for random generator 
    variable rand         : real;  -- Random real-number value in range 0 to 1.0
    variable int_rand     : integer;  -- Random integer value in range 0..4095 
    variable stim         : std_logic_vector(15 downto 0);  -- Random 16-bit stimulus

  begin
    for i in 0 to P_BANDS-1 loop
      UNIFORM(seed1, seed2, rand);      -- generate random number 
      int_rand                                                                                                                                        := integer(TRUNC(rand *256.0));  -- Convert to integer in range of 0 to 255
      stim                                                                                                                                            := std_logic_vector(to_unsigned(int_rand, stim'length));  -- convert to                                                                   --std_logic_vector
      din(P_BANDS*PIXEL_DATA_WIDTH - ((P_BANDS-i)*PIXEL_DATA_WIDTH)+ PIXEL_DATA_WIDTH-1 downto P_BANDS*PIXEL_DATA_WIDTH-(P_BANDS-i)*PIXEL_DATA_WIDTH) <= stim;
      wait for 10ns;
    end loop;
    reset_n <= '1';
    clk_en  <= '1';
    valid   <= '1';
    wait for (P_BANDS)*10ns ;  
    valid <='0';
    for i in 0 to P_BANDS-1 loop
      UNIFORM(seed1, seed2, rand);      -- generate random number 
      int_rand                                                                                                                                        := integer(TRUNC(rand *256.0));  -- Convert to integer in range of 0 to 255
      stim                                                                                                                                            := std_logic_vector(to_unsigned(int_rand, stim'length));  -- convert to                                                                   --std_logic_vector
      din(P_BANDS*PIXEL_DATA_WIDTH - ((P_BANDS-i)*PIXEL_DATA_WIDTH)+ PIXEL_DATA_WIDTH-1 downto P_BANDS*PIXEL_DATA_WIDTH-(P_BANDS-i)*PIXEL_DATA_WIDTH) <= stim;
      din(P_BANDS*PIXEL_DATA_WIDTH - ((P_BANDS-i)*PIXEL_DATA_WIDTH)+ PIXEL_DATA_WIDTH-1 downto P_BANDS*PIXEL_DATA_WIDTH-(P_BANDS-i)*PIXEL_DATA_WIDTH) <= stim;
      wait for 10ns;
    end loop;
    valid<='1';
    wait for (P_BANDS+1)*10ns;  
    -- Should be finished by now
    --clk_en  <= '0';
    --valid   <= '0';
    wait for 1000ns;
    -- insert signal assignments here

  end process WaveGen_Proc;



end architecture Behavioral;

-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
