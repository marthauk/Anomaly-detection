-------------------------------------------------------------------------------
-- Title      : Testbench for design "inverse_matrix"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : inverse_matrix_tb.vhd
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

entity inverse_matrix_tb is

end entity inverse_matrix_tb;

-------------------------------------------------------------------------------

architecture Behavioral of inverse_matrix_tb is

  -- component ports
  signal reset_n : std_logic;
  signal clk_en  : std_logic:='1';
  signal valid   : std_logic;
  signal din     : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0);
  signal writes_done_on_column : std_logic_vector(log2(P_BANDS/2) downto
                                                  0);
  signal inverse_rows : signed(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0);

  -- clock
  signal clk : std_logic := '1';

begin  -- architecture Behavioral

  -- component instantiation
  DUT : entity work.inverse_matrix
    port map (
      reset_n               => reset_n,
      clk_en                => clk_en,
      clk                   => clk,
      valid                 => valid,
      din                   => din,
      writes_done_on_column => writes_done_on_column,
      inverse_rows          => inverse_rows);

  -- clock generation
  clk <= not clk after 5 ns;
  --process
  --begin
  --  writes_done_on_column <= (others => '0');
  --  wait for 15 ns;
  --  for i in 0 to P_BANDS/2-1 loop
  --    writes_done_on_column <= std_logic_vector(to_unsigned(to_integer(unsigned(writes_done_on_column))+1, writes_done_on_column'length));
  --    wait for 10 ns;
  --  end loop;
  --  wait for 1000ns;

  --end process;

  -- waveform generation
  WaveGen_Proc : process
    variable seed1, seed2 : positive;   -- Seed values for random generator 
    variable rand         : real;  -- Random real-number value in range 0 to 1.0
    variable rand2         : real;  -- Random real-number value in range 0 to 1.0
    variable int_rand     : integer;  -- Random integer value in range 0..4095 
    variable int_rand2 : integer;
    variable stim         : std_logic_vector(31 downto 0);  -- Random 16-bit stimulus
    variable stim2         : std_logic_vector(31 downto 0);  -- Random 16-bit stimulus

  begin
    writes_done_on_column <= (others => '0');
    for i in 0 to P_BANDS/2-1 loop
      UNIFORM(seed1, seed2, rand);      -- generate random number 
      UNIFORM(seed1,seed2, rand2);
      int_rand                                                                                                                                                                            := integer(TRUNC(rand *256.0));  -- Convert to integer in range of 0 to 255
      int_rand2                                                                                                                                                                           := integer(TRUNC(rand2 *256.0));  -- Convert to integer in range of 0 to 255
      stim                                                                                                                                                                                := std_logic_vector(to_unsigned(int_rand, stim'length));  -- convert to                                                                   --std_logic_vector
      stim2                                                                                                                                                                               := std_logic_vector(to_unsigned(int_rand2, stim'length));  -- convert to                                                                   --std_logic_vector
      din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS)*PIXEL_DATA_WIDTH*2*2)                       <= stim;
      din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS)*PIXEL_DATA_WIDTH*2*2 +PIXEL_DATA_WIDTH*2) <= stim2;


      din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2*3-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS)*PIXEL_DATA_WIDTH*2*2 +PIXEL_DATA_WIDTH*2*2) <= stim;
      din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2*4-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS)*PIXEL_DATA_WIDTH*2*2 +PIXEL_DATA_WIDTH*2*3) <= stim2;

      din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2*5-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS)*PIXEL_DATA_WIDTH*2*2 +PIXEL_DATA_WIDTH*2*4) <= stim;
      din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2*6-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS)*PIXEL_DATA_WIDTH*2*2 +PIXEL_DATA_WIDTH*2*5) <= stim2;

      din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2*7-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS)*PIXEL_DATA_WIDTH*2*2 +PIXEL_DATA_WIDTH*2*6) <= stim;
      din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2*8-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS)*PIXEL_DATA_WIDTH*2*2 +PIXEL_DATA_WIDTH*2*7) <= stim2;
      valid                                                                                                                                                                                 <= '1';
      wait for 10ns;
      writes_done_on_column <= std_logic_vector(to_unsigned(to_integer(unsigned(writes_done_on_column))+1, writes_done_on_column'length));
    end loop;
    reset_n <= '1';
    clk_en  <= '1';
    valid   <= '1';
    wait for (P_BANDS)*10ns;
    valid   <= '0';
    for i in 0 to P_BANDS-1 loop
      UNIFORM(seed1, seed2, rand);      -- generate random number 
      int_rand                                                                                                                                                                                := integer(TRUNC(rand *256.0));  -- Convert to integer in range of 0 to 255
      stim                                                                                                                                                                                    := std_logic_vector(to_unsigned(int_rand, stim'length));  -- convert to                                                                   --std_logic_vector
      din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS-i)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*2)                       <= stim;
      din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS-i)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*2 +PIXEL_DATA_WIDTH*2) <= stim;
      wait for 10ns;
    end loop;
    valid <= '1';
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


-------------------------------------------------------------------------------
