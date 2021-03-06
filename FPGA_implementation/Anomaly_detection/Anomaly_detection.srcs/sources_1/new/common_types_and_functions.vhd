----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/29/2018 12:31:59 PM
-- Design Name: 
-- Module Name: common_types_and_functions - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

library work;


package Common_types_and_functions is
  -- N_PIXELS is the number of pixels in the hyperspectral image
  constant N_PIXELS                   : integer range 0 to 628864 := 628864;  -- 578 pixels per row * 1088 rows
  -- P_BANDS  is the number of spectral bands
  constant P_BANDS                    : integer range 0 to 100    := 10;
  --constant P_BANDS : integer := 100;
  -- K is size of the kernel used in LRX. 
  constant K                          : integer;
  -- PIXEL_DATA_WIDTH is the width of the raw input data from the HSI
  constant PIXEL_DATA_WIDTH           : integer range 0 to 16     := 16;
  constant NUMBER_OF_WRITES_PER_CYCLE : integer range 0 to 2      := 2;
  constant BRAM_TDP_ADDRESS_WIDTH     : integer range 0 to 10     := 10;
  -- component generics
  constant B_RAM_SIZE                 : integer                   := 100;
-- Need to be 33 bit due to updating(adding) of two 32 bit variables. Is 33 bit necessary? Precision  question.
  constant B_RAM_BIT_WIDTH            : integer                   := 32;
  -- Time from issuing write in top-level inverse to data is possible to read
  -- from BRAM:
  constant B_RAM_WAIT_CLK_CYCLES      : integer range 0 to 3      := 3;
  type matrix is array (natural range <>, natural range <>) of std_logic_vector(15 downto 0);
  -- for correlation results
  type matrix_32 is array (natural range <>, natural range <>) of std_logic_vector(31 downto 0);

  type row_array is array (0 to P_BANDS-1) of signed(PIXEL_DATA_WIDTH*2 -1 downto 0);

  -- drive signals
  constant STATE_IDLE_DRIVE                       : std_logic_vector(2 downto 0) := "000";
  constant STATE_FORWARD_ELIM_TRIANGULAR_FINISHED : std_logic_vector(2 downto 0) := "001";
  constant STATE_FORWARD_ELIMINATION_FINISHED     : std_logic_vector(2 downto 0) := "010";
  constant STATE_BACKWARD_ELIMINATION_FINISHED    : std_logic_vector(2 downto 0) := "011";
  constant STATE_LAST_DIVISION_FINISHED           : std_logic_vector(2 downto 0) := "111";

  -- start signals for fsm
  constant IDLING                         : std_logic_vector(1 downto 0) := "00";
  constant START_FORWARD_ELIMINATION      : std_logic_vector(1 downto 0) := "01";
  constant START_BACKWARD_ELIMINATION     : std_logic_vector(1 downto 0) := "10";
  constant START_IDENTITY_MATRIX_BUILDING : std_logic_vector(1 downto 0) := "11";

  -- Forward-elimination specific signals

  constant START_FORWARD_ELIM_TRIANGULAR : std_logic_vector (1 downto 0) := "10";
  constant START_FORWARD_ELIM_CORE       : std_logic_vector(1 downto 0)  := "11";
  constant STATE_FORWARD_TRIANGULAR      : std_logic_vector(1 downto 0)  := "10";
  constant STATE_FORWARD_ELIM            : std_logic_vector(1 downto 0)  := "11";

  -- Different state machines used in the design
  type state_type is (STATE_IDLE, STATE_STORE_CORRELATION_MATRIX, STATE_FORWARD_ELIMINATION, STATE_BACKWARD_ELIMINATION, STATE_LAST_DIVISION, STATE_OUTPUT_INVERSE_MATRIX);

  type elimination_write_state is (STATE_IDLE, FIRST_ELIMINATION, ODD_j_WRITE, EVEN_j_WRITE, EVEN_i_START, ODD_i_START);
  type forward_elimination_write_state_type is (STATE_IDLE, CHECK_DIAGONAL_ELEMENT_IS_ZERO, SWAP_ROWS, EVEN_j_WRITE, ODD_j_WRITE);
  type last_division_write_state_type is (STATE_IDLE, EVEN_i_WRITE, ODD_i_WRITE);

  type remainder_after_approximation_record is record
    remainder        : std_logic_vector(PIXEL_DATA_WIDTH*2-1 downto 0);  -- For PIXEL_DATA_WIDTH of 16
    number_of_shifts : integer range 0 to 31;
    remainder_valid  : std_logic;
  end record;

  type reg_state_type is record
    state                           : state_type;
    --drive                           : std_logic_vector(2 downto 0);
    --fsm_start_signal                : std_logic_vector(1 downto 0);
    --inner_loop_iter_finished        : std_logic;
    --inner_loop_last_iter_finished   : std_logic;
    --start_inner_loop                : std_logic;
    --forward_elim_ctrl_signal        : std_logic_vector(1 downto 0);
    --forward_elim_state_signal       : std_logic_vector(1 downto 0);
    --flag_forward_core_started       : std_logic;
    --flag_forward_triangular_started : std_logic;
  end record;


  type input_elimination_reg_type is record
    row_j                           : row_array;
    row_i                           : row_array;
    row_even                        : row_array;
    row_odd                         : row_array;
    inv_row_even                    : row_array;
    inv_row_odd                     : row_array;
    inv_row_j                       : row_array;
    inv_row_i                       : row_array;
    state_reg                       : reg_state_type;
    index_i                         : integer range 0 to P_BANDS -1;
    index_j                         : integer range 0 to P_BANDS -1;
    valid_data                      : std_logic;
    write_address_even              : integer range 0 to P_BANDS/2-1;
    write_address_odd               : integer range 0 to P_BANDS/2-1;
    read_address                    : integer range 0 to P_BANDS/2-1;
    flag_write_to_even_row          : std_logic;
    flag_write_to_odd_row           : std_logic;
    write_enable_odd                : std_logic;
    write_enable_even               : std_logic;
    forward_elimination_write_state : forward_elimination_write_state_type;
    address_row_i                   : integer range 0 to P_BANDS/2-1;
    address_row_j                   : integer range 0 to P_BANDS/2-1;
    flag_prev_row_i_at_odd_row      : std_logic;  --two cycles ahead 
    flag_prev_row_j_at_odd_row      : std_logic;  -- needed for flip rows
    flag_start_swapping_rows        : std_logic;  -- used in forward elimination
    flag_started_swapping_rows      : std_logic;  -- used in flip rows and forward elimination
    flag_wrote_swapped_rows_to_BRAM : std_logic;  --
    flag_first_data_elimination     : std_logic;
    read_address_even               : integer range 0 to P_BANDS/2-1;
    read_address_odd                : integer range 0 to P_BANDS/2-1;
    read_enable                     : std_logic;
    best_approx                     : remainder_after_approximation_record;
    msb_index                       : integer range 0 to 31;
    index_i_two_cycles_ahead            : integer range 0 to P_BANDS-1;
    index_j_two_cycles_ahead            : integer range 0 to P_BANDS-1;
    read_address_row_i_two_cycles_ahead : integer range 0 to P_BANDS/2-1;
    wait_counter                  : integer range 0 to 3;
    flag_waiting_for_bram_update  : std_logic;
  end record;
  type inverse_top_level_reg_type is record
    row_j                                               : row_array;
    row_i                                               : row_array;
    inv_row_j                                           : row_array;
    inv_row_i                                           : row_array;
    state_reg                                           : reg_state_type;
    index_i_two_cycles_ahead                            : integer range 0 to P_BANDS-1;
    index_j_two_cycles_ahead                            : integer range 0 to P_BANDS-1;
    index_i                                             : integer range 0 to P_BANDS -1;
    index_j                                             : integer range 0 to P_BANDS -1;
    valid_data                                          : std_logic;
    write_address_even                                  : integer range 0 to P_BANDS/2-1;
    write_address_odd                                   : integer range 0 to P_BANDS/2-1;
    read_address_even                                   : integer range 0 to P_BANDS/2-1;
    read_address_odd                                    : integer range 0 to P_BANDS/2-1;
    bram_write_data_M                                   : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0);
    bram_write_data_M_inv                               : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0);
    write_enable_even                                   : std_logic;  -- Remove?
    write_enable_odd                                    : std_logic;  -- Remove?
    read_enable                                         : std_logic;
    writes_done_on_column                               : std_logic_vector(2 downto 0);  --should
    --be size log2(P_BANDS/2)downto 0. Need to edit the size manually if
    --changing P_BANDS.
    flag_first_data_elimination                         : std_logic;
    flag_waited_one_clk                                 : std_logic;
    flag_first_memory_request                           : std_logic;  -- between each state shift
    flag_write_to_odd_row                               : std_logic;  -- row_j might be on both odd and
                                        -- even rows.
    flag_write_to_even_row                              : std_logic;  -- sometimes its necessary to write
                                        -- both rows.
    --^ Needed for forward elimination
    elimination_write_state                             : elimination_write_state;
    read_address_row_i_two_cycles_ahead                 : integer range 0 to P_BANDS/2-1;
    -- read address of the row i
    address_row_i                                       : integer range 0 to P_BANDS/2-1;
    flag_prev_row_i_at_odd_row                          : std_logic;  --two cycles ahead 
    flag_wr_row_i_at_odd_row                            : std_logic;
    ---*
    flag_finished_sending_data_to_BRAM_one_cycle_ago    : std_logic;
    flag_finished_sending_data_to_BRAM_two_cycles_ago   : std_logic;
    flag_finished_sending_data_to_BRAM_three_cycles_ago : std_logic;
    flag_last_read_backward_elimination                 : std_logic;

    flag_first_iter_backward_elim : std_logic;

    wait_counter                  : integer range 0 to 3;
    flag_waiting_for_bram_update  : std_logic;
    -- Needed for last division:
    last_division_write_state     : last_division_write_state_type;
    counter_output_inverse_matrix : integer range 0 to P_BANDS/2-1;

  end record;

  type inverse_output_reg_type is record
    --outputting two rows of the inverse matrix per cycle:
    two_inverse_rows : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH *2*2-1 downto 0);
    valid_data       : std_logic;
    address          : integer range 0 to P_BANDS/2-1;
  end record;

  type output_forward_elimination_reg_type is record
    row_j                               : row_array;
    row_i                               : row_array;
    inv_row_j                           : row_array;
    inv_row_i                           : row_array;
    index_i                             : integer range 0 to P_BANDS -1;
    index_j                             : integer range 0 to P_BANDS -1;
    state_reg                           : reg_state_type;
    r_addr_next                         : integer range 0 to P_BANDS/2-1;
    write_address_even                  : integer range 0 to P_BANDS/2-1;
    write_address_odd                   : integer range 0 to P_BANDS/2-1;
    valid_data                          : std_logic;
    flag_write_to_odd_row               : std_logic;  -- row_j might be on both odd and
                                                      -- even rows.
    flag_write_to_even_row              : std_logic;  -- sometimes its necessary to write
                                                      -- both rows.
    write_enable_even                   : std_logic;
    write_enable_odd                    : std_logic;
    flag_prev_row_i_at_odd_row          : std_logic;  --two cycles ahead 
    read_address_even                   : integer range 0 to P_BANDS/2-1;
    read_address_odd                    : integer range 0 to P_BANDS/2-1;
    read_enable                         : std_logic;
    forward_elimination_write_state     : forward_elimination_write_state_type;
    flag_started_swapping_rows          : std_logic;  -- used in flip rows and forward elimination
    wait_counter                        : integer range 0 to 3;
    index_i_two_cycles_ahead            : integer range 0 to P_BANDS-1;
    index_j_two_cycles_ahead            : integer range 0 to P_BANDS-1;
    read_address_row_i_two_cycles_ahead : integer range 0 to P_BANDS/2-1;
  end record;

  type output_backward_elimination_reg_type is record
    new_row_j                       : row_array;
    new_inv_row_j                   : row_array;
    r_addr_next                     : integer range 0 to P_BANDS/2-1;
    write_address_even              : integer range 0 to P_BANDS/2-1;
    write_address_odd               : integer range 0 to P_BANDS/2-1;
    valid_data                      : std_logic;
    state_reg                       : reg_state_type;
    flag_write_to_odd_row           : std_logic;  -- row_j might be on both odd and
                                                  -- even rows.
    flag_write_to_even_row          : std_logic;  -- sometimes its necessary to write
                                                  -- both rows.
    write_enable_even               : std_logic;
    write_enable_odd                : std_logic;
    forward_elimination_write_state : forward_elimination_write_state_type;
  end record;

  type input_last_division_reg_type is record
    row_i                  : row_array;
    inv_row_i              : row_array;
    state_reg              : reg_state_type;
    index_i                : integer range 0 to P_BANDS -1;
    flag_write_to_even_row : std_logic;  -- Maximum need to write one row at the
    -- time in STATE LAST DIVISION
    valid_data             : std_logic;
    write_address_even     : integer range 0 to P_BANDS/2-1;
    write_address_odd      : integer range 0 to P_BANDS/2-1;
    --
    best_approx            : remainder_after_approximation_record;
    msb_index              : integer range 0 to 31;
  end record;

  type output_last_division_reg_type is record
    new_inv_row_i          : row_array;
    valid_data             : std_logic;
    index_i                : integer range 0 to P_BANDS -1;
    write_address_even     : integer range 0 to P_BANDS/2-1;
    write_address_odd      : integer range 0 to P_BANDS/2-1;
    flag_write_to_even_row : std_logic;
    state_reg              : reg_state_type;
  end record;

  constant INITIAL_BEST_APPROX : remainder_after_approximation_record := (
    remainder        => (PIXEL_DATA_WIDTH*2-1 => '0', others => '1'),
    number_of_shifts => 0,
    remainder_valid  => '0'
    );
  constant DIV_PRECISION     : integer range 0 to 31                 := 17;

  function log2(i                    : natural) return integer;
  function sel (n                    : natural) return integer;
  function create_identity_matrix (n : natural) return matrix_32;

end Common_types_and_functions;

package body Common_types_and_functions is
  -- Found in SmallSat project description:
  --constant P_BANDS :  integer := 100;

  constant K : integer := 0;


  function log2(i : natural) return integer is
    variable temp    : integer := i;
    variable ret_val : integer := 0;
  begin
    while (temp > 1) loop
      ret_val := ret_val + 1;
      temp    := temp / 2;
    end loop;

    return ret_val;
  end function;

  function create_identity_matrix(n : natural) return matrix_32 is
    variable M_identity_matrix : matrix_32(0 to P_BANDS-1, 0 to P_BANDS-1);
  begin
    M_identity_matrix := (others => (others => (others => '0')));
    for i in 0 to n-1 loop
      M_identity_matrix(i, i) := std_logic_vector(to_unsigned(1, 32));
    end loop;
    return M_identity_matrix;
  end function;

  function sel(n : natural) return integer is
  begin
    return n;
  end function;



end Common_types_and_functions;
