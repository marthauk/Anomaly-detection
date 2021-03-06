library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;

-- This module is used in the forward elimination 
-- It flips rows i and j if a zero is detected in row i, and row j does not
-- contain a 0 at index j

entity swap_rows_module is
  port(clk              : in  std_logic;
       reset_n          : in  std_logic;
       clk_en           : in  std_logic;
       input_swap_rows  : in  input_elimination_reg_type;
       output_swap_rows : out output_forward_elimination_reg_type
       );
end swap_rows_module;

architecture Behavioral of swap_rows_module is
  signal r, r_in : input_elimination_reg_type;
begin

  comb_process : process(input_swap_rows, r, reset_n)
    variable v : input_elimination_reg_type;

  begin
    v := r;
    case input_swap_rows.forward_elimination_write_state is
      when SWAP_ROWS =>
        if input_swap_rows.flag_start_swapping_rows = '1' then
          v.flag_started_swapping_rows      := '1';
          v.flag_wrote_swapped_rows_to_BRAM := '0';
          v.index_j                         := input_swap_rows.index_j;
          v.index_i                         := input_swap_rows.index_i;
          v.row_i                           := input_swap_rows.row_i;
          v.row_j                           := input_swap_rows.row_j;
          v.address_row_i                   := input_swap_rows.address_row_i;
          v.address_row_j                   := input_swap_rows.address_row_j;
          v.flag_write_to_even_row          := input_swap_rows.flag_write_to_even_row;
          v.flag_write_to_odd_row           := input_swap_rows.flag_write_to_odd_row;
          v.flag_prev_row_i_at_odd_row      := input_swap_rows.flag_prev_row_i_at_odd_row;
          v.flag_prev_row_j_at_odd_row      := not(input_swap_rows.flag_prev_row_i_at_odd_row);
          if v.row_j(v.index_j) /= 0 then
            -- flip the rows, write_to_BRAM 
            v.row_i                           := v.row_j;
            v.row_j                           := input_swap_rows.row_i;
            v.flag_wrote_swapped_rows_to_BRAM := '1';
            v.flag_write_to_even_row          := '1';
            v.flag_write_to_odd_row           := '1';
            if v.flag_prev_row_i_at_odd_row = '1' then
              v.write_address_odd  := v.address_row_i;
              v.write_address_even := v.address_row_j;
            else
              v.write_address_even := v.address_row_i;
              v.write_address_odd  := v.address_row_j;
            end if;
          else
            -- need to check next row_j. Issue reads for two cycles ahead 
            if v.index_j <= P_BANDS-3 then
              if input_swap_rows.flag_write_to_even_row = '1' then
                -- need to read an odd row, has already read the even row with the
                -- same address as this odd row
                v.read_enable       := '1';
                v.read_address_even := input_swap_rows.read_address_even;
                v.read_address_odd  := input_swap_rows.read_address_odd;
              else
                -- need to read an even row
                v.read_enable       := '1';
                v.read_address_even := input_swap_rows.read_address_even+1;
                v.read_address_odd  := input_swap_rows.read_address_odd +1;
              end if;
            --end if;
            else
              --all reads has been issued. Need to wait to see if some of the latest
              --rows can be swapped 
              v.read_enable := '0';
            end if;
          end if;

          if r.flag_started_swapping_rows = '1' and r.flag_wrote_swapped_rows_to_BRAM = '0' then
            --need to check if index_i and index_j is at two even or two odd
            --indexes. If so, the writes two BRAM will have to continue in two cycles.
            v.index_j                    := r.index_j +1;
            v.flag_prev_row_j_at_odd_row := not(r.flag_prev_row_j_at_odd_row);
            v.flag_write_to_even_row     := not(r.flag_write_to_even_row);
            v.flag_write_to_odd_row      := not(r.flag_write_to_odd_row);
            v.row_j                      := input_swap_rows.row_j;  --this is outputted directly from BRAMS.
            if v.flag_prev_row_j_at_odd_row = '0' then
              --current row j is at an even index, need to update row_j address
              v.address_row_j := r.address_row_j+1;
            end if;
            if v.row_j(v.index_j) /= 0 then
              --flip the rows, write to BRAM 
              v.row_i                           := v.row_j;
              v.row_j                           := input_swap_rows.row_i;  --this correct?
              v.flag_wrote_swapped_rows_to_BRAM := '1';
              v.flag_write_to_even_row          := '1';
              v.flag_write_to_odd_row           := '1';
              if v.flag_prev_row_i_at_odd_row = '1' then
                v.write_address_odd  := v.address_row_i;
                v.write_address_even := v.address_row_j;
              else
                v.write_address_even := v.address_row_i;
                v.write_address_odd  := v.address_row_j;
              end if;
            else
              -- need to read new data 
              if v.index_j <= P_BANDS-3 then
                v.valid_data := '0';
                if v.flag_write_to_even_row = '1' then
                  --need to read an odd row, has already read the even row with the
                  -- same address as this odd row
                  v.read_enable       := '1';
                  v.read_address_even := v.read_address_even;
                  v.read_address_odd  := v.read_address_odd;
                else
                  -- need to read an even row
                  v.read_enable       := '1';
                  v.read_address_even := v.read_address_even+1;
                  v.read_address_odd  := v.read_address_odd +1;
                end if;
              end if;
            end if;
          elsif v.index_j = 0 then
            -- The loop has continued without any swap of rows
            -- The matrix is singular. 
            v.valid_data := '1';
          else
            -- all reads has been issued. Need to wait to see if some of the latest
            -- rows can be swapped 
            v.read_enable := '0';
          end if;
        end if;
        if r.flag_wrote_swapped_rows_to_BRAM = '1' then
          -- valid_data is used to signal that the swapping is done
          -- and that the data is finished written to BRAM
          v.valid_data             := '1';
          v.flag_write_to_even_row := '0';
          v.flag_write_to_odd_row  := '0';
          v.read_enable            := '0';
          -- Start issuing reads
          if r.flag_prev_row_i_at_odd_row = '0' then
            -- This means that row j two cycles ahead is at an odd index
            -- because the first row j is at an odd index
            v.read_address_odd  := r.address_row_i;
            v.read_address_even := r.address_row_i;
          else
            -- This means that row j two cycles ahead is at an even index
            -- because the first row j is at an even index
            v.read_address_odd  := r.address_row_i;
            v.read_address_even := r.address_row_i+1;
          end if;
        end if;
      when others =>
        v.index_i                    := 0;
        v.index_j                    := 1;
        v.valid_data                 := '0';
        v.address_row_i              := 0;
        v.address_row_j              := 1;
        v.flag_write_to_even_row     := '0';
        v.flag_write_to_odd_row      := '0';
        v.flag_started_swapping_rows := '0';
    end case;
    if(reset_n = '0') then
      v.index_i                    := 0;
      v.index_j                    := 1;
      v.valid_data                 := '0';
      v.address_row_i              := 0;
      v.address_row_j              := 1;
      v.flag_write_to_even_row     := '0';
      v.flag_write_to_odd_row      := '0';
      v.flag_started_swapping_rows := '0';
    end if;
    r_in                                        <= v;
    -- This module needs to write 
--  output_forward_elimination
    output_swap_rows.row_j                  <= r.row_j;
    output_swap_rows.row_i                  <= r.row_i;
    output_swap_rows.read_address_odd           <= r.read_address_odd;
    output_swap_rows.read_address_even          <= r.read_address_even;
    output_swap_rows.flag_write_to_odd_row      <= r.flag_write_to_odd_row;
    output_swap_rows.flag_write_to_even_row     <= r.flag_write_to_even_row;
    output_swap_rows.read_enable                <= r.read_enable;
    output_swap_rows.valid_data                 <= r.valid_data;
    output_swap_rows.write_address_odd          <= r.write_address_odd;
    output_swap_rows.write_address_even         <= r.write_address_even;
    output_swap_rows.state_reg                  <= r.state_reg;
    output_swap_rows.flag_prev_row_i_at_odd_row <= r.flag_prev_row_i_at_odd_row;

  end process;


  sequential_process : process(clk, clk_en)
  begin
    if(rising_edge(clk) and clk_en = '1') then
      r <= r_in;
    end if;
  end process;

end Behavioral;
