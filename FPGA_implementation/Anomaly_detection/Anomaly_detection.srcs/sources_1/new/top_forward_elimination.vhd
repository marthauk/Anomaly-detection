library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;


entity top_forward_elimination is
  port(clk            : in    std_logic;
       reset          : in    std_logic;
       clk_en         : in    std_logic;
       M              : in    matrix_reg_type;
       M_forward_elim : inout matrix_reg_type);
end top_forward_elimination;

architecture Behavioral of top_forward_elimination is

  signal M_forward_elim_inner      : matrix_reg_type;
  signal M_forward_elim_triangular : matrix_reg_type;
  signal r, r_in                   : matrix_reg_type;

begin


  forward_elim_triangular_triangular_controller_1 : entity work.forward_elim_triangular_triangular_controller
    port map (
      clk                       => clk,
      reset                     => reset,
      clk_en                    => clk_en,
      M                         => M_forward_elim,
      M_forward_elim_triangular => M_forward_elim_triangular);

  forward_elim_inner_loop_controller_1 : entity work.forward_elim_inner_loop_controller
    port map (
      clk            => clk,
      reset          => reset,
      clk_en         => clk_en,
      M              => M_forward_elim,
      M_forward_elim => M_forward_elim_inner);


  comb_process : process(M, r, reset, M_forward_elim_inner, M_forward_elim_triangular)

    variable v : matrix_reg_type;
    --variable flag_forward_triangular_started : std_logic := 0;
    --variable flag_forward_core_started       : std_logic := 0;

  begin
    v                            := r;
    v.state_reg.fsm_start_signal := M.state_reg.fsm_start_signal;
-- M_forward_elim?

    if(M.state_reg.state = STATE_FORWARD_ELIMINATION and not(r.state_reg.drive = STATE_FORWARD_ELIMINATION_FINISHED)) then
      if(M.state_reg.fsm_start_signal = START_FORWARD_ELIMINATION and M.valid_matrix_data = '1') then
        -- Load matrix and set index_i, the index of the outer forward
        -- elimination loop. Also start triangular-loop if M[i][i]==0
        v                                           := M;
        v.row_reg.elim_index_i                      := std_logic_vector(to_signed(0, 32));
        v.row_reg.valid_data                        := '1';
        v.valid_matrix_data:='1';
        v.state_reg.start_inner_loop                := '1';
        v.state_reg.flag_forward_triangular_started := '0';
        v.state_reg.flag_forward_core_started       := '0';
      else
        v.state_reg.start_inner_loop := '0';
      end if;
      -- Move over the check if M(i,i)==0
   if (r.row_reg.valid_data = '1' and to_integer(unsigned(r.row_reg.elim_index_i)) <= P_BANDS-1) then
           if(r.state_reg.forward_elim_state_signal = STATE_FORWARD_TRIANGULAR) then
             if(M_forward_elim_triangular.state_reg.inner_loop_iter_finished = '1' and M_forward_elim_triangular.row_reg.valid_data = '1' and to_integer(unsigned(r.row_reg.elim_index_i)) < P_BANDS-1 ) then
               -- received data
               v.matrix                                    := M_forward_elim_triangular.matrix;
               v.matrix_inv                                := M_forward_elim_triangular.matrix_inv;
               v.row_reg.elim_index_i                      := std_logic_vector(to_signed(to_integer(unsigned(r.row_reg.elim_index_i))+1, 32));
               v.row_reg.a_i_i                             := M_forward_elim_triangular.matrix(to_integer(unsigned(v.row_reg.elim_index_i)), to_integer(unsigned(v.row_reg.elim_index_i)));
               v.state_reg.inner_loop_iter_finished        := '0';
               v.state_reg.start_inner_loop                := '1';
               v.state_reg.flag_forward_triangular_started := '0';
             end if;
           elsif(r.state_reg.forward_elim_state_signal = STATE_FORWARD_ELIM) then
             if(M_forward_elim_inner.state_reg.inner_loop_iter_finished = '1' and M_forward_elim_inner.row_reg.valid_data = '1' and to_integer(unsigned(r.row_reg.elim_index_i)) < P_BANDS-1 ) then
               -- received data
               v.matrix                              := M_forward_elim_inner.matrix;
               v.matrix_inv                          := M_forward_elim_inner.matrix_inv;
               -- update index_i 
               v.row_reg.elim_index_i                := std_logic_vector(to_signed(to_integer(unsigned(r.row_reg.elim_index_i))+1, 32));
               v.row_reg.a_i_i                       := M_forward_elim_inner.matrix(to_integer(unsigned(v.row_reg.elim_index_i)), to_integer(unsigned(v.row_reg.elim_index_i)));
               v.state_reg.inner_loop_iter_finished  := '0';
               v.state_reg.start_inner_loop          := '1';
               v.state_reg.flag_forward_core_started := '0';
   
             --elsif(to_integer(unsigned(M_forward_elim_inner.row_reg.elim_index_i)) >= P_BANDS-1 and M_forward_elim_inner.row_reg.valid_data = '1') then
             --elsif(to_integer(unsigned(M_forward_elim_inner.row_reg.elim_index_i)) >= P_BANDS-2 and M_forward_elim_inner.row_reg.valid_data = '1') then
             elsif(M_forward_elim_inner.state_reg.inner_loop_last_iter_finished='1' and M_forward_elim_inner.row_reg.valid_data = '1') then
               -- This is the last iteration of the forward elimination, signal
               -- to top module
               -- Finished forward elimination
               v.state_reg.drive                         := STATE_FORWARD_ELIMINATION_FINISHED;
               v.matrix                                  := M_forward_elim_inner.matrix;
               v.matrix_inv                              := M_forward_elim_inner.matrix_inv;
               v.state_reg.inner_loop_last_iter_finished := '1';
             end if;
           --elsif( to_integer(signed(r.row_reg.elim_index_i)) >= P_BANDS-1 and M_forward_elim_inner.row_reg.valid_data = '1' and r.state_reg.inner_loop_last_iter_finished = '1') then
           --  -- Finished forward elimination
           --  v.state_reg.drive := STATE_FORWARD_ELIMINATION_FINISHED;
           --  v.matrix          := M_forward_elim_inner.matrix;
           --  v.matrix_inv      := M_forward_elim_inner.matrix_inv;
           --end if;
           end if;
      -- Check if M(i,i)==0
      if(v.matrix(to_integer(unsigned(r.row_reg.elim_index_i)), to_integer(unsigned(r.row_reg.elim_index_i))) = std_logic_vector(to_unsigned(0, 32))) then
        v.state_reg.forward_elim_state_signal     := STATE_FORWARD_TRIANGULAR;
       -- v.state_reg.inner_loop_last_iter_finished := M_forward_elim_triangular.state_reg.inner_loop_last_iter_finished;
       -- v.state_reg.inner_loop_iter_finished      := M_forward_elim_triangular.state_reg.inner_loop_iter_finished;
        if(v.state_reg.flag_forward_triangular_started = '1') then
          v.state_reg.forward_elim_ctrl_signal := IDLING;
        else
          v.state_reg.forward_elim_ctrl_signal        := START_FORWARD_ELIM_TRIANGULAR;
          v.state_reg.flag_forward_triangular_started := '1';
        end if;
      else
        v.state_reg.forward_elim_state_signal     := STATE_FORWARD_ELIM;
       -- v.state_reg.inner_loop_iter_finished      := M_forward_elim_inner.state_reg.inner_loop_iter_finished;
       -- v.state_reg.inner_loop_last_iter_finished := M_forward_elim_inner.state_reg.inner_loop_last_iter_finished;
        if(v.state_reg.flag_forward_core_started = '1') then
          v.state_reg.forward_elim_ctrl_signal := IDLING;
        else
          v.state_reg.forward_elim_ctrl_signal  := START_FORWARD_ELIM_CORE;
          v.state_reg.flag_forward_core_started := '1';
        end if;
      end if;

   
      end if;
    end if;
    if(reset = '1') then
      v.row_reg.elim_index_i := std_logic_vector(to_signed(P_BANDS-1, 32));
      v.row_reg.elim_index_j := std_logic_vector(to_signed(P_BANDS-2, 32));
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
