-------------------------------------------------------------------------------
-- Title      : Testbench for design "inverse_matrix"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : inverse_matrix_tb.vhd
-- Author     :   <Martin@MARTIN-PC>
-- Company    : 
-- Created    : 2018-04-20
-- Last update: 2018-04-25
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
  signal clk_en  : std_logic := '1';
  signal valid   : std_logic;
  signal din     : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0);
  signal writes_done_on_column : std_logic_vector(log2(P_BANDS/2) downto
                                                  0);
  signal inverse_rows : inverse_output_reg_type;
  -- Testbench Internal Signals
  -----------------------------------------------------------------------------

  file file_VECTORS : text;
  file file_RESULTS : text;
  constant c_WIDTH  : natural := 4;

  -- clock
  signal clk     : std_logic := '1';
  signal din_1_s : std_logic_vector(PIXEL_DATA_WIDTH*2*P_BANDS*2 -1 downto 0);
  signal din_2_s : std_logic_vector(PIXEL_DATA_WIDTH*2*P_BANDS*2 -1 downto 0);

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


  process
    type t_logic_vector_array is array(0 to P_BANDS-1) of std_logic_vector(31 downto 0);
-- Contains one row of matrix data
    variable v_ILINE         : line;
    variable v_data_read     : t_logic_vector_array;
    variable v_OLINE         : line;
    variable row_counter     : integer := 0;
    variable element_counter : integer := 0;
    variable test            : std_logic_vector(7 downto 0);
    variable v_SPACE         : character;
    variable din_1           : std_logic_vector(PIXEL_DATA_WIDTH*2*P_BANDS*2 -1 downto 0);
    variable din_2           : std_logic_vector(PIXEL_DATA_WIDTH*2*P_BANDS*2 -1 downto 0);
    variable line_in         : std_logic_vector(PIXEL_DATA_WIDTH*2*P_BANDS-1 downto 0);
    variable line_counter    : integer := 0;
  begin

    file_open(file_VECTORS, "input_matrix.txt", read_mode);
    -- file_open(file_RESULTS, "output_inv_matrix.txt", write_mode);

    while not endfile(file_VECTORS) loop
      readline(file_VECTORS, v_ILINE);
      while element_counter <= P_BANDS-1 loop
        hread(v_ILINE, v_data_read(element_counter));
        read(v_ILINE, v_SPACE);
        element_counter := element_counter+1;
      end loop;
      for k in 0 to P_BANDS-1 loop
        if line_counter <= 1 then
          din_1(k*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2 -1+ line_counter*P_BANDS*PIXEL_DATA_WIDTH*2 downto k*PIXEL_DATA_WIDTH*2 + line_counter*PIXEL_DATA_WIDTH*P_BANDS*2) := v_data_read(k);
        elsif line_counter <= 3 and line_counter >= 2 then
          din_2(k*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2 -1+ (line_counter-2)*P_BANDS*PIXEL_DATA_WIDTH*2 downto k*PIXEL_DATA_WIDTH*2 + (line_counter-2)*PIXEL_DATA_WIDTH*P_BANDS*2) := v_data_read(k);
        end if;
      end loop;
      line_counter    := line_counter+1;
      element_counter := 0;
    end loop;
    din_1_s <= din_1;
    din_2_s <= din_2;
    file_close(file_VECTORS);
    wait;
  end process;

  process
    variable i_count : integer;
  begin
    writes_done_on_column <= (others => '0');
    reset_n               <= '1';
    clk_en                <= '1';
    wait for 30 ns;
    i_count               := 0;
    if(i_count = 0) then
      din <= din_1_s;
    end if;
    valid                 <= '1';
    wait for 10 ns;
    i_count := 1;
    if(i_count = 1) then
      din <= din_2_s;
    end if;
    writes_done_on_column <= std_logic_vector(to_unsigned(to_integer(unsigned(writes_done_on_column))+1, writes_done_on_column'length));
    valid                 <= '1';
    wait for 10ns;
    wait;
end process;


-- waveform generation
-- WaveGen_Proc : process
--   variable seed1, seed2 : positive;   -- Seed values for random generator 
--   variable rand         : real;  -- Random real-number value in range 0 to 1.0
--   variable rand2        : real;  -- Random real-number value in range 0 to 1.0
--   variable int_rand     : integer;  -- Random integer value in range 0..4095 
--   variable int_rand2    : integer;
--   --variable stim         : std_logic_vector(31 downto 0);  -- Random 16-bit stimulus
--   --variable stim         : std_logic_vector(31 downto 0);  -- Random 16-bit stimulus
--   variable stim         : std_logic_vector(127 downto 0);  -- Random 16-bit stimulus
--   variable stim2        : std_logic_vector(127 downto 0);  -- Random 16-bit stimulus

-- begin
--   wait for 1000 ns;
--   wait;
--   writes_done_on_column <= (others => '0');
--   for i in 0 to P_BANDS/2-1 loop
--     UNIFORM(seed1, seed2, rand);      -- generate random number 
--     UNIFORM(seed1, seed2, rand2);
--     int_rand  := integer(TRUNC(rand *256.0));  -- Convert to integer in range of 0 to 255
--     int_rand2 := integer(TRUNC(rand2 *256.0));  -- Convert to integer in range of 0 to 255
--     stim      := std_logic_vector(to_unsigned(int_rand, stim'length));  -- convert to                                                                   --std_logic_vector
--     stim2     := std_logic_vector(to_unsigned(int_rand2, stim'length));  -- convert to                                                                   --std_logic_vector
--     -- din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS)*PIXEL_DATA_WIDTH*2*2)                       <= stim;
--     -- din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS)*PIXEL_DATA_WIDTH*2*2 +PIXEL_DATA_WIDTH*2) <= stim2;

--     din(P_BANDS*PIXEL_DATA_WIDTH*2-1 downto 0)                             <= stim;
--     din(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto P_BANDS*PIXEL_DATA_WIDTH*2) <= stim2;

--     valid                 <= '1';
--     wait for 10ns;
--     writes_done_on_column <= std_logic_vector(to_unsigned(to_integer(unsigned(writes_done_on_column))+1, writes_done_on_column'length));
--   end loop;
--   reset_n <= '1';
--   clk_en  <= '1';
--   valid   <= '1';
--   wait for (P_BANDS)*10ns;
--   valid   <= '0';
--   wait for P_BANDS*100000ns;
--   for i in 0 to P_BANDS-1 loop
--     UNIFORM(seed1, seed2, rand);      -- generate random number 
--     int_rand                                                                                                                                                                                := integer(TRUNC(rand *256.0));  -- Convert to integer in range of 0 to 255
--     stim                                                                                                                                                                                    := std_logic_vector(to_unsigned(int_rand, stim'length));  -- convert to                                                                   --std_logic_vector
--     din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS-i)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*2)                       <= stim;
--     din(P_BANDS*PIXEL_DATA_WIDTH*2*2 - ((P_BANDS-i)*PIXEL_DATA_WIDTH)*2*2+ PIXEL_DATA_WIDTH*2*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*2 +PIXEL_DATA_WIDTH*2) <= stim;
--     wait for 10ns;
--   end loop;
--   valid <= '1';
--   wait for (P_BANDS+1)*10ns;
--   -- Should be finished by now
--   --clk_en  <= '0';
--   --valid   <= '0';
--   wait for 1000ns;
--   -- insert signal assignments here

-- end process WaveGen_Proc;



end architecture Behavioral;

-------------------------------------------------------------------------------






-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
