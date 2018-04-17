-------------------------------------------------------------------------------
-- Title      : Testbench for design "block_ram"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : block_ram_tb.vhd
-- Author     :   <Martin@MARTIN-PC>
-- Company    : 
-- Created    : 2018-04-14
-- Last update: 2018-04-14
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2018 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2018-04-14  1.0      Martin  Created
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

use work.math_real.all;
use std.textio.all;
-------------------------------------------------------------------------------

entity block_ram_tb is

end entity block_ram_tb;

-------------------------------------------------------------------------------

architecture Behavioral of block_ram_tb is

  -- component generics
  constant B_RAM_SIZE      : integer := 100;
  constant B_RAM_BIT_WIDTH : integer := 32;

  -- component ports
  signal aresetn            : std_logic;
  signal data_in            : std_logic_vector(B_RAM_BIT_WIDTH-1 downto 0);
  signal data_in_even       : std_logic_vector(B_RAM_BIT_WIDTH-1 downto 0);  -- even BRAM_row_input
  signal write_enable       : std_logic;
  signal read_enable        : std_logic;
  signal read_address       : integer range 0 to B_RAM_SIZE-1;
  signal read_address_even  : integer range 0 to B_RAM_SIZE-1;
  signal write_address      : integer range 0 to B_RAM_SIZE-1;
  signal write_address_even : integer range 0 to B_RAM_SIZE-1;
  signal data_out           : std_logic_vector(B_RAM_BIT_WIDTH-1 downto 0);
  signal data_out_even      : std_logic_vector(B_RAM_BIT_WIDTH-1 downto 0);

  -- clock
  signal clk : std_logic := '1';

begin  -- architecture Behavioral

  -- component instantiation
  DUT : entity work.block_ram
    generic map (
      B_RAM_SIZE      => B_RAM_SIZE,
      B_RAM_BIT_WIDTH => B_RAM_BIT_WIDTH)
    port map (
      clk           => clk,
      aresetn       => aresetn,
      data_in       => data_in,
      write_enable  => write_enable,
      read_enable   => read_enable,
      read_address  => read_address,
      write_address => write_address,
      data_out      => data_out);

  DUT_even : entity work.block_ram
    generic map (
      B_RAM_SIZE      => B_RAM_SIZE,
      B_RAM_BIT_WIDTH => B_RAM_BIT_WIDTH)
    port map (
      clk           => clk,
      aresetn       => aresetn,
      data_in       => data_in_even,
      write_enable  => write_enable,
      read_enable   => read_enable,
      read_address  => read_address_even,
      write_address => write_address_even,
      data_out      => data_out_even);

  -- clock generation
  clk <= not clk after 5 ns;

  -- waveform generation
  WaveGen_Proc : process
    variable seed1, seed2 : positive;   -- Seed values for random generator 
    variable rand         : real;  -- Random real-number value in range 0 to 1.0
    variable rand_even         : real;  -- Random real-number value in range 0 to 1.0
    variable int_rand     : integer;  -- Random integer value in range 0..4095 
    variable int_rand_even     : integer;  -- Random integer value in range 0..4095 
    variable stim         : std_logic_vector(31 downto 0);  -- Random 32-bit stimulus
    variable stim_even         : std_logic_vector(31 downto 0);  -- Random 32-bit stimulus
    variable int_address_even  : integer:=0;
    variable has_written  : std_logic := '0';

  begin
    -- insert signal assignments here
    read_enable  <= '1';
    write_enable <= '1';
    aresetn      <= '1';

    for i in 0 to 5 loop
      UNIFORM(seed1, seed2, rand);      -- generate random number 
      UNIFORM(seed1, seed2, rand_even);      -- generate random number 
      int_rand    := integer(TRUNC(rand *256.0));  -- Convert to integer in range of 0 to 255
      int_rand_even    := integer(TRUNC(rand_even *256.0));  -- Convert to integer in range of 0 to 255
                                                   --, find integer part 
      stim        := std_logic_vector(to_unsigned(int_rand, stim'length));  -- convert to                                                                   --std_logic_vector
      stim_even        := std_logic_vector(to_unsigned(int_rand_even, stim'length));  -- convert to                                                                   --std_logic_vector
      -- Address and data input
      if (has_written = '1') then
        data_in <= std_logic_vector(to_signed(to_integer(unsigned(stim)) +to_integer(unsigned(data_out)), data_in'length));
        data_in_even <= std_logic_vector(to_signed(to_integer(unsigned(stim_even)) +to_integer(unsigned(data_out_even)), data_in_even'length));
      else
        data_in <= stim;
        data_in_even <= std_logic_vector(to_signed(to_integer(unsigned(stim_even)) +to_integer(unsigned(data_out_even)), data_in_even'length));
      end if;
      write_address_even <= int_address_even;  -- convert to                                                                   --std_logic_vector_
      read_address_even  <= int_address_even+2;  -- convert to                                                                   --std_logic_vector
      write_address <= int_address_even+1;  -- convert to                                                                   --std_logic_vector
      read_address  <= int_address_even+3;  -- convert to                                                                   --std_logic_vector
      int_address_even := int_address_even +2; -- this i
      wait for 10 ns;
    end loop;
    int_address_even :=0;
    has_written  := '1';
    write_enable <= '0';
    wait for 20ns;
  end process WaveGen_Proc;



end architecture Behavioral;

-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
