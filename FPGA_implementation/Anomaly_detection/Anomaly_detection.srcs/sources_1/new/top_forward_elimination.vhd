library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;

-- This module controls the forward elimination stage. It issues reads and
-- writes to BRAM
entity top_forward_elimination is
  port(clk                        : in  std_logic;
       reset_n                    : in  std_logic;
       clk_en                     : in  std_logic;
       input_forward_elimination  : in  input_elimination_reg_type;
       output_forward_elimination : out output_forward_elimination_reg_type
       );
end top_forward_elimination;

architecture Behavioral of top_forward_elimination is

  signal r, r_in          : input_elimination_reg_type;
  signal output_swap_rows : output_forward_elimination_reg_type;
  signal input_swap_rows  : input_elimination_reg_type;
  signal output_top_level : output_forward_elimination_reg_type;

begin
  -- Instance to swap the rows if needed.
  swap_rows_1 : entity work.swap_rows_module
    port map (
      clk              => clk,
      reset_n          => reset_n,
      clk_en           => clk_en,
      input_swap_rows  => input_swap_rows,
      output_swap_rows => output_swap_rows);

  --process to set output to inverse top level
  set_outputs : process(r, output_swap_rows, output_top_level)
  begin
    case r.forward_elimination_write_state is
      when STATE_IDLE =>
        output_forward_elimination <= output_top_level;
      when CHECK_DIAGONAL_ELEMENT_IS_ZERO =>
        output_forward_elimination <= output_top_level;
      when SWAP_ROWS =>
        output_forward_elimination <= output_swap_rows;
      when EVEN_j_WRITE =>
        output_forward_elimination <= output_top_level;
      when ODD_j_WRITE =>
        output_forward_elimination <= output_top_level;
      when others =>
        output_forward_elimination <= output_top_level;
    end case;
  end process;

  set_inputs_to_swap_rows : process(input_forward_elimination, r)
  begin
    case r.forward_elimination_write_state is
      when STATE_IDLE =>
        input_swap_rows.forward_elimination_write_state <= STATE_IDLE;
      when SWAP_ROWS =>
        input_swap_rows.forward_elimination_write_state <= r.forward_elimination_write_state;
        if r.flag_start_swapping_rows = '1' then
          -- input from top level
          input_swap_rows.row_i                      <= r.row_i;
          input_swap_rows.row_j                      <= r.row_j;
          input_swap_rows.index_i                    <= r.index_i;
          input_swap_rows.index_j                    <= r.index_j;
          input_swap_rows.address_row_i              <= r.address_row_i;
          input_swap_rows.address_row_j              <= r.address_row_j;
          input_swap_rows.flag_write_to_even_row     <= r.flag_write_to_even_row;
          input_swap_rows.flag_write_to_odd_row      <= r.flag_write_to_odd_row;
          input_swap_rows.flag_prev_row_i_at_odd_row <= r.flag_prev_row_i_at_odd_row;
        else
        -- receive row i and row j from BRAM directly
        end if;
      when others =>
        input_swap_rows.forward_elimination_write_state <= STATE_IDLE;
    end case;
  end process;



  comb_process : process(output_swap_rows, input_forward_elimination, r, reset_n)

    variable v : input_elimination_reg_type;

  begin
    v           := r;
    v.state_reg := input_forward_elimination.state_reg;
    if(input_forward_elimination.state_reg.state = STATE_FORWARD_ELIMINATION and input_forward_elimination.valid_data = '1') then
      case r.forward_elimination_write_state is
        when STATE_IDLE =>
          v.valid_data := '0';
          -- input_elimination.flag_first_data_elimination is to be sent only
          -- once, by the top level inverse
          if input_forward_elimination.flag_first_data_elimination = '1' then
            v.forward_elimination_write_state := CHECK_DIAGONAL_ELEMENT_IS_ZERO;
            v.flag_first_data_elimination     := '1';
          end if;
        when CHECK_DIAGONAL_ELEMENT_IS_ZERO =>
          if r.flag_first_data_elimination = '1' then
            -- First iteration of the forward-elimination
            -- for the current processed pixel
            v.index_i                             := 0;
            v.index_j                             := 0;
            -- Has already read the first j
            v.index_j_two_cycles_ahead            := 2;
            v.index_i_two_cycles_ahead            := 0;
            v.read_address_row_i_two_cycles_ahead := 0;
            v.flag_write_to_even_row              := '0';
            v.flag_write_to_odd_row               := '1';
            v.write_address_even                  := 0;
            v.write_address_odd                   := 0;
            v.valid_data                          := '0';
            -- First iteration row_i is located at even index=0
            v.row_i                               := input_forward_elimination.row_even;
            v.row_j                               := input_forward_elimination.row_odd;
            v.inv_row_i                           := input_forward_elimination.inv_row_even;
            v.inv_row_j                           := input_forward_elimination.inv_row_odd;
            v.address_row_i                       := 0;
            v.flag_prev_row_i_at_odd_row          := '0';
            v.wait_counter                        := 0;
            v.flag_waiting_for_bram_update        := '0';
          else
            v.valid_data                          := '0';
            v.index_i                      := r.index_i - 1;
            v.index_j                      := r.index_i - 2;
            v.flag_write_to_odd_row        := not(r.flag_write_to_odd_row);
            v.flag_write_to_even_row       := not(r.flag_write_to_even_row);
            v.flag_prev_row_i_at_odd_row   := not(r.flag_prev_row_i_at_odd_row);
            v.wait_counter                 := 0;
            v.flag_waiting_for_bram_update := '0';
            if v.flag_write_to_even_row = '1' then
              -- index_i at odd row i
              -- address row i?
              v.address_row_i      := r.address_row_i;
              v.address_row_j      := r.address_row_i+1;
              v.write_address_even := r.write_address_even +1;
              v.write_address_odd  := r.write_address_odd;
              v.row_i              := input_forward_elimination.row_odd;
              v.row_j              := input_forward_elimination.row_even;
              v.inv_row_i          := input_forward_elimination.inv_row_odd;
              v.inv_row_j          := input_forward_elimination.inv_row_even;
            else
              -- index i at even row
              v.address_row_i      := r.address_row_i+1;
              v.write_address_odd  := r.write_address_odd +1;
              v.address_row_j      := r.address_row_i+1;
              v.write_address_even := r.write_address_even;
              v.row_i              := input_forward_elimination.row_even;
              v.row_j              := input_forward_elimination.row_odd;
              v.inv_row_i          := input_forward_elimination.inv_row_even;
              v.inv_row_j          := input_forward_elimination.inv_row_odd;
            end if;
          end if;
          if v.row_i(v.index_i) = 0 then
            -- issue correct read address
            --v.read_address_even :=
            --v.read_address_odd :=
            -- v address row_j
            v.forward_elimination_write_state := SWAP_ROWS;
            v.flag_start_swapping_rows        := '1';
            -- insecure about the reading process here...
            v.read_address_even               := r.read_address_even +1;
            v.read_address_odd                := r.read_address_odd +1;
          else
            if v.flag_write_to_even_row = '1' then  -- and data is ready
              v.forward_elimination_write_state := EVEN_j_WRITE;
              v.read_address_even               := r.read_address_even;
              v.read_address_odd                := r.read_address_odd;
            else
              v.forward_elimination_write_state := ODD_j_WRITE;
              v.read_address_even               := r.read_address_even+1;
              v.read_address_odd                := r.read_address_odd+1;
            end if;
          end if;
        when SWAP_ROWS =>
          -- wait until received new swapped rows from swapped row module
          v.flag_start_swapping_rows := '0';
          if output_swap_rows.valid_data = '1' then
            -- A swap of rows have happened. The forward elimination can continue 
            if output_swap_rows.flag_prev_row_i_at_odd_row = '1' then
              v.forward_elimination_write_state := EVEN_j_WRITE;
              -- read data. Need to read an odd row
              v.read_address_odd                := output_swap_rows.read_address_odd;
              v.read_address_even               := output_swap_rows.read_address_even;
            else
              v.forward_elimination_write_state := ODD_j_WRITE;
              --read data. Need to read an even row
              v.read_address_odd                := output_swap_rows.read_address_odd +1;
              v.read_address_even               := output_swap_rows.read_address_even +1;
            end if;
          end if;
        when EVEN_j_WRITE =>
          -- Need to check if i two cycles forward is at new place..
          --when writing to BRAM,in inverse-module, check that write_state is
          --either EVEN_j_Write or ODD_j_write and write_flag is high.
          if r.flag_waiting_for_bram_update = '0' then
            v.valid_data :='1';
            v.flag_write_to_even_row := '1';
            v.flag_write_to_odd_row  := '0';
            v.valid_data             := '1';
            v.index_j                := r.index_j+1;
            v.row_j                  := input_forward_elimination.row_even;
            v.inv_row_j              := input_forward_elimination.inv_row_even;
            v.address_row_i          := r.address_row_i;
            if r.index_j             <= P_BANDS-2 then
              v.write_address_even := r.write_address_even+1;
              v.write_address_odd  := r.write_address_odd +1;
            end if;
          end if;

          if v.index_j >= P_BANDS-2 and r.index_i_two_cycles_ahead -v.index_j < B_RAM_WAIT_CLK_CYCLES and r.wait_counter < B_RAM_WAIT_CLK_CYCLES-(r.index_i_two_cycles_ahead -v.index_j) then
            -- Need to wait for the row to update before reading it
            v.wait_counter                 := r.wait_counter+1;
            v.flag_waiting_for_bram_update := '1';
          else
            v.wait_counter                 := 0;
            v.flag_waiting_for_bram_update := '0';
            if v.index_j                   <= P_BANDS-2 then
              v.forward_elimination_write_state := ODD_j_WRITE;
            end if;
            -- read new data. Data need to be read two clock cycles in advance 
            if(r.read_address_even <= P_BANDS/2-1 and r.index_j_two_cycles_ahead <= P_BANDS-3) then
              -- need to read an even row
              v.read_address_even        := r.read_address_even+1;
              v.read_address_odd         := r.read_address_odd +1;
              v.index_j_two_cycles_ahead := r.index_j_two_cycles_ahead +1;
            elsif v.index_j > P_BANDS-3 then
              -- new i, update
              if r.index_i_two_cycles_ahead <= P_BANDS-3 then
                v.index_i_two_cycles_ahead := r.index_i_two_cycles_ahead+1;
                v.index_j_two_cycles_ahead := r.index_i_two_cycles_ahead+2;
                if r.flag_prev_row_i_at_odd_row = '1' then
                  --next row i will be located in an even indexed row
                  v.read_address_even                   := r.address_row_i+1;
                  v.read_address_odd                    := r.address_row_i+1;
                  v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead+1;
                  v.flag_prev_row_i_at_odd_row          := '0';
                else
                  -- next row i will be located in an odd indexed row
                  v.read_address_odd                    := r.read_address_row_i_two_cycles_ahead;
                  v.read_address_even                   := r.read_address_row_i_two_cycles_ahead;
                  v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead;
                  v.flag_prev_row_i_at_odd_row          := '1';
                end if;
              end if;
            end if;
          end if;


        when ODD_j_WRITE =>
          -- Need to check if i two cycles forward is at new place..
          if r.flag_waiting_for_bram_update = '0' then
            v.valid_data :='1';
            v.flag_write_to_even_row := '0';
            v.flag_write_to_odd_row  := '1';
            v.valid_data             := '1';
            v.row_j                  := input_forward_elimination.row_odd;
            v.inv_row_j              := input_forward_elimination.inv_row_odd;
            v.index_j                := r.index_j+1;
            v.address_row_i          := r.address_row_i;
            v.write_address_even     := r.write_address_even;
            v.write_address_odd      := r.write_address_odd;
          end if;

          if v.index_j >= P_BANDS-1 and r.index_i_two_cycles_ahead -v.index_j < B_RAM_WAIT_CLK_CYCLES and r.wait_counter < B_RAM_WAIT_CLK_CYCLES-(r.index_i_two_cycles_ahead -v.index_j) then
            -- Need to wait for the row to update before reading it
            v.wait_counter                 := r.wait_counter+1;
            v.flag_waiting_for_bram_update := '1';
          else
            v.wait_counter                 := 0;
            v.flag_waiting_for_bram_update := '0';
            -- Set next state
            if v.index_j                   <= P_BANDS-3 then
              v.forward_elimination_write_state := EVEN_j_WRITE;
            else
              --New iteration of the outermost loop
              v.forward_elimination_write_state := CHECK_DIAGONAL_ELEMENT_IS_ZERO;
            end if;
            -- read new data. Data need to be read two clock cycles in advance 
            if(r.read_address_odd <= P_BANDS/2-1 and r.index_j_two_cycles_ahead <= P_BANDS-1) then
              -- need to read an odd row
              v.read_address_even        := r.read_address_even;
              v.read_address_odd         := r.read_address_odd;
              v.index_j_two_cycles_ahead := r.index_j_two_cycles_ahead +1;
            elsif v.index_j > P_BANDS-3 then
              -- new i, update
              if r.index_i_two_cycles_ahead <= P_BANDS-3 then
                v.index_i_two_cycles_ahead := r.index_i_two_cycles_ahead+1;
                v.index_j_two_cycles_ahead := r.index_i_two_cycles_ahead+2;
                if r.flag_prev_row_i_at_odd_row = '1' then
                  --next row i will be located in an even indexed row
                  v.read_address_even                   := r.address_row_i+1;
                  v.read_address_odd                    := r.address_row_i+1;
                  v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead+1;
                  v.flag_prev_row_i_at_odd_row          := '0';
                else
                  -- next row i will be located in an odd indexed row
                  v.read_address_odd                    := r.read_address_row_i_two_cycles_ahead;
                  v.read_address_even                   := r.read_address_row_i_two_cycles_ahead;
                  v.read_address_row_i_two_cycles_ahead := r.read_address_row_i_two_cycles_ahead;
                  v.flag_prev_row_i_at_odd_row          := '1';
                end if;
              end if;
            end if;
          end if;
        when others =>
          v.forward_elimination_write_state := STATE_IDLE;
          v.flag_write_to_odd_row           := '0';
          v.flag_write_to_even_row          := '0';
      end case;
    end if;

    if(reset_n = '0') then
      v.index_i                         := 0;
      v.index_j                         := 1;
      v.valid_data                      := '0';
      v.address_row_i                   := 0;
      v.flag_write_to_even_row          := '0';
      v.flag_write_to_odd_row           := '0';
      v.forward_elimination_write_state := STATE_IDLE;
    end if;
    r_in                                             <= v;
    --data
    output_top_level.row_j                           <= r.row_j;
    output_top_level.row_i                           <= r.row_i;
    output_top_level.inv_row_j                       <= r.inv_row_j;
    output_top_level.inv_row_i                       <= r.inv_row_i;
    --control
    output_top_level.index_i                         <= r.index_i;
    output_top_level.index_j                         <= r.index_j;
    output_top_level.read_address_even               <= r.read_address_even;
    output_top_level.read_address_odd                <= r.read_address_odd;
    output_top_level.write_address_even              <= r.write_address_even;
    output_top_level.write_address_odd               <= r.write_address_odd;
    output_top_level.valid_data                      <= r.valid_data;
    output_top_level.forward_elimination_write_state <= r.forward_elimination_write_state;
    output_top_level.flag_write_to_odd_row           <= r.flag_write_to_odd_row;
    output_top_level.flag_write_to_even_row          <= r.flag_write_to_even_row;
    output_top_level.state_reg                       <= r.state_reg;

  end process;


  sequential_process : process(clk, clk_en)
  begin
    if(rising_edge(clk) and clk_en = '1') then
      r <= r_in;
    end if;
  end process;

end Behavioral;
