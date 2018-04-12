library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;

entity backward_elim_inner_loop_controller is
  port(clk             : in    std_logic;
       reset           : in    std_logic;
       clk_en          : in    std_logic;
       M               : in    matrix_reg_type;
       M_backward_elim : inout matrix_reg_type);
end backward_elim_inner_loop_controller;

architecture Behavioral of backward_elim_inner_loop_controller is

  signal backward_elim_row : row_reg_type;
  signal r, r_in           : matrix_reg_type := C_MATRIX_REG_TYPE_INIT;

begin


  backward_elim_gauss_1 : entity work.backward_elim_gauss
    port map (
      clk               => clk,
      reset             => reset,
      clk_en            => clk_en,
      row               => r.row_reg,
      backward_elim_row => backward_elim_row);

  comb_process : process(M, r, reset, backward_elim_row)
    variable v : matrix_reg_type;

  begin
    v                            := r;
    v.state_reg.start_inner_loop := M.state_reg.start_inner_loop;

    if(v.state_reg.start_inner_loop = '1') then
      v.state_reg.inner_loop_iter_finished := '0';
    end if;

    --if(M.state_reg.state = STATE_BACKWARD_ELIMINATION and not (v.state_reg.inner_loop_iter_finished = '1')) then
    if(M.state_reg.state = STATE_BACKWARD_ELIMINATION ) then
      if(M.state_reg.start_inner_loop = '1' and M.valid_matrix_data = '1') then
        -- Load matrix and set index_j
        v                                    := M;
        v.row_reg.backward_elim_index_j      := std_logic_vector(to_signed(to_integer(unsigned(M.row_reg.backward_elim_index_i))-1, 32));
        v.row_reg.valid_data                 := '1';
        v.state_reg.inner_loop_iter_finished := '0';
      end if;
      -- Have loaded
      if(backward_elim_row.valid_data = '1') then
        -- Received backward elim data-- update Matrix 
        for p in 0 to P_BANDS-1 loop
          v.matrix(to_integer(unsigned(backward_elim_row.backward_elim_index_j)), p)     := backward_elim_row.row_j(0, p);
          v.matrix_inv(to_integer(unsigned(backward_elim_row.backward_elim_index_j)), p) := backward_elim_row.inv_row_j(0, p);
        end loop;
      end if;

      if(to_integer(signed(v.row_reg.backward_elim_index_j)) >= 0) then
        if (v.row_reg.backward_elim_index_j /= std_logic_vector(to_unsigned(0, 32)) and M.state_reg.fsm_start_signal /= START_BACKWARD_ELIMINATION and backward_elim_row.valid_data = '1') then
          -- Wait until we actually have registered in some matrix-value before
          -- altering the index.
          v.row_reg.backward_elim_index_j := std_logic_vector(to_signed(to_integer(signed(r.row_reg.backward_elim_index_j))-1, 32));
        end if;
        v.row_reg.a_j_i := v.matrix(to_integer(unsigned(v.row_reg.backward_elim_index_j)), to_integer(unsigned(v.row_reg.backward_elim_index_i)));
        --v.row_reg.a_j_i := v.matrix(to_integer(unsigned(r.row_reg.backward_elim_index_j)), to_integer(unsigned(r.row_reg.backward_elim_index_i)));
        for p in 0 to P_BANDS-1 loop
          v.row_reg.row_j(0, p)     := v.matrix(to_integer(unsigned(v.row_reg.backward_elim_index_j)), p);
          v.row_reg.row_i(0, p)     := v.matrix(to_integer(unsigned(v.row_reg.backward_elim_index_i)), p);
          v.row_reg.inv_row_j(0, p) := v.matrix_inv(to_integer(unsigned(v.row_reg.backward_elim_index_j)), p);
          v.row_reg.inv_row_i(0, p) := v.matrix_inv(to_integer(unsigned(v.row_reg.backward_elim_index_i)), p);
        end loop;
        if(backward_elim_row.backward_elim_index_j <= std_logic_vector(to_unsigned(0, 32))and backward_elim_row.valid_data = '1' and v.state_reg.start_inner_loop /= '1' and r.state_reg.inner_loop_iter_finished = '0') then
          -- Finished backward elimination, inner loop
          v.state_reg.inner_loop_iter_finished := '1';
        end if;
        if(to_integer(unsigned(backward_elim_row.backward_elim_index_i)) <= 1 and backward_elim_row.valid_data = '1') then
          -- This is the last iteration of the backward elimination, signal
          -- to top module
          v.state_reg.inner_loop_last_iter_finished := '1';
        end if;
      end if;

    end if;
    if(reset = '1') then
      v.row_reg.backward_elim_index_i           := std_logic_vector(to_signed(P_BANDS-1, 32));
      v.row_reg.backward_elim_index_j           := std_logic_vector(to_signed(P_BANDS-2, 32));
      v.state_reg.inner_loop_iter_finished      := '0';
      v.state_reg.inner_loop_last_iter_finished := '0';
    end if;
    r_in            <= v;
    M_backward_elim <= r;

  end process;


  sequential_process : process(clk, clk_en)
  begin
    if(rising_edge(clk) and clk_en = '1') then
      r <= r_in;
    end if;
  end process;

end Behavioral;
