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
       input_elimination          : in  input_elimination_reg_type;
       output_forward_elimination : out output_forward_elimination_reg_type
       );
end top_forward_elimination;

architecture Behavioral of top_forward_elimination is

  signal r, r_in                     : input_elimination_reg_type;

begin



  comb_process : process(input_elimination, r, reset_n, row_forward_elim_inner)

    variable v : input_elimination_reg_type;

  begin
    v                            := r;
    if(input_elimination.state_reg.state = STATE_FORWARD_ELIMINATION and input_elimination.valid_data ='1') then
      case r.state_reg.state


    if(reset_n = '0') then
      v.index_i      := 0;--P_BANDS-1;
      v.index_j := 1;--P_BANDS-2;
    end if;
    r_in                                     <= v;
    output_forward_elimination.new_row_j     <= r.row_j;      
    output_forward_elimination.new_row_i     <= r.row_i;      
    output_forward_elimination.new_inv_row_j <= r.inv_row_j;  
    output_forward_elimination.wr_addr_new   <= r.index_j;

  end process;


  sequential_process : process(clk, clk_en)
  begin
    if(rising_edge(clk) and clk_en = '1') then
      r <= r_in;
    end if;
  end process;

end Behavioral;
