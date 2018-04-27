----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/07/2018 02:19:19 PM
-- Design Name: 
-- Module Name: inverse_matrix - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;


library work;
use work.Common_types_and_functions.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- This entity is the top-level for computing the inverse of a matrix
-- It uses the two-step method, as described by Jiri Gaisler, with one modification;
-- added initialization process
entity inverse_matrix is
  port (reset_n               : in  std_logic;
        clk_en                : in  std_logic;
        clk                   : in  std_logic;
        valid                 : in  std_logic;  -- connect this to valid_out from
        -- correlation module
        din                   : in  std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0);
-- assumes that data are inputted row-wise
        --shifted_in_pixel_counter : in    std_logic_vector(log2(N_PIXELS) downto 0);
        writes_done_on_column : in  std_logic_vector(log2(P_BANDS/2) downto
                                                    0);  -- increases by one
                                                         -- for every two
                                                         -- writes to BRAM
        inverse_rows          : out signed(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0)  --outputting two and
                                        --two rows of the inverse matrix
        );
end inverse_matrix;

architecture Behavioral of inverse_matrix is
  signal r, r_in               : inverse_top_level_reg_type;
  signal output_backward_elim  : output_backward_elimination_reg_type;
  signal output_forward_elim   : output_forward_elimination_reg_type;
  signal output_last_division  : output_last_division_reg_type;
  --signal bram_write_data_M     : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0);
  --signal bram_write_data_M_inv : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0);
  signal data_out_brams_M      : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2-1 downto 0);
  signal data_out_brams_M_inv  : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2-1 downto 0);
  signal input_elimination     : input_elimination_reg_type;
  signal write_address_even    : integer range 0 to B_RAM_SIZE-1;  -- write
                                                                   -- address
                                                                   -- for even
                                                                   -- indexed
                                                                   -- BRAMs
  signal write_address_odd     : integer range 0 to B_RAM_SIZE-1;  -- write
                                                                   -- address
                                                                   -- for odd
                                                                   -- indexed
                                                                   -- BRAMs.
  signal read_address_even     : integer range 0 to B_RAM_SIZE-1;
  signal read_address_odd      : integer range 0 to B_RAM_SIZE-1;
  signal write_enable_odd      : std_logic := '0';
  signal write_enable_even     : std_logic := '0';
  -- for BRAMs containing the inverse matrix
  signal write_enable_inv_odd  : std_logic := '0';
  signal write_enable_inv_even : std_logic := '0';

  signal input_forward_elimination  : input_elimination_reg_type;
  signal input_backward_elimination : input_elimination_reg_type;
  constant EVEN_ROW_TOP_INDEX       : integer range 0 to P_BANDS*PIXEL_DATA_WIDTH*2-1   := P_BANDS*PIXEL_DATA_WIDTH*2 -1;
  -- index of the top bit of the even rows in data out from the BRAMs
  constant ODD_ROW_TOP_INDEX        : integer range 0 to 2*P_BANDS*PIXEL_DATA_WIDTH*2-1 := 2*P_BANDS*PIXEL_DATA_WIDTH*2 -1;
-- index of the topper bit of the odd rows in data out from the BRAMs

begin

  gen_BRAM_18_for_storing_correlation_matrix : for i in 0 to P_BANDS-1 generate
    -- Generating N_BRAMS = P_BANDS BRAM 36 kbits.
    -- Storing matrix M
    signal data_in_even_i, data_in_odd_i, data_out_even_i, data_out_odd_i : std_logic_vector(B_RAM_BIT_WIDTH -1 downto 0);
  --signal write_even_i, read_even_i, write_odd_i, read_odd_i             : integer range 0 to B_RAM_SIZE -1;
--value read from BRAM (odd index) before writing to address
  begin
    -- Block ram row for even addresses and row indexes of the correlation matrix
    block_ram_even : entity work.block_ram
      generic map (
        B_RAM_SIZE      => B_RAM_SIZE,
        B_RAM_BIT_WIDTH => B_RAM_BIT_WIDTH)
      port map (
        clk           => clk,
        aresetn       => reset_n,
        data_in       => data_in_even_i,
        write_enable  => write_enable_even,
        read_enable   => r.read_enable,
        read_address  => read_address_even,
        write_address => write_address_even,
        data_out      => data_out_even_i);
    -- Block ram row for odd addresses and row indexes of the correlation matrix
    block_ram_odd : entity work.block_ram
      generic map (
        B_RAM_SIZE      => B_RAM_SIZE,
        B_RAM_BIT_WIDTH => B_RAM_BIT_WIDTH)
      port map (
        clk           => clk,
        aresetn       => reset_n,
        data_in       => data_in_odd_i,
        write_enable  => write_enable_odd,
        read_enable   => r.read_enable,
        write_address => write_address_odd,
        read_address  => read_address_odd,
        data_out      => data_out_odd_i);

    -- Process to control data input to BRAMs.
    -- Maybe asynchronos?
    process(valid, r, output_last_division, output_forward_elim, output_backward_elim)
    begin
      if(r.state_reg.state = STATE_STORE_CORRELATION_MATRIX) then
        data_in_even_i <= r.bram_write_data_M(PIXEL_DATA_WIDTH*2-1 + i*PIXEL_DATA_WIDTH*2 downto i*PIXEL_DATA_WIDTH*2);
        data_in_odd_i  <= r.bram_write_data_M(PIXEL_DATA_WIDTH*2-1 +i*PIXEL_DATA_WIDTH*2+P_BANDS*PIXEL_DATA_WIDTH*2 downto i*PIXEL_DATA_WIDTH*2 + P_BANDS*PIXEL_DATA_WIDTH*2);
      elsif (r.state_reg.state = STATE_FORWARD_ELIMINATION) then
      elsif (r.state_reg.state = STATE_BACKWARD_ELIMINATION) then
        if(output_backward_elim.valid_data = '1') then
          -- Received data from backward elimination.
          if(output_backward_elim.flag_write_to_odd_row = '1') then
            -- the j-indexed row is an odd row of the matrix
            data_in_odd_i <= std_logic_vector(output_backward_elim.new_row_j(i));
          elsif(output_backward_elim.flag_write_to_even_row = '1') then
            -- the j-indexed row is an even row of the matrix 
            data_in_even_i <= std_logic_vector(output_backward_elim.new_row_j(i));
          end if;
        end if;
      elsif(r.state_reg.state = STATE_LAST_DIVISION) then
      end if;
    end process;
    data_out_brams_M(PIXEL_DATA_WIDTH*2-1 + i*PIXEL_DATA_WIDTH*2 downto i*PIXEL_DATA_WIDTH*2)                                                           <= data_out_even_i;
    data_out_brams_M(PIXEL_DATA_WIDTH*2-1 + i*PIXEL_DATA_WIDTH*2 + P_BANDS*PIXEL_DATA_WIDTH*2 downto i*PIXEL_DATA_WIDTH*2 + P_BANDS*PIXEL_DATA_WIDTH*2) <= data_out_odd_i;
  end generate;

  gen_BRAM_18_for_storing_inv_correlation_matrix : for i in 0 to P_BANDS-1 generate
    -- Generating N_BRAMS = P_BANDS BRAM 36 kbits.
    -- Storing matrix M_inv
    signal inv_data_in_even_i, inv_data_in_odd_i, inv_data_out_even_i, inv_data_out_odd_i : std_logic_vector(B_RAM_BIT_WIDTH -1 downto 0);
-- signal inv_write_even_i, inv_read_even_i, inv_write_odd_i, read_odd_i                 : integer range 0 to B_RAM_SIZE -1;
--value read from BRAM (odd index) before writing to address
  begin
    -- Block ram row for even indexes of the inverse matrix
    block_ram_even : entity work.block_ram
      generic map (
        B_RAM_SIZE      => B_RAM_SIZE,
        B_RAM_BIT_WIDTH => B_RAM_BIT_WIDTH)
      port map (
        clk           => clk,
        aresetn       => reset_n,
        data_in       => inv_data_in_even_i,
        write_enable  => write_enable_inv_even,
        read_enable   => r.read_enable,
        read_address  => read_address_even,
        write_address => write_address_even,
        data_out      => inv_data_out_even_i);
    -- Block ram row for odd indexes of the inverse matrix
    block_ram_odd : entity work.block_ram
      generic map (
        B_RAM_SIZE      => B_RAM_SIZE,
        B_RAM_BIT_WIDTH => B_RAM_BIT_WIDTH)
      port map (
        clk           => clk,
        aresetn       => reset_n,
        data_in       => inv_data_in_odd_i,
        write_enable  => write_enable_inv_odd,
        read_enable   => r.read_enable,
        write_address => write_address_odd,
        read_address  => read_address_odd,
        data_out      => inv_data_out_odd_i);

    -- Process to control data input to BRAMs.
    process(valid, r, output_forward_elim, output_backward_elim, output_last_division)
      variable test : std_logic_vector(31 downto 0);
    begin
      if(r.state_reg.state = STATE_STORE_CORRELATION_MATRIX) then
        inv_data_in_even_i <= r.bram_write_data_M_inv(PIXEL_DATA_WIDTH*2-1 + i*PIXEL_DATA_WIDTH*2 downto i*PIXEL_DATA_WIDTH*2);
        inv_data_in_odd_i  <= r.bram_write_data_M_inv(PIXEL_DATA_WIDTH*2-1 +i*PIXEL_DATA_WIDTH*2+P_BANDS*PIXEL_DATA_WIDTH*2 downto i*PIXEL_DATA_WIDTH*2 + P_BANDS*PIXEL_DATA_WIDTH*2);
      elsif (r.state_reg.state = STATE_FORWARD_ELIMINATION) then
      elsif (r.state_reg.state = STATE_BACKWARD_ELIMINATION) then
        if(output_backward_elim.valid_data = '1') then
          -- Received data from backward elimination.
          if(output_backward_elim.flag_write_to_odd_row = '1') then
            -- the j-indexed row is an odd row of the matrix
            test              := std_logic_vector(output_backward_elim.new_inv_row_j(i));
            inv_data_in_odd_i <= std_logic_vector(output_backward_elim.new_inv_row_j(i));
          elsif(output_backward_elim.flag_write_to_even_row = '1') then
            -- the j-indexed row is an even row of the matrix 
            test               := std_logic_vector(output_backward_elim.new_inv_row_j(i));
            inv_data_in_even_i <= std_logic_vector(output_backward_elim.new_inv_row_j(i));
          end if;
        end if;
      elsif(r.state_reg.state = STATE_LAST_DIVISION) then
      end if;
    end process;
-- DATA outputted from the BRAMs
    data_out_brams_M_inv(PIXEL_DATA_WIDTH*2-1 + i*PIXEL_DATA_WIDTH*2 downto i*PIXEL_DATA_WIDTH*2)                                                           <= inv_data_out_even_i;
    data_out_brams_M_inv(PIXEL_DATA_WIDTH*2-1 + i*PIXEL_DATA_WIDTH*2 + P_BANDS*PIXEL_DATA_WIDTH*2 downto i*PIXEL_DATA_WIDTH*2 + P_BANDS*PIXEL_DATA_WIDTH*2) <= inv_data_out_odd_i;

  end generate;

  -- top_forward_elimination_1 : entity work.top_forward_elimination
  --   port map (
  --     clk                        => clk,
  --     reset_n                    => reset_n,
  --     clk_en                     => clk_en,
  --     input_elimination          => input_elimination,
  --     output_forward_elimination => output_forward_elim);

--  top_backward_elimination_1 : entity work.top_backward_elimination
--    port map (
--      clk                  => clk,
--      reset_n              => reset_n,
--      clk_en               => clk_en,
--      din                  => input_backward_elimination,
--      backward_elim_output => output_backward_elim);
  backward_elim_core_1 : entity work.backward_elim_core
    port map (
      clk                  => clk,
      reset_n              => reset_n,
      clk_en               => clk_en,
      input_backward_elim  => input_backward_elimination,
      output_backward_elim => output_backward_elim);

  -- top_last_division_1 : entity work.top_last_division
  --   port map (
  --     clk             => clk,
  --     reset_n         => reset_n,
  --     clk_en          => clk_en,
  --     M               => M_inv,
  --     M_last_division => output_last_division);
  just_for_test : process(data_out_brams_M)
    variable row_even, row_odd, inv_row_even, inv_row_odd : row_array;
  begin
    for i in 0 to P_BANDS-1 loop
      row_even(i)     := signed(data_out_brams_M(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2-1 downto i*PIXEL_DATA_WIDTH*2));
      row_odd(i)      := signed(data_out_brams_M(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX downto i*PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX+1));
-- the odd row
      inv_row_even(i) := signed(data_out_brams_M_inv(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2-1 downto i*PIXEL_DATA_WIDTH*2));
      inv_row_odd(i)  := signed(data_out_brams_M_inv(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX downto i*PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX+1));
    end loop;
  end process;

-- control address inputs and control inputs to BRAMs  
  control_addresses_and_control_BRAM : process(r, output_backward_elim, output_last_division, output_forward_elim)
  begin
    if(r.state_reg.state = STATE_STORE_CORRELATION_MATRIX) then
      write_address_even    <= r.write_address_even;
      write_address_odd     <= r.write_address_odd;
      read_address_even     <= r.read_address_even;
      read_address_odd      <= r.read_address_odd;
      write_enable_even     <= '1';
      write_enable_odd      <= '1';
      write_enable_inv_even <= '1';
      write_enable_inv_odd  <= '1';
    elsif (r.state_reg.state = STATE_FORWARD_ELIMINATION) then
      read_address_even <= r.read_address_even;
      read_address_odd  <= r.read_address_odd;
    elsif(r.state_reg.state = STATE_BACKWARD_ELIMINATION) then
      read_address_even <= r.read_address_even;
      read_address_odd  <= r.read_address_odd;
      if(output_backward_elim.valid_data = '1') then
        --write_enable_even     <= output_backward_elim.write_enable_even;
        --write_enable_odd      <= output_backward_elim.write_enable_odd;
        --write_enable_inv_even <= output_backward_elim.write_enable_even;
        --write_enable_inv_odd  <= output_backward_elim.write_enable_odd;
        -- Received data from backward elimination.
        if(output_backward_elim.flag_write_to_odd_row = '1') then
          -- the j-indexed row is an odd row of the matrix
          write_enable_inv_odd  <= '1';
          write_enable_inv_even <= '0';
          write_enable_odd      <= '1';
          write_enable_even     <= '0';
          write_address_odd     <= output_backward_elim.write_address_odd;
        elsif(output_backward_elim.flag_write_to_even_row = '1') then
          -- the j-indexed row is an even row of the matrix 
          write_enable_inv_odd  <= '0';
          write_enable_inv_even <= '1';
          write_enable_odd      <= '0';
          write_enable_even     <= '1';
          write_address_even    <= output_backward_elim.write_address_even;
        end if;
      else
        write_enable_inv_odd  <= '0';
        write_enable_inv_even <= '0';
        write_enable_even     <= '0';
        write_enable_odd      <= '0';
      end if;
    elsif r.state_reg.state = STATE_LAST_DIVISION then
      read_address_odd  <= r.read_address_odd;
      read_address_even <= r.read_address_even;
    end if;

  end process;

-- control inputs to elimination processes
  control_input_to_elimination : process(r, output_backward_elim, output_last_division, output_forward_elim)
  begin
    if(r.state_reg.state = STATE_FORWARD_ELIMINATION) then
    elsif(r.state_reg.state = STATE_BACKWARD_ELIMINATION) then
      if(r.valid_data = '1') then
        -- set input to backward elimination
        input_backward_elimination.row_j                  <= r.row_j;
        input_backward_elimination.row_i                  <= r.row_i;
        input_backward_elimination.index_i                <= r.index_i;
        input_backward_elimination.index_j                <= r.index_j;
        input_backward_elimination.inv_row_j              <= r.inv_row_j;
        input_backward_elimination.inv_row_i              <= r.inv_row_i;
        input_backward_elimination.valid_data             <= r.valid_data;
        input_backward_elimination.state_reg              <= r.state_reg;
        input_backward_elimination.write_address_even     <= r.write_address_even;
        input_backward_elimination.write_address_odd      <= r.write_address_odd;
        input_backward_elimination.flag_write_to_even_row <= r.flag_write_to_even_row;
        input_backward_elimination.flag_write_to_odd_row  <= r.flag_write_to_odd_row;
        input_backward_elimination.write_enable_even      <= r.write_enable_even;
        input_backward_elimination.write_enable_odd       <= r.write_enable_odd;
      end if;

    elsif(r.state_reg.state = STATE_LAST_DIVISION) then
    end if;
  end process;


  comb : process(reset_n, valid, r, data_out_brams_M_inv, data_out_brams_M, output_forward_elim, output_backward_elim, output_last_division, din)  -- combinatorial process
    variable v : inverse_top_level_reg_type;
  begin
    v := r;
    case v.state_reg.state is
      when STATE_IDLE =>
        v.read_enable       := '0';
        v.write_enable_even := '0';
        v.write_enable_odd  := '0';
        if(valid = '1') then
          v.state_reg.state                                                                                                        := STATE_STORE_CORRELATION_MATRIX;
                                        -- Set write address to BRAMS
          v.write_address_even                                                                                                     := 0;
          v.flag_last_read_backward_elimination                                                                                    := '0';
          v.read_address_odd                                                                                                       := 0;
          v.read_address_even                                                                                                      := 0;
          v.write_enable_odd                                                                                                       := '1';
          v.write_enable_even                                                                                                      := '1';
          v.read_enable                                                                                                            := '1';
          v.bram_write_data_M                                                                                                      := din;
          v.writes_done_on_column                                                                                                  := writes_done_on_column;
          v.bram_write_data_M_inv                                                                                                  := (others => '0');
          v.bram_write_data_M_inv                                                                                                  := (others => '0');
          v.bram_write_data_M_inv((to_integer(unsigned(r.writes_done_on_column))*2)*PIXEL_DATA_WIDTH*2)                            := '1';  -- creating the identity matrix
          v.bram_write_data_M_inv((to_integer(unsigned(writes_done_on_column))*2+1)*PIXEL_DATA_WIDTH*2+P_BANDS*PIXEL_DATA_WIDTH*2) := '1';
          v.wait_counter                                                                                                           := 0;
          v.flag_waiting_for_bram_update                                                                                           := '0';
        end if;
        v.state_reg.drive := IDLING;
                                        -- need to wait until valid data on all
      when STATE_STORE_CORRELATION_MATRIX =>
                                        -- SET BRAM to write input data 
        v.writes_done_on_column                                                                                                  := writes_done_on_column;
        v.write_address_even                                                                                                     := r.write_address_even +1;  -- r.write_address +1;
        v.write_address_odd                                                                                                      := r.write_address_odd +1;  -- r.write_address +1;
        v.read_address_odd                                                                                                       := r.read_address_odd+1;
        v.read_address_even                                                                                                      := r.read_address_even+1;
        v.write_enable_even                                                                                                      := '1';
        v.write_enable_odd                                                                                                       := '1';
        v.read_enable                                                                                                            := '1';
        v.bram_write_data_M                                                                                                      := din;
        v.bram_write_data_M_inv                                                                                                  := (others => '0');
        v.bram_write_data_M_inv((to_integer(unsigned(writes_done_on_column))*2)*PIXEL_DATA_WIDTH*2)                              := '1';  -- creating the identity matrix
        v.bram_write_data_M_inv((to_integer(unsigned(writes_done_on_column))*2+1)*PIXEL_DATA_WIDTH*2+P_BANDS*PIXEL_DATA_WIDTH*2) := '1';
        v.flag_waiting_for_bram_update                                                                                           := '0';
        if (to_integer(unsigned(r.writes_done_on_column)) +1 < P_BANDS/2) then
          v.bram_write_data_M_inv((to_integer(unsigned(writes_done_on_column))*2)*PIXEL_DATA_WIDTH*2)                              := '1';  -- creating the identity matrix
          v.bram_write_data_M_inv((to_integer(unsigned(writes_done_on_column))*2+1)*PIXEL_DATA_WIDTH*2+P_BANDS*PIXEL_DATA_WIDTH*2) := '1';
        end if;
        if to_integer(unsigned(r.writes_done_on_column)) = P_BANDS/2-1 then
                                                                                                                                          -- Need to wait until the entire correlation matrix have been stored
                                        -- in BRAM before starting to edit it.
          v.state_reg.state            := STATE_FORWARD_ELIMINATION;
          v.state_reg.fsm_start_signal := START_FORWARD_ELIMINATION;
          v.write_enable_even          := '0';
          v.write_enable_odd           := '0';
          v.wait_counter               := 0;

        end if;
        if valid = '0' then
          v.state_reg.state := STATE_IDLE;
          v.state_reg.drive := STATE_IDLE_DRIVE;
        end if;
      when STATE_FORWARD_ELIMINATION =>
        v.state_reg.fsm_start_signal := IDLING;
        -- expecting data from FORWARD_ELIMINATION
        -- it must write to BRAM before being finished


        --*FOR TESTING OF BACKWARD_ELIMINATION ONLY*--
        -- Needs to be a if here somewhere under the rainbow
        v.state_reg.state               := STATE_BACKWARD_ELIMINATION;
        v.state_reg.fsm_start_signal    := START_BACKWARD_ELIMINATION;
        v.flag_first_iter_backward_elim := '1';
        -- Request data for BACKWARD elimination
        v.read_address_even             := P_BANDS/2-1;  --read toppermost address ( contains row
        v.read_address_odd              := P_BANDS/2-1;  --read toppermost address ( contains row
        -- P_BANDS-1 and P_BANDS -2 in odd and
        --even BRAMs respectively
        --* END OF TEST SECTION FOR BACKWARD ELIMINATION *--

        if(output_forward_elim.state_reg.drive = STATE_FORWARD_ELIMINATION_FINISHED) then
          v.row_j                      := output_forward_elim.new_row_j;  -- going to be
                                        -- written to BRAM
          v.row_i                      := output_forward_elim.new_row_i;
          v.inv_row_j                  := output_forward_elim.new_inv_row_j;
          v.state_reg.drive            := output_forward_elim.state_reg.drive;
          v.state_reg.state            := STATE_BACKWARD_ELIMINATION;
          v.state_reg.fsm_start_signal := START_BACKWARD_ELIMINATION;
          -- Need to read the two last rows. Making ready for backward elimination
          v.read_address_odd           := P_BANDS/2-1;
          v.read_address_even          := P_BANDS/2-1;
        end if;
      when STATE_BACKWARD_ELIMINATION =>
        if(r.flag_first_iter_backward_elim = '1') then
          -- Read first data from BRAMs 
          v.write_address_even                                := P_BANDS/2-1;  -- first write will happen
                                        -- to even row, located
                                        -- in even BRAMs.
          v.write_address_odd                                 := P_BANDS/2-1;
          v.read_enable                                       := '1';
          v.write_enable_even                                 := '0';
          v.write_enable_odd                                  := '0';
          v.flag_first_data_elimination                       := '0';
          --v.flag_waited_one_clk                               := '0';
          v.flag_first_memory_request                         := '1';
          v.index_j_two_cycles_ahead                          := P_BANDS-2;
          v.index_i_two_cycles_ahead                          := P_BANDS-1;
          v.read_address_row_i_two_cycles_ahead               := P_BANDS/2-1;
          v.read_address_even                                 := P_BANDS/2-1;
          v.read_address_odd                                  := P_BANDS/2-1;
          v.address_row_i                                     := P_BANDS/2-1;
          v.flag_finished_sending_data_to_BRAM_one_cycle_ago  := '0';
          v.flag_finished_sending_data_to_BRAM_two_cycles_ago := '0';
          v.flag_wr_row_i_at_odd_row                          := '1';
          v.flag_prev_row_i_at_odd_row                        := '1';
          v.flag_first_iter_backward_elim                     := '0';
          v.wait_counter                                      := 0;
          v.flag_waiting_for_bram_update                      := '0';
        end if;

        if(r.flag_first_memory_request = '1') then
          v.flag_first_memory_request := '0';
          --v.flag_waited_one_clk       := '1';
          v.index_j_two_cycles_ahead  := r.index_j_two_cycles_ahead -1;
          v.read_address_even         := r.read_address_even -1;
          -- need to read an odd row
          v.read_address_odd          := r.read_address_odd -1;

          v.flag_first_data_elimination := '1';

        end if;
        -- if(r.flag_waited_one_clk = '1') then
        --   v.flag_first_data_elimination := '1';  -- the next clock cycle the BRAM
        --                                 -- will have the correct output, for
        --   -- the first input of the inverse matrix
        --   v.flag_waited_one_clk :='0';
        --   if(r.index_j_two_cycles_ahead-1 >= 0) then
        --     -- need to read an even row, do not change read address
        --     v.index_j_two_cycles_ahead := r.index_j_two_cycles_ahead-1;
        --   end if;
        -- end if;
        if (r.flag_first_data_elimination = '1') then  --received the first
          --input_data to backward elimination from BRAM
          v.state_reg.fsm_start_signal  := START_BACKWARD_ELIMINATION;
          -- must set the flag low again
          v.flag_first_data_elimination := '0';
          for i in 0 to P_BANDS-1 loop
            v.row_j(i)     := signed(data_out_brams_M(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2-1 downto i*PIXEL_DATA_WIDTH*2));
            v.row_i(i)     := signed(data_out_brams_M(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX downto i*PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX+1));
-- the odd row
            v.inv_row_j(i) := signed(data_out_brams_M_inv(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2-1 downto i*PIXEL_DATA_WIDTH*2));
            v.inv_row_i(i) := signed(data_out_brams_M_inv(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX downto i*PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX+1));
          end loop;
          v.index_i                  := P_BANDS-1;
          v.index_j                  := P_BANDS-2;
          v.address_row_i            := P_BANDS/2-1;
          v.valid_data               := '1';
          -- The first written j-row will alway be at an even-row.
          v.flag_write_to_even_row   := '1';
          v.flag_write_to_odd_row    := '0';
          v.write_enable_even        := '1';
          v.write_enable_odd         := '0';
          v.write_address_even       := P_BANDS/2 -1;
          v.write_address_odd        := P_BANDS/2-1;
          v.flag_wr_row_i_at_odd_row := '1';
          v.elimination_write_state  := ODD_j_WRITE;
          -- read new data
          if(r.read_address_odd >= 0 and r.index_j_two_cycles_ahead >= 1) then
            -- need to read an even row 
            v.read_address_odd         := r.read_address_odd;
            v.read_address_even        := r.read_address_even;
            v.index_j_two_cycles_ahead := r.index_j_two_cycles_ahead-1;
          elsif r.index_j_two_cycles_ahead < 1 then
            -- new i or finished, update
            if r.index_i_two_cycles_ahead >= 2 then
              v.index_i_two_cycles_ahead := r.index_i_two_cycles_ahead-1;
              v.index_j_two_cycles_ahead := r.index_i_two_cycles_ahead-1;
              if r.flag_prev_row_i_at_odd_row = '1' then
                -- next row i will be located in an even indexed row
                v.read_address_even                   := r.read_address_row_i_two_cycles_ahead;
                v.read_address_odd                    := r.read_address_row_i_two_cycles_ahead-1;
                v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead;
                v.flag_prev_row_i_at_odd_row          := '0';
              else
                -- next row_i will be located in an odd indexed row
                v.read_address_odd                    := r.read_address_row_i_two_cycles_ahead -1;
                v.read_address_even                   := r.read_address_row_i_two_cycles_ahead -1;
                v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead-1;
                v.flag_prev_row_i_at_odd_row          := '1';
              end if;
            end if;
          end if;
        end if;
        case r.elimination_write_state is
          when ODD_j_WRITE =>
            if r.flag_waiting_for_bram_update = '0' then
              v.flag_write_to_even_row := '0';
              v.flag_write_to_odd_row  := '1';
              -- row_j is outputted from odd BRAMs(located at higher end of output)
              for i in 0 to P_BANDS-1 loop
                v.row_j(i)     := signed(data_out_brams_M(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX downto i*PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX+1));
                v.inv_row_j(i) := signed(data_out_brams_M_inv(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX downto i*PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX+1));
              end loop;
              v.write_enable_even := '0';
              v.write_enable_odd  := '1';
              v.index_j           := r.index_j -1;
              if r.index_j >= 1 then
                v.write_address_odd  := r.write_address_odd -1;
                v.write_address_even := r.write_address_even -1;
              end if;
            end if;

            if v.index_j <= 1 and r.index_i_two_cycles_ahead-2 - v.index_j < B_RAM_WAIT_CLK_CYCLES and r.wait_counter < B_RAM_WAIT_CLK_CYCLES-(r.index_i_two_cycles_ahead-2 -v.index_j) then
              -- Need to wait for the row to update before reading it.
              v.wait_counter                 := r.wait_counter +1;
              v.flag_waiting_for_bram_update := '1';
            else
              v.flag_waiting_for_bram_update := '0';
              v.wait_counter                 := 0;
              if(v.index_j >= 1) then
                --v.index_j                 := r.index_j -1;
                v.elimination_write_state := EVEN_j_WRITE;
              elsif v.index_j < 1 then
                --v.index_i := r.index_i -1;
                --v.index_j := r.index_i -2;
                if(r.flag_wr_row_i_at_odd_row = '0') then
                  v.elimination_write_state := ODD_i_START;
                else
                  v.elimination_write_state := EVEN_i_START;
                end if;
              end if;
              -- read new data. Data need to be read two clock cycles in advance 
              if(r.read_address_odd >= 1 and r.index_j_two_cycles_ahead >= 2) then
                -- need to read an odd row 
                v.read_address_odd         := r.read_address_odd-1;
                v.read_address_even        := r.read_address_even-1;
                v.index_j_two_cycles_ahead := r.index_j_two_cycles_ahead-1;
              elsif v.index_j < 2 then
                -- new i, update
                if r.index_i_two_cycles_ahead >= 2 then
                  v.index_i_two_cycles_ahead := r.index_i_two_cycles_ahead-1;
                  v.index_j_two_cycles_ahead := r.index_i_two_cycles_ahead-2;
                  if r.flag_prev_row_i_at_odd_row = '1' then
                    -- next row i will be located in an even indexed row
                    v.read_address_even                   := r.address_row_i;
                    v.read_address_odd                    := r.address_row_i-1;
                    v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead;
                    v.flag_prev_row_i_at_odd_row          := '0';
                  else
                    -- next row_i will be located in an odd indexed row
                    v.read_address_odd                    := r.read_address_row_i_two_cycles_ahead -1;
                    v.read_address_even                   := r.read_address_row_i_two_cycles_ahead -1;
                    v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead-1;
                    v.flag_prev_row_i_at_odd_row          := '1';
                  end if;
                end if;
              end if;
            end if;
          when EVEN_j_WRITE =>
            if r.flag_waiting_for_bram_update = '0' then
              for i in 0 to P_BANDS-1 loop
                -- data is located in the even part of the output from BRAM
                v.row_j(i)     := signed(data_out_brams_M(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2-1 downto i*PIXEL_DATA_WIDTH*2));
                v.inv_row_j(i) := signed(data_out_brams_M_inv(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2-1 downto i*PIXEL_DATA_WIDTH*2));
              end loop;
              v.flag_write_to_even_row := '1';
              v.flag_write_to_odd_row  := '0';
              v.write_address_even     := r.write_address_even;
              v.write_address_odd      := r.write_address_odd;
              v.write_enable_even      := '1';
              v.write_enable_odd       := '0';
              v.index_j                := r.index_j -1;
              v.index_i                := r.index_i;
            end if;

            if v.index_j <= 1 and r.index_j_two_cycles_ahead-1- v.index_j < B_RAM_WAIT_CLK_CYCLES and r.wait_counter < B_RAM_WAIT_CLK_CYCLES-(r.index_j_two_cycles_ahead-1 -v.index_j) then
              v.wait_counter                 := r.wait_counter+1;
              v.flag_waiting_for_bram_update := '1';
            else
              v.wait_counter :=0;
              v.flag_waiting_for_bram_update :='0';
              if(v.index_j >= 2) then
                v.elimination_write_state := ODD_j_WRITE;
              elsif v.index_j < 2 then
                if(r.flag_wr_row_i_at_odd_row = '0') then
                  v.elimination_write_state := ODD_i_START;
                else
                  v.elimination_write_state := EVEN_i_START;
                end if;
              end if;
              -- read new data
              --if(r.read_address_odd >= 1 and v.index_j >= 1) then
              if r.flag_last_read_backward_elimination = '0' then
                if(r.read_address_odd >= 0 and r.index_j_two_cycles_ahead >= 1) then
                  -- need to read an even row("two clock cycles ahead") 
                  -- Even and odd read addresses will be equal in backward
                  -- elimination except for when reading the first read for a even
                  -- indexed i.
                  v.read_address_odd         := r.read_address_odd;
                  --v.read_address_even        := r.read_address_even;
                  v.read_address_even        := r.read_address_odd;
                  v.index_j_two_cycles_ahead := r.index_j_two_cycles_ahead-1;
                elsif v.index_j < 2 then
                  -- new i or finished, update
                  if v.index_i >= 2 then
                    v.index_i_two_cycles_ahead := r.index_i_two_cycles_ahead-1;
                    v.index_j_two_cycles_ahead := r.index_i_two_cycles_ahead-2;
                    if r.flag_prev_row_i_at_odd_row = '1' then
                      -- next row i will be located in an even indexed row
                      v.read_address_even                   := r.read_address_row_i_two_cycles_ahead;
                      v.read_address_odd                    := r.read_address_row_i_two_cycles_ahead-1;
                      v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead;
                      v.flag_prev_row_i_at_odd_row          := '0';
                    else
                      -- next row_i will be located in an odd indexed row
                      v.read_address_odd                    := r.read_address_row_i_two_cycles_ahead -1;
                      v.read_address_even                   := r.read_address_row_i_two_cycles_ahead -1;
                      v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead-1;
                      v.flag_prev_row_i_at_odd_row          := '1';
                    end if;
                  end if;
                end if;
              end if;
            end if;
          when ODD_i_START =>
            if(r.flag_finished_sending_data_to_BRAM_one_cycle_ago = '0') then
              for i in 0 to P_BANDS-1 loop
                v.row_j(i)     := signed(data_out_brams_M(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2-1 downto i*PIXEL_DATA_WIDTH*2));
                v.row_i(i)     := signed(data_out_brams_M(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX downto i*PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX+1));
-- the odd row
                v.inv_row_j(i) := signed(data_out_brams_M_inv(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2-1 downto i*PIXEL_DATA_WIDTH*2));
                v.inv_row_i(i) := signed(data_out_brams_M_inv(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX downto i*PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX+1));
              end loop;
              v.flag_write_to_even_row   := '1';
              v.flag_wr_row_i_at_odd_row := '1';
              v.flag_write_to_odd_row    := '0';
              v.index_i                  := r.index_i-1;
              v.index_j                  := r.index_i-2;
              v.address_row_i            := r.address_row_i-1;
              v.write_address_even       := r.address_row_i-1;
              v.write_address_odd        := r.address_row_i-1;
              v.write_enable_even        := '1';
              v.write_enable_odd         := '0';
              if(v.index_j > 1) then    -- the first two indexes are contained
                -- within address 0
                --v.index_j                 := r.index_j -1;
                v.elimination_write_state := ODD_j_WRITE;
              elsif v.index_j = 0 and v.index_i = 1 then
                -- In two clock cycles the data will be written to B_RAM.
                -- and it is possible to change state to TOP_LAST_DIVISON.
                v.flag_finished_sending_data_to_BRAM_one_cycle_ago := '1';
              end if;

              if r.flag_last_read_backward_elimination = '0' then
                if(r.read_address_odd >= 0 and r.index_j_two_cycles_ahead >= 1) then
                  --if(r.read_address_odd >= 1 and r.index_j_two_cycles_ahead >= 2) then
                  -- need to read an even row 
                  v.read_address_odd         := r.read_address_odd;
                  v.read_address_even        := r.read_address_even;
                  v.index_j_two_cycles_ahead := r.index_j_two_cycles_ahead-1;
                elsif r.index_j_two_cycles_ahead < 1 then
                  -- new i or finished, update
                  if r.index_i_two_cycles_ahead >= 2 then
                    v.index_i_two_cycles_ahead := r.index_i_two_cycles_ahead-1;
                    v.index_j_two_cycles_ahead := v.index_i_two_cycles_ahead-2;
                    if r.flag_prev_row_i_at_odd_row = '1' then
                      -- next row i will be located in an even indexed row
                      v.read_address_even                   := r.read_address_row_i_two_cycles_ahead;
                      v.read_address_odd                    := r.read_address_row_i_two_cycles_ahead-1;
                      v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead;
                      v.flag_prev_row_i_at_odd_row          := '0';
                    else
                      -- next row_i will be located in an odd indexed row
                      v.read_address_odd                    := r.read_address_row_i_two_cycles_ahead -1;
                      v.read_address_even                   := r.read_address_row_i_two_cycles_ahead -1;
                      v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead-1;
                      v.flag_prev_row_i_at_odd_row          := '1';
                    end if;
                  end if;
                end if;
              end if;
            else
              --v                                                   := r;
              --v.flag_finished_sending_data_to_BRAM_one_cycle_ago  := '1';
              v.flag_finished_sending_data_to_BRAM_two_cycles_ago := '1';
            end if;

            if(r.flag_finished_sending_data_to_BRAM_two_cycles_ago = '1') then
              v.state_reg.state := STATE_LAST_DIVISION;
            end if;

          when EVEN_i_START =>
            for i in 0 to P_BANDS-1 loop
              v.row_i(i)     := signed(data_out_brams_M(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2-1 downto i*PIXEL_DATA_WIDTH*2));
              v.row_j(i)     := signed(data_out_brams_M(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX downto i*PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX+1));
-- the odd row
              v.inv_row_i(i) := signed(data_out_brams_M_inv(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2-1 downto i*PIXEL_DATA_WIDTH*2));
              v.inv_row_j(i) := signed(data_out_brams_M_inv(i*PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX downto i*PIXEL_DATA_WIDTH*2 +EVEN_ROW_TOP_INDEX+1));
            end loop;
            v.flag_wr_row_i_at_odd_row := '0';
            v.flag_write_to_even_row   := '0';
            v.flag_write_to_odd_row    := '1';
            v.index_i                  := r.index_i-1;
            v.index_j                  := r.index_i-2;
            v.address_row_i            := r.address_row_i;
            v.write_address_even       := r.address_row_i -1;
            v.write_address_odd        := r.address_row_i -1;
            v.write_enable_even        := '0';
            v.write_enable_odd         := '1';
            if(v.index_j >= 1) then
              v.elimination_write_state := EVEN_j_WRITE;
            end if;
            -- read new data. 
            if r.flag_last_read_backward_elimination = '0' then
              if(r.read_address_odd >= 1 and r.index_j_two_cycles_ahead >= 2) then
                -- need to read an odd row 
                v.read_address_odd         := r.read_address_odd-1;
                v.read_address_even        := r.read_address_even-1;
                v.index_j_two_cycles_ahead := r.index_j_two_cycles_ahead-1;
              elsif r.index_j_two_cycles_ahead < 1 then
                -- new i, update
                if r.index_i_two_cycles_ahead >= 2 then
                  v.index_i_two_cycles_ahead := r.index_i_two_cycles_ahead-1;
                  v.index_j_two_cycles_ahead := r.index_i_two_cycles_ahead-2;
                  if r.flag_prev_row_i_at_odd_row = '1' then
                    -- next row i will be located in an even indexed row
                    v.read_address_even                   := r.read_address_row_i_two_cycles_ahead;
                    v.read_address_odd                    := r.read_address_row_i_two_cycles_ahead-1;
                    v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead;
                    v.flag_prev_row_i_at_odd_row          := '0';
                  else
                    -- next row_i will be located in an odd indexed row
                    v.read_address_odd                    := r.read_address_row_i_two_cycles_ahead -1;
                    v.read_address_even                   := r.read_address_row_i_two_cycles_ahead -1;
                    v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead-1;
                    v.flag_prev_row_i_at_odd_row          := '1';
                  end if;
                end if;
                if v.index_i_two_cycles_ahead = 1 then
                  -- Finished reading data for backward elimination
                  v.flag_last_read_backward_elimination := '1';
                end if;
              end if;
            end if;
          when others =>
        end case;
      when STATE_LAST_DIVISION =>
        if r.wait_counter < B_RAM_WAIT_CLK_CYCLES then
          v.read_address_even := 0;
          v.read_address_odd  := 0;
          v.wait_counter      := r.wait_counter +1;
        else
          v.read_address_even := 1;
          v.read_address_odd  := 1;
        end if;
        if(output_last_division.state_reg.drive = STATE_LAST_DIVISION_FINISHED) then
          -- state_reg.drive as finish-check signal
          v.inv_row_i       := output_last_division.new_inv_row_i;
          v.state_reg.drive := output_last_division.state_reg.drive;
        end if;
      when others =>
        v.read_enable       := '0';
        v.write_enable_even := '0';
        v.write_enable_odd  := '0';
    --      v.row_j :=                      -- row_j outputted from BRAM
    --      v.row_i :=                      -- row_j outputted from BRAM
    --  v.inv_row_j :=                      -- row_j outputted from BRAM
    --  v.inv_row_i :=                      -- row_j outputted from BRAM
    end case;
    if(reset_n = '0') then
      v.read_enable       := '0';
      v.write_enable_even := '0';
      v.write_enable_odd  := '0';
    --     v.row_j :=                        --value outputted from BRAM;
    --     v.row_i :=                        -- row_j outputted from BRAM
    -- v.inv_row_j :=                        -- row_j outputted from BRAM
    -- v.inv_row_i :=                        -- row_j outputted from BRAM
    end if;
    r_in <= v;
  end process;


  regs : process(clk, reset_n, clk_en)
  begin
    if rising_edge(clk) and clk_en = '1' then
      if(reset_n = '0') then
                                        --r.matrix_inv <= M_identity_matrix;
      else
        r <= r_in;
      end if;
    end if;

  end process;

end Behavioral;
