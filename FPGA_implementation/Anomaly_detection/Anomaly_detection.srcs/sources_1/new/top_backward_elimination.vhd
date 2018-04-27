----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03/15/2018 04:26:59 PM
-- Design Name: 
-- Module Name: top_backward_elimination - Behavioral
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


entity top_backward_elimination is
  port(clk                  : in  std_logic;
       reset_n              : in  std_logic;
       clk_en               : in  std_logic;
       din                  : in  input_elimination_reg_type;
       backward_elim_output : out output_backward_elimination_reg_type);
end top_backward_elimination;

architecture Behavioral of top_backward_elimination is

  signal backward_elim_core   : input_elimination_reg_type;
  signal output_backward_elim : output_backward_elimination_reg_type;
  signal r, r_in              : input_elimination_reg_type;

begin



 -- backward_elim_core_1 : entity work.backward_elim_core
 --   port map (
 --     clk                  => clk,
 --     reset_n              => reset_n,
 --     clk_en               => clk_en,
 --     input_backward_elim  => backward_elim_core,
 --     output_backward_elim => output_backward_elim);

  -- Drive the top-level output
  backward_elim_output <= output_backward_elim;

  comb_process : process(r, reset_n, din, output_backward_elim)
    variable v : input_elimination_reg_type;

  begin
    v                            := r;
    v.state_reg.fsm_start_signal := din.state_reg.fsm_start_signal;

    if(din.state_reg.state = STATE_BACKWARD_ELIMINATION and not(r.state_reg.drive = STATE_BACKWARD_ELIMINATION_FINISHED)) then
      if(din.state_reg.fsm_start_signal = START_BACKWARD_ELIMINATION ) then
        -- Set index_i and j, the index of the outer forward
        -- elimination loop. Also start triangular-loop if M[i][i]==0
        v                                     := din;
        v.index_i                             := P_BANDS-1;
        v.index_j                             := P_BANDS-2;
        --v.row_reg.valid_data                  := '1';
        v.state_reg.start_inner_loop          := '1';
        v.state_reg.flag_forward_core_started := '0';
      else
        v.state_reg.start_inner_loop := '0';
      end if;
      if (din.valid_data = '1' and r.index_i >= 0) then
        -- receive row_i and row_j from top-level
        if(din.index_i = v.index_i and din.index_j = v.index_j) then
          -- receive the correct data from topmodule(according to
          -- expectations),send further to backwards-core
          backward_elim_core.index_i   <= din.index_i;
          backward_elim_core.index_j   <= din.index_j;
          backward_elim_core.row_j     <= din.row_j;
          backward_elim_core.row_i     <= din.row_i;
          backward_elim_core.inv_row_j <= din.inv_row_j;
          backward_elim_core.inv_row_i <= din.inv_row_i;
          backward_elim_core.valid_data <= '1';
          -- has sent input to backward elim core, need to update elim index i
          -- and j
          if v.index_j > 0 then
            v.index_j := v.index_j -1;  -- be obs about using v.index_j... maybe
          -- use r.index_j ?
          elsif v.index_j <= 0 then
            if v.index_i > 2 then
              v.index_i := v.index_i -1;
            elsif v.index_i <= 1 then
            -- finished backward elimination
            end if;
          end if;

        end if;
        --if(output_backward_elim.row_reg.valid_data = '1' and output_backward_elim.index_j > 0) then
        --  -- received data
        --  -- update index_i and index_j 
        --  --v.row_reg.elim_index_i                := r.index_i-1, 32));
        --  v.state_reg.inner_loop_iter_finished  := '0';
        --  v.state_reg.start_inner_loop          := '1';

      --  -- Must know if receiving two row.j-s or one row_j and one row.i
      --  v.row_j     := din.row_j;
      --  v.row_i     := din.row_i;
      --  v.inv_row_j := din.inv_row_j;
      --  v.inv_row_i := din.inv_row_i;
      --end if;
      end if;
    end if;
    if(reset_n = '0') then
      v.index_i := P_BANDS-1;
      v.index_j := P_BANDS-2;
    end if;
    r_in            <= v;
    

  end process;


  sequential_process : process(clk, clk_en)
  begin
    if(rising_edge(clk) and clk_en = '1') then
      r <= r_in;
    end if;
  end process;

end Behavioral;






