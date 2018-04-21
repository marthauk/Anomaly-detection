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
  signal r, r_in              : inverse_top_level_reg_type;
  signal output_backward_elim : output_backward_elimination_reg_type;
  signal output_forward_elim  : output_forward_elimination_reg_type;
  signal output_last_division : output_last_division_reg_type;
  --signal bram_write_data_M     : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0);
  --signal bram_write_data_M_inv : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto 0);
  signal data_out_brams_M     : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2-1 downto 0);
  signal data_out_brams_M_inv : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2-1 downto 0);
  signal input_elimination    : input_elimination_reg_type;
  signal write_address_even   : integer range 0 to B_RAM_SIZE-1;  -- write
                                                                  -- address
                                                                  -- for even
                                                                  -- indexed
                                                                  -- BRAMs
  signal write_address_odd    : integer range 0 to B_RAM_SIZE-1;  -- write
                                                                  -- address
                                                                  -- for odd
                                                                  -- indexed
                                                                  -- BRAMs.
  signal read_address_even    : integer range 0 to B_RAM_SIZE-1;
  signal read_address_odd     : integer range 0 to B_RAM_SIZE-1;

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
        write_enable  => r.write_enable,
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
        write_enable  => r.write_enable,
        read_enable   => r.read_enable,
        write_address => write_address_odd,
        read_address  => read_address_odd,
        data_out      => data_out_odd_i);

    -- Process to control data input to BRAMs.
    -- Maybe asynchronos?
    process(valid, r.bram_write_data_M)
      variable test : std_logic_vector(31 downto 0);
    begin
      test           := r.bram_write_data_M(P_BANDS*PIXEL_DATA_WIDTH*2*2 - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*2 + PIXEL_DATA_WIDTH*2 -1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*2);
      data_in_even_i <= r.bram_write_data_M(P_BANDS*PIXEL_DATA_WIDTH*2*2 - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*2 + PIXEL_DATA_WIDTH*2 -1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*2);
      data_in_odd_i  <= r.bram_write_data_M(P_BANDS*PIXEL_DATA_WIDTH*2*2 - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*2 + PIXEL_DATA_WIDTH*2*2 -1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*2+ PIXEL_DATA_WIDTH*2);
    end process;
    data_out_brams_M(P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE + PIXEL_DATA_WIDTH*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE)                                              <= data_out_even_i;
    data_out_brams_M(P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE +PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE+PIXEL_DATA_WIDTH*2) <= data_out_odd_i;
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
        write_enable  => r.write_enable,
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
        write_enable  => r.write_enable,
        read_enable   => r.read_enable,
        write_address => write_address_odd,
        read_address  => read_address_odd,
        data_out      => inv_data_out_odd_i);

    -- Process to control  data input to BRAMs.
    process(valid, r.bram_write_data_M_inv)

    begin
      inv_data_in_even_i <= r.bram_write_data_M_inv(P_BANDS*PIXEL_DATA_WIDTH*2*2 - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*2 + PIXEL_DATA_WIDTH*2 -1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*2);
      inv_data_in_odd_i  <= r.bram_write_data_M_inv(P_BANDS*PIXEL_DATA_WIDTH*2*2 - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*2 + PIXEL_DATA_WIDTH*2*2 -1 downto P_BANDS*PIXEL_DATA_WIDTH*2*2-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*2+ PIXEL_DATA_WIDTH*2);
    end process;
-- DATA outputted from the BRAMs
    data_out_brams_M_inv(P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE + PIXEL_DATA_WIDTH*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE)                                              <= inv_data_out_even_i;
    data_out_brams_M_inv(P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE +PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE+PIXEL_DATA_WIDTH*2) <= inv_data_out_odd_i;

  end generate;

  -- top_forward_elimination_1 : entity work.top_forward_elimination
  --   port map (
  --     clk                        => clk,
  --     reset_n                    => reset_n,
  --     clk_en                     => clk_en,
  --     input_elimination          => input_elimination,
  --     output_forward_elimination => output_forward_elim);

  -- top_backward_elimination_1 : entity work.top_backward_elim_new
  --   port map (
  --     clk             => clk,
  --     reset_n         => reset_n,
  --     clk_en          => clk_en,
  --     M               => M_inv,
  --     M_backward_elim => output_backward_elim);

  -- top_last_division_1 : entity work.top_last_division
  --   port map (
  --     clk             => clk,
  --     reset_n         => reset_n,
  --     clk_en          => clk_en,
  --     M               => M_inv,
  --     M_last_division => output_last_division);

  control_read_and_write_address : process(r.state_reg, r.read_address, r.write_address)
  begin
    if(r.state_reg.state = STATE_STORE_CORRELATION_MATRIX) then
      write_address_even <= r.write_address;
      write_address_odd  <= r.write_address;
      read_address_even  <= r.read_address;
      read_address_odd   <= r.read_address;
    elsif(r.state_reg.state = STATE_FORWARD_ELIMINATION) then
    elsif(r.state_reg.state = STATE_BACKWARD_ELIMINATION) then
    elsif(r.state_reg.state = STATE_IDENTITY_MATRIX_BUILDING) then
    end if;
  end process;


  comb : process(reset_n, valid, r, data_out_brams_M_inv, data_out_brams_M, output_forward_elim, output_backward_elim, output_last_division, din)  -- combinatorial process
    variable v : inverse_top_level_reg_type;
  begin
    v := r;
    case v.state_reg.state is
      when STATE_IDLE =>
        v.read_enable  := '0';
        v.write_enable := '0';
        if(valid = '1') then
          v.state_reg.state                                                                             := STATE_STORE_CORRELATION_MATRIX;
                                        -- Set write address to BRAMS
          v.write_address                                                                               := 0;
          v.read_address                                                                                := 0;
          v.write_enable                                                                                := '1';
          v.read_enable                                                                                 := '1';
          v.bram_write_data_M                                                                           := din;
          v.bram_write_data_M_inv                                                                       := (others => '0');
          v.bram_write_data_M_inv                                                                       := (others => '0');
          v.bram_write_data_M_inv((to_integer(unsigned(writes_done_on_column))*2)*PIXEL_DATA_WIDTH*2)   := '1';  -- creating the identity matrix
          v.bram_write_data_M_inv((to_integer(unsigned(writes_done_on_column))*2+1)*PIXEL_DATA_WIDTH*2) := '1';
        end if;
        v.state_reg.drive := IDLING;
                                        -- need to wait until valid data on all
      when STATE_STORE_CORRELATION_MATRIX =>
                                        -- SET BRAM to write input data 
        v.write_address                                                                               := r.write_address +1;
        v.read_address                                                                                := r.read_address+1;
        v.write_enable                                                                                := '1';
        v.read_enable                                                                                 := '1';
        v.bram_write_data_M                                                                           := din;
        v.bram_write_data_M_inv                                                                       := (others => '0');
        v.bram_write_data_M_inv((to_integer(unsigned(writes_done_on_column))*2)*PIXEL_DATA_WIDTH*2)   := '1';  -- creating the identity matrix
        v.bram_write_data_M_inv((to_integer(unsigned(writes_done_on_column))*2+1)*PIXEL_DATA_WIDTH*2) := '1';
        if to_integer(unsigned(writes_done_on_column)) = P_BANDS/2-1 then
                                                                          -- Need to wait until the entire correlation matrix have been stored
                                        -- in BRAM before starting to edit it.
          v.state_reg.state            := STATE_FORWARD_ELIMINATION;
          v.state_reg.fsm_start_signal := START_FORWARD_ELIMINATION;
        end if;
        if valid = '0' then
          v.state_reg.state := STATE_IDLE;
          v.state_reg.drive := STATE_IDLE_DRIVE;
        end if;
      when STATE_FORWARD_ELIMINATION =>
        v.state_reg.fsm_start_signal := IDLING;
        -- expecting data from FORWARD_ELIMINATION
        -- it must write to BRAM before being finished
        if(output_forward_elim.state_reg.drive = STATE_FORWARD_ELIMINATION_FINISHED) then
          v.row_j                      := output_forward_elim.new_row_j;  -- going to be
                                        -- written to BRAM
          v.row_i                      := output_forward_elim.new_row_i;
          v.inv_row_j                  := output_forward_elim.new_inv_row_j;
          v.state_reg.drive            := output_forward_elim.state_reg.drive;
          v.state_reg.state            := STATE_BACKWARD_ELIMINATION;
          v.state_reg.fsm_start_signal := START_BACKWARD_ELIMINATION;
          -- Need to read the two last rows. Making ready for backward elimination
          v.read_address               := P_BANDS/2-1;
        end if;
      when STATE_BACKWARD_ELIMINATION =>
        -- Wait for some time before you know that there is valid input data to
        -- module, then set valid high.
        if(output_backward_elim.state_reg.drive = STATE_BACKWARD_ELIMINATION_FINISHED) then
          v.row_j           := output_backward_elim.new_row_j;
          v.inv_row_j       := output_backward_elim.new_inv_row_j;
          v.state_reg.drive := output_backward_elim.state_reg.drive;
        end if;
      when STATE_IDENTITY_MATRIX_BUILDING =>
        if(output_last_division.state_reg.drive = STATE_IDENTITY_MATRIX_BUILDING_FINISHED) then
                                                                          -- state_reg.drive as finish-check signal
          v.inv_row_i       := output_last_division.new_inv_row_i;
          v.state_reg.drive := output_last_division.state_reg.drive;
        end if;
      when others =>
        v.read_enable  := '0';
        v.write_enable := '0';
                                                                          --      v.row_j :=                      -- row_j outputted from BRAM
                                                                          --      v.row_i :=                      -- row_j outputted from BRAM
                                                                          --  v.inv_row_j :=                      -- row_j outputted from BRAM
                                                                          --  v.inv_row_i :=                      -- row_j outputted from BRAM
    end case;
    if(reset_n = '0') then
        v.read_enable  := '0';
        v.write_enable := '0';
                                                                          --     v.row_j :=                        --value outputted from BRAM;
                                                                          --     v.row_i :=                        -- row_j outputted from BRAM
                                                                          -- v.inv_row_j :=                        -- row_j outputted from BRAM
                                                                          -- v.inv_row_i :=                        -- row_j outputted from BRAM
    end if;
    r_in                         <= v;
    input_elimination.row_j      <= r.row_j;
    input_elimination.row_i      <= r.row_i;
    input_elimination.inv_row_j  <= r.inv_row_j;
    input_elimination.inv_row_i  <= r.inv_row_i;
    input_elimination.state_reg  <= r.state_reg;
    input_elimination.valid_data <= r.valid_data;
    -- may also need some indexing.. Bit insecure as to how to do that as of yet.

  --M_inv.state_reg.state            <= fsm_state_reg.state;
  --M_inv.state_reg.fsm_start_signal <= fsm_state_reg.fsm_start_signal;
  --M_inv.state_reg.drive            <= r.state_reg.drive;
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
