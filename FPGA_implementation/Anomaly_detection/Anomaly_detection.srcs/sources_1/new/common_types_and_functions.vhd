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
--use IEEE.STD_LOGIC_ARITH.all;
use ieee.numeric_std.all;

library work;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package Common_types_and_functions is
  -- N_PIXELS is the number of pixels in the hyperspectral image
  constant N_PIXELS                   : integer range 0 to 628864 := 628864;  -- 578 pixels per row * 1088 rows
  -- P_BANDS  is the number of spectral bands
  constant P_BANDS                    : integer range 0 to 100    := 4;
  --constant P_BANDS : integer := 100;
  -- K is size of the kernel used in LRX. 
  constant K                          : integer;
  constant PIXEL_DATA_WIDTH           : integer                   := 16;
  constant NUMBER_OF_WRITES_PER_CYCLE : integer range 0 to 2      := 2;  -- NUMBER of
                                        -- writes to
                                        -- BRAM per
                                        -- cycle
  constant BRAM_TDP_ADDRESS_WIDTH     : integer range 0 to 10     := 10;
  -- component generics
  constant B_RAM_SIZE                 : integer                   := 100;
-- Need to be 33 bit due to updating of two 32 bit variables. Is 33 bit necessary? Precision  question.
  constant B_RAM_BIT_WIDTH            : integer                   := 32;

  type matrix is array (natural range <>, natural range <>) of std_logic_vector(15 downto 0);
  -- for correlation results
  type matrix_32 is array (natural range <>, natural range <>) of std_logic_vector(31 downto 0);

  type row_array is array (0 to P_BANDS-1) of signed(PIXEL_DATA_WIDTH*2 -1 downto 0);

  -- drive signals
  constant STATE_IDLE_DRIVE                        : std_logic_vector(2 downto 0) := "000";
  constant STATE_FORWARD_ELIM_TRIANGULAR_FINISHED  : std_logic_vector(2 downto 0) := "001";
  constant STATE_FORWARD_ELIMINATION_FINISHED      : std_logic_vector(2 downto 0) := "010";
  constant STATE_BACKWARD_ELIMINATION_FINISHED     : std_logic_vector(2 downto 0) := "011";
  constant STATE_IDENTITY_MATRIX_BUILDING_FINISHED : std_logic_vector(2 downto 0) := "111";

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

  type state_type is (STATE_IDLE, STATE_STORE_CORRELATION_MATRIX, STATE_FORWARD_ELIMINATION, STATE_BACKWARD_ELIMINATION, STATE_IDENTITY_MATRIX_BUILDING);

  type reg_state_type is record
    state                           : state_type;
    drive                           : std_logic_vector(2 downto 0);
    fsm_start_signal                : std_logic_vector(1 downto 0);
    inner_loop_iter_finished        : std_logic;
    inner_loop_last_iter_finished   : std_logic;
    start_inner_loop                : std_logic;
    forward_elim_ctrl_signal        : std_logic_vector(1 downto 0);
    forward_elim_state_signal       : std_logic_vector(1 downto 0);
    flag_forward_core_started       : std_logic;
    flag_forward_triangular_started : std_logic;
  end record;

  type row_reg_type is record
    row_j        : matrix_32(0 to 0, 0 to P_BANDS-1);
    row_i        : matrix_32(0 to 0, 0 to P_BANDS-1);
    inv_row_j    : matrix_32(0 to 0, 0 to P_BANDS-1);
    inv_row_i    : matrix_32(0 to 0, 0 to P_BANDS-1);
    a_j_i        : std_logic_vector(0 to 31);
    a_i_i        : std_logic_vector(0 to 31);
    elim_index_i : std_logic_vector(0 to 31);  -- outer loop index
    elim_index_j : std_logic_vector(0 to 31);  -- inner loop index
    valid_data   : std_logic;
  end record;

  type matrix_reg_type is record
    matrix            : matrix_32 (0 to P_BANDS-1, 0 to P_BANDS-1);
    matrix_inv        : matrix_32 (0 to P_BANDS-1, 0 to P_BANDS-1);
    valid_matrix_data : std_logic;
    row_reg           : row_reg_type;
    state_reg         : reg_state_type;
  end record;

  type input_elimination_reg_type is record
    row_j         : row_array;
    row_i         : row_array;
    inv_row_j     : row_array;
    inv_row_i     : row_array;
    state_reg     : reg_state_type;
    index_i       : integer range 0 to B_RAM_SIZE -1;
    index_j       : integer range 0 to B_RAM_SIZE -1;
    valid_data    : std_logic;
    write_address : integer range 0 to B_RAM_SIZE-1;
    read_address  : integer range 0 to B_RAM_SIZE-1;
  end record;
  type inverse_top_level_reg_type is record
    row_j                 : row_array;
    row_i                 : row_array;
    inv_row_j             : row_array;
    inv_row_i             : row_array;
    state_reg             : reg_state_type;
    index_i               : integer range 0 to B_RAM_SIZE -1;
    index_j               : integer range 0 to B_RAM_SIZE -1;
    valid_data            : std_logic;
    write_address         : integer range 0 to B_RAM_SIZE-1;
    read_address          : integer range 0 to B_RAM_SIZE-1;
    bram_write_data_M     : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0);
    bram_write_data_M_inv : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0);
    write_enable          : std_logic;
    read_enable           : std_logic;
    writes_done_on_column : std_logic_vector(1 downto 0);--should
                                                                       --be
                                                                       --size
                                                                       --log2(P_BANDS/2)
                                                                       --downto 0
  end record;

  type output_forward_elimination_reg_type is record
    new_row_j     : row_array;
    new_row_i     : row_array;
    new_inv_row_j : row_array;
    state_reg     : reg_state_type;
    r_addr_next   : integer range 0 to B_RAM_SIZE-1;
    wr_addr_new   : integer range 0 to B_RAM_SIZE-1;
    valid_data    : std_logic;
  end record;

  type output_backward_elimination_reg_type is record
    new_row_j     : row_array;
    new_inv_row_j : row_array;
    r_addr_next   : integer range 0 to B_RAM_SIZE-1;
    wr_addr_new   : integer range 0 to B_RAM_SIZE-1;
    valid_data    : std_logic;
    state_reg     : reg_state_type;
  end record;

  type input_last_division_reg_type is record
    row_i     : row_array;
    inv_row_i : row_array;
    state_reg : reg_state_type;
  end record;

  type output_last_division_reg_type is record
    new_inv_row_i : row_array;
    r_addr_next   : integer range 0 to B_RAM_SIZE-1;
    wr_addr_new   : integer range 0 to B_RAM_SIZE-1;
    state_reg     : reg_state_type;
  end record;

  constant C_ROW_REG_TYPE_INIT : row_reg_type := (
    row_j        => (others => (others => (others => '0'))),
    row_i        => (others => (others => (others => '0'))),
    inv_row_j    => (others => (others => (others => '0'))),
    inv_row_i    => (others => (others => (others => '0'))),
    a_j_i        => (others => '0'),
    a_i_i        => (others => '0'),
    elim_index_i => (others => '0'),
    elim_index_j => (others => '0'),
    valid_data   => '0'
    );


  constant C_STATE_REG_TYPE_INIT : reg_state_type := (
    state                           => STATE_IDLE,
    drive                           => STATE_IDLE_DRIVE,
    fsm_start_signal                => IDLING,
    inner_loop_iter_finished        => '0',
    inner_loop_last_iter_finished   => '0',
    start_inner_loop                => '0',
    forward_elim_ctrl_signal        => IDLING,
    forward_elim_state_signal       => IDLING,
    flag_forward_core_started       => '0',
    flag_forward_triangular_started => '0'
    );

  constant C_MATRIX_REG_TYPE_INIT : matrix_reg_type := (
    matrix            => (others => (others => (others => '0'))),
    matrix_inv        => (others => (others => (others => '0'))),
    valid_matrix_data => '0',
    row_reg           => C_ROW_REG_TYPE_INIT,
    state_reg         => C_STATE_REG_TYPE_INIT
    );

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
