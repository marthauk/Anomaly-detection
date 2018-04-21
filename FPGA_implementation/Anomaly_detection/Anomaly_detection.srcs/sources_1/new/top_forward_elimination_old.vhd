
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.fixed_pkg.all;

library work;
use work.Common_types_and_functions.all;
use work.MATH_REAL.all;

entity forward_elim_inner_loop_controller is
  port(clk                 : in  std_logic;
       reset_n             : in  std_logic;
       clk_en              : in  std_logic;
       input_forward_elim  : in  input_elimination_reg_type;
       output_forward_elim : out output_forward_elimination_reg_type);
end forward_elim_inner_loop_controller;

architecture Behavioral of forward_elim_inner_loop_controller is

  signal r, r_in : input_elimination_reg_type;

begin

  comb_process : process(input_forward_elim, r, reset_n)
    variable v                   : input_elimination_reg_type;
    variable r_j_i               : integer ;
    variable r_i_i               : integer ;
    variable test                : integer;
    variable inner_product       : integer;
    variable r_i_i_halv          : integer;
    ---
  begin
    v                                    := r;
    v.state_reg.start_inner_loop         := input_forward_elim.state_reg.start_inner_loop;
    v.state_reg.inner_loop_iter_finished := '0';  --default value;
    --if(v.state_reg.start_inner_loop = '1') then
    -- v.state_reg.inner_loop_iter_finished := '0';
    --end if;

    --if(M.state_reg.state = STATE_FORWARD_ELIMINATION and not (v.state_reg.inner_loop_iter_finished = '1')) then
    if(input_forward_elim.state_reg.state = STATE_FORWARD_ELIMINATION and input_forward_elim.state_reg.forward_elim_state_signal = STATE_FORWARD_ELIM) then
      if(input_forward_elim.state_reg.forward_elim_ctrl_signal = START_FORWARD_ELIM_CORE and input_forward_elim.valid_data = '1') then
        -- Load data set index_j
        v.row_j                              := input_forward_elim.row_j;
        v.row_i                              := input_forward_elim.row_i;
        v.index_i                            := input_forward_elim.index_i;
        v.index_j                            := input_forward_elim.index_j;
        v.valid_data                 := '1';
        v.state_reg.inner_loop_iter_finished := '0';
      end if;

      if(v.index_j <= P_BANDS-1 and input_forward_elim.valid_data = '1') then

        r_j_i      := to_integer(input_forward_elim.row_j(input_forward_elim.index_i));
        r_i_i      := to_integer(input_forward_elim.row_i(input_forward_elim.index_i));
        r_i_i_halv := r_i_i/2;
        for i in 0 to P_BANDS-1 loop
          inner_product                                                 := to_integer(input_forward_elim.row_i(input_forward_elim.index_i))*r_j_i;
          test                                                          := (inner_product+r_i_i_halv);
          test                                                          := test/r_i_i;
          v.row_j(i) := to_signed(to_integer(signed(input_forward_elim.row_j(i)))-test,32);
          
          inner_product                                                 := to_integer(input_forward_elim.inv_row_i(input_forward_elim.index_i))*r_j_i;
          test                                                          := (inner_product+r_i_i_halv);
          test                                                          := test/r_i_i;
          v.inv_row_j(i) := to_signed(to_integer(input_forward_elim.inv_row_j(i))-test,32);

        end loop;
        if (v.index_j < P_BANDS-1 and input_forward_elim.state_reg.forward_elim_ctrl_signal /= START_FORWARD_ELIM_CORE) then
          -- Wait until we actually have registered in some matrix-value before
          -- altering the index.
          v.index_j :=r.index_j+1;
        end if;
        v.row_reg.a_j_i := v.matrix(to_integer(unsigned(v.row_reg.elim_index_j)), to_integer(unsigned(v.row_reg.elim_index_i)));
        if(r.index_j >= std_logic_vector(to_unsigned(P_BANDS-1, 32))and v.state_reg.start_inner_loop /= '1' and r.state_reg.inner_loop_iter_finished = '0') then
          --if(r.row_reg.elim_index_j >= std_logic_vector(to_unsigned(P_BANDS-1, 32)) and r.state_reg.inner_loop_iter_finished = '0') then
          -- Finished forward elimination, inner loop
          v.state_reg.inner_loop_iter_finished := '1';
        --v.state_reg.drive                    := STATE_FORWARD_ELIMINATION_FINISHED;
        end if;
        if(to_integer(unsigned(r.index_i)) >= P_BANDS-2 and v.valid_data = '1') then
          -- This is the last iteration of the forward elimination, signal
          -- to top module. Not necessary to check for i= P_BANDS-1
          v.state_reg.inner_loop_last_iter_finished := '1';
        end if;
      end if;
    end if;
    if(reset_n = '0') then
      v.index_i                    := 0;
      v.index_j                    := 1;
      v.state_reg.inner_loop_iter_finished      := '0';
      v.state_reg.inner_loop_last_iter_finished := '0';
    end if;
    r_in           <= v;
    output_forward_elim.new_row_j <= r.row_j;
    output_forward_elim.new_inv_row_j <= r.inv_row_j;
    output_forward_elim.state_reg <=r.state_reg;
    output_forward_elim.valid_data <=r.valid_data;
    output_forward_elim.wr_addr_new <=r.index_j; -- bit insecure about this one
    output_forward_elim.r_addr_next <=r.index_i+1;-- also a bit insecure. Maybe
                                                  -- not this module that needs
                                                  -- to control this.
  end process;


  sequential_process : process(clk, clk_en)
  begin
    if(rising_edge(clk) and clk_en = '1') then
      r <= r_in;
    end if;
  end process;

end Behavioral;
