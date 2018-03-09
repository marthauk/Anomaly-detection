
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;

entity forward_elim_inner_loop_controller is
  port(clk            : in    std_logic;
       reset          : in    std_logic;
       clk_en         : in    std_logic;
       M              : in    matrix_reg_type;
       M_forward_elim : inout matrix_reg_type);
end forward_elim_inner_loop_controller;

architecture Behavioral of forward_elim_inner_loop_controller is

  signal r, r_in : matrix_reg_type := C_MATRIX_REG_TYPE_INIT;

begin

  comb_process : process(M, r, reset)
    variable v : matrix_reg_type;

  begin
    v                            := r;
    v.state_reg.start_inner_loop := M.state_reg.start_inner_loop;
    v.state_reg.inner_loop_iter_finished := '0'; --default value;
    --if(v.state_reg.start_inner_loop = '1') then
     -- v.state_reg.inner_loop_iter_finished := '0';
    --end if;

    --if(M.state_reg.state = STATE_FORWARD_ELIMINATION and not (v.state_reg.inner_loop_iter_finished = '1')) then
    if(M.state_reg.state = STATE_FORWARD_ELIMINATION and M.state_reg.forward_elim_state_signal = STATE_FORWARD_ELIM) then
      if(M.state_reg.forward_elim_ctrl_signal = START_FORWARD_ELIM_CORE and M.valid_matrix_data = '1') then
        -- Load matrix and set index_j
        v                                    := M;
        v.row_reg.elim_index_j               := std_logic_vector(to_signed(to_integer(unsigned(M.row_reg.elim_index_i))+1, 32));
        v.row_reg.valid_data                 := '1';
        v.state_reg.inner_loop_iter_finished := '0';
      end if;
      -- Have loaded
      --    if(forward_elim_row.valid_data = '1') then
      -- Received forward elim data-- update Matrix 
      --      for p in 0 to P_BANDS-1 loop
      --        v.matrix(to_integer(unsigned(forward_elim_row.elim_index_j)), p)     := forward_elim_row.row_j(0, p);
      --        v.matrix_inv(to_integer(unsigned(forward_elim_row.elim_index_j)), p) := forward_elim_row.inv_row_j(0, p);
      --      end loop;
      --    end if;

      if(to_integer(signed(v.row_reg.elim_index_j)) <= P_BANDS-1 and r.row_reg.valid_data = '1') then
        for i in 0 to P_BANDS-1 loop
          v.matrix(to_integer(unsigned(r.row_reg.elim_index_j)), i)     := std_logic_vector(to_signed(to_integer(signed(r.matrix(to_integer(unsigned(r.row_reg.elim_index_j)), i))) -to_integer(signed(v.matrix(to_integer(unsigned(r.row_reg.elim_index_i)), i))) * to_integer(signed(r.matrix(to_integer(unsigned(r.row_reg.elim_index_j)), to_integer(unsigned(r.row_reg.elim_index_i)))))/to_integer(signed(r.matrix(to_integer(unsigned(r.row_reg.elim_index_i)), to_integer(unsigned(r.row_reg.elim_index_i))))), 32));
          v.matrix_inv(to_integer(unsigned(r.row_reg.elim_index_j)), i)     := std_logic_vector(to_signed(to_integer(signed(r.matrix_inv(to_integer(unsigned(r.row_reg.elim_index_j)), i))) -to_integer(signed(r.matrix_inv(to_integer(unsigned(r.row_reg.elim_index_i)), i))) * to_integer(signed(r.matrix(to_integer(unsigned(r.row_reg.elim_index_j)), to_integer(unsigned(r.row_reg.elim_index_i)))))/to_integer(signed(r.matrix(to_integer(unsigned(r.row_reg.elim_index_i)), to_integer(unsigned(r.row_reg.elim_index_i))))), 32));
        end loop;
        if (v.row_reg.elim_index_j < std_logic_vector(to_unsigned(P_BANDS-1, 32)) and M.state_reg.forward_elim_ctrl_signal /= START_FORWARD_ELIM_CORE) then
          -- Wait until we actually have registered in some matrix-value before
          -- altering the index.
          v.row_reg.elim_index_j := std_logic_vector(to_signed(to_integer(signed(r.row_reg.elim_index_j))+1, 32));
        end if;
        v.row_reg.a_j_i := v.matrix(to_integer(unsigned(v.row_reg.elim_index_j)), to_integer(unsigned(v.row_reg.elim_index_i)));
        --if(forward_elim_row.elim_index_j <= std_logic_vector(to_unsigned(0, 32))and forward_elim_row.valid_data = '1' and v.state_reg.start_inner_loop /= '1' and r.state_reg.inner_loop_iter_finished = '0') then
        -- Finished forward elimination, inner loop
        --   v.state_reg.inner_loop_iter_finished := '1';
        --end if;
        if(r.row_reg.elim_index_j >= std_logic_vector(to_unsigned(P_BANDS-1, 32))and v.state_reg.start_inner_loop /= '1' and r.state_reg.inner_loop_iter_finished = '0') then
        --if(r.row_reg.elim_index_j >= std_logic_vector(to_unsigned(P_BANDS-1, 32)) and r.state_reg.inner_loop_iter_finished = '0') then
          -- Finished forward elimination, inner loop
          v.state_reg.inner_loop_iter_finished := '1';
          --v.state_reg.drive                    := STATE_FORWARD_ELIMINATION_FINISHED;
        end if;
        if(to_integer(unsigned(r.row_reg.elim_index_i)) >= P_BANDS-2 and v.row_reg.valid_data = '1') then
          -- This is the last iteration of the forward elimination, signal
          -- to top module. Not necessary to check for i= P_BANDS-1
          v.state_reg.inner_loop_last_iter_finished := '1';
          end if;
      end if;
    end if;
    if(reset = '1') then
      v.row_reg.elim_index_i                    := std_logic_vector(to_signed(0, 32));
      v.row_reg.elim_index_j                    := std_logic_vector(to_signed(1, 32));
      v.state_reg.inner_loop_iter_finished      := '0';
      v.state_reg.inner_loop_last_iter_finished := '0';
    end if;
    r_in           <= v;
    M_forward_elim <= r;

  end process;


  sequential_process : process(clk, clk_en)
  begin
    if(rising_edge(clk) and clk_en = '1') then
      r <= r_in;
    end if;
  end process;

end Behavioral;