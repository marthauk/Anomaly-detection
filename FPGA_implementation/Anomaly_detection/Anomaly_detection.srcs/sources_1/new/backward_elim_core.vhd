
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.fixed_pkg.all;

library work;
use work.Common_types_and_functions.all;

entity backward_elim_core is
  port(clk                 : in  std_logic;
       reset_n             : in  std_logic;
       clk_en              : in  std_logic;
       input_backward_elim  : in  input_elimination_reg_type;
       output_backward_elim : out output_backward_elimination_reg_type);
end backward_elim_core;

architecture Behavioral of backward_elim_core is

  signal r, r_in : input_elimination_reg_type;

begin

  comb_process : process(input_backward_elim, r, reset_n)
    variable v             : input_elimination_reg_type;
    variable r_j_i         : integer;
    variable r_i_i         : integer;
    variable temp          : integer;
    variable inner_product : integer;
    variable r_i_i_halv    : integer;
  ---
  begin
    v                                    := r;
    v.state_reg.start_inner_loop         := input_backward_elim.state_reg.start_inner_loop;
    v.state_reg.inner_loop_iter_finished := '0';  --default value;

    if(input_backward_elim.state_reg.state = STATE_FORWARD_ELIMINATION and input_backward_elim.state_reg.forward_elim_state_signal = STATE_FORWARD_ELIM) then
      -- Load data set index_j
      v.row_j                              := input_backward_elim.row_j;
      v.row_i                              := input_backward_elim.row_i;
      v.index_i                            := input_backward_elim.index_i;
      v.index_j                            := input_backward_elim.index_j;
      v.state_reg.inner_loop_iter_finished := '0';

      if(v.index_j <= P_BANDS-1 and input_backward_elim.valid_data = '1') then

        r_j_i      := to_integer(input_backward_elim.row_j(input_backward_elim.index_i));
        r_i_i      := to_integer(input_backward_elim.row_i(input_backward_elim.index_i));
        r_i_i_halv := to_integer(shift_right(to_signed(r_i_i,32),1));-- dividing
                                                                  -- by two
        for i in 0 to P_BANDS-1 loop
          inner_product := to_integer(input_backward_elim.row_i(i))*r_j_i;
          temp          := (inner_product+r_i_i_halv);
          temp          := temp/r_i_i;
          v.row_j(i)    := to_signed(to_integer(signed(input_backward_elim.row_j(i)))-temp, 32);

          inner_product  := to_integer(input_backward_elim.inv_row_i(i))*r_j_i;
          temp           := (inner_product+r_i_i_halv);
          temp           := temp/r_i_i;
          v.inv_row_j(i) := to_signed(to_integer(input_backward_elim.inv_row_j(i))-temp, 32);

        end loop;
      end if;
    end if;
    if(reset_n = '0') then
      v.index_i                                 := P_BANDS-1;
      v.index_j                                 := P_BANDS-2;
    end if;
    r_in                              <= v;
    output_backward_elim.new_row_j     <= r.row_j;
    output_backward_elim.new_inv_row_j <= r.inv_row_j;
    output_backward_elim.state_reg     <= r.state_reg;
    output_backward_elim.valid_data    <= r.valid_data;
    output_backward_elim.wr_addr_new   <= r.index_j;  -- bit insecure about this one
    output_backward_elim.r_addr_next   <= r.index_i+1;  -- also a bit insecure. Maybe
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
