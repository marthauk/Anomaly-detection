library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;

entity top_backward_elim_gauss is
  port(clk : in std_logic;
       reset : in std_logic;
       clk_en : in std_logic;
       M : in matrix_reg_type;
       M_backward_elim : inout matrix_reg_type);
       end top_backward_elim_gauss;

       architecture Behavioral of top_backward_elim_gauss is

      signal r : row_reg_type ;--:= C_ROW_REG_TYPE_INIT  ;
      signal r_in, backward_elim_row : row_reg_type;

       begin


         backward_elim_gauss_1 : entity work.backward_elim_gauss
           port map (
             clk => clk,
             reset => reset,
             clk_en => clk_en,
             row => r,
             backward_elim_row => backward_elim_row);

         comb_process : process(M, r, r_in, reset, backward_elim_row)
           variable v : row_reg_type ;
           variable v_backward_eliminated : matrix_reg_type;

           begin
           v := r;
           v_backward_eliminated := M;

           if(M.state_reg.state = STATE_BACKWARD_ELIMINATION) then
             for i in 0 to P_BANDS-1 loop
           if(M.state_reg.fsm_start_signal = START_BACKWARD_ELIMINATION and M.valid_matrix_data ='1') then
             v.backward_elim_index_i := std_logic_vector(to_signed(P_BANDS-1, 32));
             v.backward_elim_index_j := std_logic_vector(to_signed(P_BANDS-2, 32));
             v.valid_data := '1'; 
           end if;
             if(backward_elim_row.valid_data = '1') then -- Returned backward
                                                         -- eliminated row data
               v_backward_eliminated.matrix(to_integer(unsigned(v.backward_elim_index_j)), i) := backward_elim_row.row_j(0,i);
               v_backward_eliminated.matrix_inv(to_integer(unsigned(v.backward_elim_index_j)), i) := backward_elim_row.row_j(0,i);
             end if;
              -- v.row_j(0, i) := M.matrix(to_integer(unsigned(v.backward_elim_index_j)), i);
              -- v.row_i(0, i) := M.matrix(to_integer(unsigned(v.backward_elim_index_i)), i);
              -- v.inv_row_j(0, i) := M.matrix_inv(to_integer(unsigned(v.backward_elim_index_j)), i);
              -- v.inv_row_i(0, i) := M.matrix_inv(to_integer(unsigned(v.backward_elim_index_i)), i);
               v.row_j(0, i) := v_backward_eliminated.matrix(to_integer(unsigned(v.backward_elim_index_j)), i);
               v.row_i(0, i) := v_backward_eliminated.matrix(to_integer(unsigned(v.backward_elim_index_i)), i);
               v.inv_row_j(0, i) := v_backward_eliminated.matrix_inv(to_integer(unsigned(v.backward_elim_index_j)), i);
               v.inv_row_i(0, i) := v_backward_eliminated.matrix_inv(to_integer(unsigned(v.backward_elim_index_i)), i);

               v.a_j_i := M.matrix(to_integer(unsigned(v.backward_elim_index_j)), to_integer(unsigned(v.backward_elim_index_i)));
               v.a_i_i := M.matrix(to_integer(unsigned(v.backward_elim_index_i)), to_integer(unsigned(v.backward_elim_index_i)));
           if(v.backward_elim_index_i = std_logic_vector(to_unsigned(1, 32))) then
                    -- Finished backward elimination!
                    v_backward_eliminated.state_reg.drive:= STATE_BACKWARD_ELIMINATION_FINISHED;
           elsif(v.backward_elim_index_j = std_logic_vector(to_unsigned(0, 32))) then
               v.backward_elim_index_i := std_logic_vector(to_signed(to_integer(signed(v.backward_elim_index_i)) -1, 32));
               v.backward_elim_index_j := std_logic_vector(to_signed(to_integer(signed(v.backward_elim_index_i)) -1, 32));
           else
               v.backward_elim_index_j := std_logic_vector(to_signed(to_integer(signed(v.backward_elim_index_j)) -1, 32));
           end if;
             end loop;
           end if;
           if(reset = '1') then
             v.backward_elim_index_i := std_logic_vector(to_signed(P_BANDS-1, 32));
             v.backward_elim_index_j := std_logic_vector(to_signed(P_BANDS-1-1, 32));
           end if;
           r_in <= v;
           M_backward_elim <= v_backward_eliminated; 

         end process;


         sequential_process : process(clk, clk_en)
         begin
           if(rising_edge(clk) and clk_en = '1') then
             r <= r_in;
           end if;
         end process;

       end Behavioral;
