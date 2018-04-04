----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/15/2018 04:26:59 PM
-- Design Name: 
-- Module Name: top_backward_elim_new - Behavioral
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
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;


entity top_backward_elim_new is
  port(clk            : in    std_logic;
       reset          : in    std_logic;
       clk_en         : in    std_logic;
       M              : in    matrix_reg_type;
       M_backward_elim : inout matrix_reg_type);
end top_backward_elim_new;

architecture Behavioral of top_backward_elim_new is

  signal M_backward_elim_inner      : matrix_reg_type;
  signal r, r_in                   : matrix_reg_type;

begin


  backward_elim_inner_loop_controller_new_1 : entity work.backward_elim_inner_loop_controller_new
    port map (
      clk            => clk,
      reset          => reset,
      clk_en         => clk_en,
      M              => M_backward_elim,
      M_backward_elim => M_backward_elim_inner);


  comb_process : process(M, r, reset, M_backward_elim_inner )

    variable v : matrix_reg_type;

  begin
    v                            := r;
    v.state_reg.fsm_start_signal := M.state_reg.fsm_start_signal;

    if(M.state_reg.state = STATE_BACKWARD_ELIMINATION and not(r.state_reg.drive = STATE_BACKWARD_ELIMINATION_FINISHED)) then
      if(M.state_reg.fsm_start_signal = START_BACKWARD_ELIMINATION and M.valid_matrix_data = '1') then
        -- Load matrix and set index_i, the index of the outer forward
        -- elimination loop. Also start triangular-loop if M[i][i]==0
        v                                           := M;
        v.row_reg.elim_index_i                      := std_logic_vector(to_signed(P_BANDS-1, 32));
        v.row_reg.valid_data                        := '1';
        v.valid_matrix_data:='1';
        v.state_reg.start_inner_loop                := '1';
        v.state_reg.flag_forward_core_started       := '0';
      else
        v.state_reg.start_inner_loop := '0';
      end if;
      -- Move over the check if M(i,i)==0
   if (r.row_reg.valid_data = '1' and to_integer(unsigned(r.row_reg.elim_index_i)) >= 0) then
             if(M_backward_elim_inner.state_reg.inner_loop_iter_finished = '1' and M_backward_elim_inner.row_reg.valid_data = '1' and to_integer(unsigned(r.row_reg.elim_index_i)) > 0 ) then
               -- received data
               v.matrix                              := M_backward_elim_inner.matrix;
               v.matrix_inv                          := M_backward_elim_inner.matrix_inv;
               -- update index_i 
               v.row_reg.elim_index_i                := std_logic_vector(to_signed(to_integer(unsigned(r.row_reg.elim_index_i))-1, 32));
               v.row_reg.a_i_i                       := M_backward_elim_inner.matrix(to_integer(unsigned(v.row_reg.elim_index_i)), to_integer(unsigned(v.row_reg.elim_index_i)));
               v.state_reg.inner_loop_iter_finished  := '0';
               v.state_reg.start_inner_loop          := '1';
               v.state_reg.flag_forward_core_started := '0';
   
             elsif(M_backward_elim_inner.state_reg.inner_loop_last_iter_finished='1' and M_backward_elim_inner.row_reg.valid_data = '1') then
               -- This is the last iteration of the forward elimination, signal
               -- to top module
               -- Finished forward elimination
               v.state_reg.drive                         := STATE_BACKWARD_ELIMINATION_FINISHED;
               v.matrix                                  := M_backward_elim_inner.matrix;
               v.matrix_inv                              := M_backward_elim_inner.matrix_inv;
               v.state_reg.inner_loop_last_iter_finished := '1';
             end if;
      end if;
    end if;
    if(reset = '1') then
      v.row_reg.elim_index_i := std_logic_vector(to_signed(P_BANDS-1, 32));
      v.row_reg.elim_index_j := std_logic_vector(to_signed(P_BANDS-2, 32));
    end if;
    r_in           <= v;
    M_backward_elim <= r;

  end process;


  sequential_process : process(clk, clk_en)
  begin
    if(rising_edge(clk) and clk_en = '1') then
      r <= r_in;
    end if;
  end process;

end Behavioral;






