----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/17/2018 01:21:37 PM
-- Design Name: 
-- Module Name: fsm_inverse_matrix - Behavioral
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
use IEEE.STD_LOGIC_1164.all;

library work;
use work.Common_types_and_functions.all;
--use work.gauss_jordan_pkg.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fsm_inverse_matrix is
  port (reset           : in    std_logic;
        clk             : in    std_logic;
        clk_en          : in    std_logic;
        start_inversion : in    std_logic;
        state_reg       : inout reg_state_type);
end fsm_inverse_matrix;

architecture Behavioral of fsm_inverse_matrix is

  signal r, r_in : reg_state_type;      --cointains all registered values 

begin

  comb : process(r, reset, start_inversion)
    variable v : reg_state_type;

  begin
    v       := r;
    v.drive := state_reg.drive;
    case state_reg.state is
      when STATE_IDLE =>
        if(start_inversion = '1') then
          v.state                     := STATE_FORWARD_ELIMINATION;
          v.forward_elim_ctrl_signal  := START_FORWARD_ELIM_TRIANGULAR;
          v.forward_elim_state_signal := STATE_FORWARD_TRIANGULAR;
        end if;
      when STATE_FORWARD_ELIMINATION =>
        if (r.forward_elim_ctrl_signal = START_FORWARD_TRIANGULAR) then
          v.forward_elim_ctrl_signal := STATE_IDLE_DRIVE;
        elsif (r.forward_elim_ctrl_signal = START_FORWARD_ELIM_CORE) then
          v.forward_elim_ctrl_signal := STATE_IDLE_DRIVE;
        end if;
        if (r.drive = STATE_FORWARD_ELIMINATION_TRIANGULAR_FINISHED) then
          v.forward_elim_state_signal := STATE_FORWARD_ELIM;
          v.forward_elim_ctrl_signal  := START_FORWARD_ELIM_CORE;
        end if;
        if (r.drive = STATE_FORWARD_ELIMINATION_FINISHED) then
          v.state := STATE_BACKWARD_ELIMINATION;
        end if;
      when STATE_BACKWARD_ELIMINATION =>
        if(r.drive = STATE_BACKWARD_ELIMINATION_FINISHED) then
          v.state := STATE_IDENTITY_MATRIX_BUILDING;
        end if;
      when STATE_IDENTITY_MATRIX_BUILDING =>
        if(r.drive = STATE_IDENTITY_MATRIX_BUILDING_FINISHED) then
          v.state := STATE_IDLE;
        end if;
      when others =>
        v.drive := STATE_IDLE_DRIVE;
        v.state := STATE_IDLE;
    end case;
    if(reset = '1') then
      v.state := STATE_IDLE;
      v.drive := STATE_IDLE_DRIVE;
    end if;
    r_in      <= v;
    --state.state <= v.state; -- Combinatorial output;
    state_reg <= r;                     --registered output
  end process;

  sequential_process : process(clk, clk_en)
  begin
    if(rising_edge(clk) and clk_en = '1') then
      r <= r_in;
    end if;
  end process;


end Behavioral;
