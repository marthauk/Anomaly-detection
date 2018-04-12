-------------------------------------------------------------------------------
-- Title      : Testbench for design "BRAM"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : BRAM_tb.vhd
-- Author     :   <Martin@MARTIN-PC>
-- Company    : 
-- Created    : 2018-04-05
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
-- 2018-04-05  1.0      Martin  Created
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

entity BRAM_tb is

end entity BRAM_tb;

-------------------------------------------------------------------------------

architecture Behavioral of BRAM_tb is

  -- component ports
  signal DOA    : std_logic_vector (31 downto 0);
  signal DOB    : std_logic_vector (31 downto 0);
  signal ADDRA  : std_logic_vector(9 downto 0);
  signal ADDRB  : std_logic_vector(9 downto 0);
  signal DIA    : std_logic_vector(31 downto 0);
  signal DIB    : std_logic_vector(31 downto 0);
  signal ENA    : std_logic;
  signal ENB    : std_logic;
  signal REGCEA : std_logic;
  signal REGCEB : std_logic;
  signal RSTA   : std_logic;
  signal RSTB   : std_logic;
  signal WEA    : std_logic_vector(3 downto 0);
  signal WEB    : std_logic_vector(3 downto 0);

  -- clock
  signal CLKA : std_logic := '1';
  signal CLKB : std_logic := '1';

begin  -- architecture Behavioral

  -- component instantiation
  DUT : entity work.BRAM
    port map (
      DOA    => DOA,
      DOB    => DOB,
      ADDRA  => ADDRA,
      ADDRB  => ADDRB,
      CLKA   => CLKA,
      CLKB   => CLKB,
      DIA    => DIA,
      DIB    => DIB,
      ENA    => ENA,
      ENB    => ENB,
      REGCEA => REGCEA,
      REGCEB => REGCEB,
      RSTA   => RSTA,
      RSTB   => RSTB,
      WEA    => WEA,
      WEB    => WEB);

  -- clock generation
  CLKA <= not CLKA after 5 ns;
  CLKB <= not CLKB after 5 ns;

  -- waveform generation
  WaveGen_Proc : process
    variable seed1, seed2              : positive;  -- Seed values for random generator 
    variable rand                      : real;  -- Random real-number value in range 0 to 1.0
    variable int_rand                  : integer;  -- Random integer value in range 0..4095 
    variable stim                      : std_logic_vector(31 downto 0);  -- Random 32-bit stimulus
    variable int_address               : integer;
    variable number_of_matrix_elements : integer := 1125; -- 36 kBit block ram
                                                          -- size, 32 bit per
                                                          -- pixel/band. Matrix
                                                          -- element in BRAM.

  begin
    -- Control signals
    ENA             <= '1';
    ENB             <= '1';
    REGCEA          <= '1';
    REGCEB          <= '1';
    RSTA            <= '0';
    RSTB            <= '0';
    WEA             <= "1111";
    WEB             <= "1111";

    for i in 0 to (number_of_matrix_elements-1)/2 loop
      UNIFORM(seed1, seed2, rand);      -- generate random number 
      int_rand    := integer(TRUNC(rand *256.0));  -- Convert to integer in range of 0 to 255
                                                   --, find integer part 
      stim        := std_logic_vector(to_unsigned(int_rand, stim'length));  -- convert to                                                                   --std_logic_vector
      -- Address and data input
      int_address := i*2;
      DIA         <= stim;
      DIB         <= stim;
      ADDRA       <= std_logic_vector(to_unsigned(int_address, ADDRA'length));  -- convert to                                                                   --std_logic_vector
      ADDRB       <= std_logic_vector(to_unsigned(int_address+1, ADDRA'length));  -- convert to                                                                   --std_logic_vector

      wait for 10 ns;
    end loop;
  end process WaveGen_Proc;



end architecture Behavioral;


