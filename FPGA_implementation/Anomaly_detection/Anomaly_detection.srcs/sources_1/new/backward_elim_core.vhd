
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.fixed_pkg.all;

library work;
use work.Common_types_and_functions.all;

entity backward_elim_core is
  port(clk                  : in  std_logic;
       reset_n              : in  std_logic;
       clk_en               : in  std_logic;
       input_backward_elim  : in  input_elimination_reg_type;
       output_backward_elim : out output_backward_elimination_reg_type);
end backward_elim_core;

architecture Behavioral of backward_elim_core is

  signal r, r_in : input_elimination_reg_type;

-- number of shifts required to approximate the division
  signal divisor_is_negative : std_logic;
  -- If the divisor is negative, we need to take two's complement of the divisor
  signal divisor             : std_logic_vector(PIXEL_DATA_WIDTH*2 -1 downto 0);
  signal divisor_valid       : std_logic                             := '0';
  signal remainder_valid     : std_logic                             := '0';
  type remainders_array is array(0 to PIXEL_DATA_WIDTH*2-2) of std_logic_vector(PIXEL_DATA_WIDTH*2-1 downto 0);
  signal remainders          : remainders_array;
  constant ONE               : signed(PIXEL_DATA_WIDTH*2-1 downto 0) := (0 => '1', others => '0');
  -- to be used in two's complement.

  constant INITIAL_BEST_APPROX : remainder_after_approximation_record := (
    remainder        => (PIXEL_DATA_WIDTH*2-1 => '0', others => '1'),
    number_of_shifts => 0,
    remainder_valid  => '0'
    );
begin

  check_if_divisor_is_negative : process(input_backward_elim.state_reg.state, input_backward_elim.row_i, input_backward_elim.valid_data, reset_n)
  begin
    if reset_n = '0'  then
      divisor_valid       <= '0';
      divisor_is_negative <= '0';
      divisor             <= std_logic_vector(to_signed(1, PIXEL_DATA_WIDTH*2));
    elsif(input_backward_elim.row_i(input_backward_elim.index_i)(PIXEL_DATA_WIDTH*2-1) = '1' and input_backward_elim.valid_data = '1') then
      -- row[i][i] is negative
      -- using the absolute value
      divisor_is_negative <= '1';
      divisor             <= std_logic_vector(abs(signed(input_backward_elim.row_i(input_backward_elim.index_i))));
      divisor_valid       <= '1';
    elsif input_backward_elim.row_i(input_backward_elim.index_i)(PIXEL_DATA_WIDTH*2-1) = '0' and input_backward_elim.valid_data = '1' then
      divisor_is_negative <= '0';
      divisor             <= std_logic_vector(input_backward_elim.row_i(input_backward_elim.index_i));
      divisor_valid       <= '1';
    else
      divisor_valid       <= '0';
      divisor_is_negative <= '0';
      divisor             <= std_logic_vector(to_signed(1, PIXEL_DATA_WIDTH*2));
    end if;
  end process;

-- generate PIXEL_DATA_WIDTH*2-1 number of shifters that shifts
-- A[i][i] n places in order to see how many shifts yield the best
-- approximation to the division. Don't need to shift the
-- 31 bit as this is the sign bit.
  generate_shifters : for i in 1 to PIXEL_DATA_WIDTH*2-1 generate
    signal remainder_after_approximation_i : remainder_after_approximation_record;
  begin
    process(divisor, divisor_valid, reset_n, input_backward_elim.state_reg)
    begin
      if reset_n = '0' then
        remainder_after_approximation_i.remainder        <= std_logic_vector(shift_right(signed(divisor), i));
        remainder_after_approximation_i.number_of_shifts <= i;
        remainder_after_approximation_i.remainder_valid  <= '0';
      elsif divisor_valid = '1' then
        remainder_after_approximation_i.remainder        <= std_logic_vector(shift_right(signed(divisor), i));
        remainder_after_approximation_i.number_of_shifts <= i;
        remainder_after_approximation_i.remainder_valid  <= '1';
      else
        remainder_after_approximation_i.remainder        <= std_logic_vector(shift_right(signed(divisor), i));
        remainder_after_approximation_i.number_of_shifts <= i;
      end if;
    end process;
    remainders(i-1) <= remainder_after_approximation_i.remainder;
    remainder_valid <= remainder_after_approximation_i.remainder_valid;
  end generate;

  comb_process : process(input_backward_elim, r, reset_n)
    variable v             : input_elimination_reg_type;
    variable r_j_i         : integer;
    variable r_i_i         : integer;
    variable temp          : integer;
    variable inner_product : integer;
    variable r_i_i_halv    : integer;
  ---
  begin
    v := r;

    if((input_backward_elim.state_reg.state = STATE_BACKWARD_ELIMINATION or input_backward_elim.state_reg.state= STATE_FORWARD_ELIMINATION) and input_backward_elim.valid_data = '1' and remainder_valid = '1') then
      -- Load data set index_j
      v.row_j     := input_backward_elim.row_j;
      v.row_i     := input_backward_elim.row_i;
      v.inv_row_j := input_backward_elim.inv_row_j;
      v.inv_row_i := input_backward_elim.inv_row_i;
      v.index_i   := input_backward_elim.index_i;
      v.index_j   := input_backward_elim.index_j;

      if(v.index_j <= P_BANDS-1) then
        -- Finding the best approx for the divisor A[i][i] only need to be done
        -- once per index i. Currently the design is doing it for each iteration
        v.best_approx := INITIAL_BEST_APPROX;

        -- find msb
        if divisor_is_negative = '1' then
          -- Need to negate the divisor before finding the msb
          v.row_i(input_backward_elim.index_i) := not(v.row_i(input_backward_elim.index_i)) + ONE;
        end if;
        for i in 0 to PIXEL_DATA_WIDTH*2-2 loop
          if(v.row_i(input_backward_elim.index_i)(i) = '1') then
            -- the first '1' found is the msb.
            -- msb index is one-indexed
            v.msb_index := i+1;
          end if;
        end loop;

-- Finding closest approximation to divisor 
        for j in 0 to PIXEL_DATA_WIDTH*2-2 loop
          if to_integer(unsigned(remainders(j))) < to_integer(unsigned(v.best_approx.remainder)) and (j <= v.msb_index) then
            -- This is a better approximation
            v.best_approx.remainder        := remainders(j);
            v.best_approx.number_of_shifts := j;
          end if;
        end loop;

      -- The best approximation to the divisor may be larger than the divisor.
      if to_integer(signed(divisor))- to_integer(shift_left(to_signed(1,PIXEL_DATA_WIDTH*2),v.best_approx.number_of_shifts)) > to_integer(shift_left(to_signed(1, PIXEL_DATA_WIDTH*2), v.best_approx.number_of_shifts+1))- to_integer(signed(divisor)) then
      -- This is a better approximation
       v.best_approx.remainder := std_logic_vector(to_signed(to_integer(shift_left(to_signed(1, PIXEL_DATA_WIDTH*2), v.best_approx.number_of_shifts+1))-to_integer(signed(divisor)), PIXEL_DATA_WIDTH*2));
       v.best_approx.number_of_shifts := v.best_approx.number_of_shifts+1;
       end if;

        r_j_i      := to_integer(input_backward_elim.row_j(input_backward_elim.index_i));
        r_i_i      := to_integer(input_backward_elim.row_i(input_backward_elim.index_i));
        r_i_i_halv := to_integer(shift_right(to_signed(r_i_i, PIXEL_DATA_WIDTH*2), 1));  -- dividing
                                        -- by two
        for i in 0 to P_BANDS-1 loop
          inner_product := to_integer(input_backward_elim.row_i(i))*r_j_i;
          temp          := (inner_product+r_i_i_halv);
          -- The r_i_i_halv is added to get a better approximation when
          -- dividing. This is done because of integer math.
          temp          := to_integer(shift_right(to_signed(temp, PIXEL_DATA_WIDTH*2), v.best_approx.number_of_shifts));
          --if(r_i_i > 0 or r_i_i < 0) then
          --  temp := temp/r_i_i;
          --end if;
          v.row_j(i)    := to_signed(to_integer(signed(input_backward_elim.row_j(i)))-temp, 32);

          inner_product  := to_integer(input_backward_elim.inv_row_i(i))*r_j_i;
          temp           := (inner_product+r_i_i_halv);
          temp           := to_integer(shift_right(to_signed(temp, PIXEL_DATA_WIDTH*2), v.best_approx.number_of_shifts));
          --if(r_i_i > 0 or r_i_i < 0) then
          --  temp := temp/r_i_i;
          --end if;
          v.inv_row_j(i) := to_signed(to_integer(input_backward_elim.inv_row_j(i))-temp, 32);
        end loop;
        -- Control signals --
        v.write_address_odd               := input_backward_elim.write_address_odd;
        v.write_address_even              := input_backward_elim.write_address_even;
        v.flag_write_to_odd_row           := input_backward_elim.flag_write_to_odd_row;
        v.flag_write_to_even_row          := input_backward_elim.flag_write_to_even_row;
        v.state_reg                       := input_backward_elim.state_reg;
        v.valid_data                      := input_backward_elim.valid_data;
        v.forward_elimination_write_state := input_backward_elim.forward_elimination_write_state;
        v.valid_data                      := '1';
      end if;
    end if;
    if(reset_n = '0') then
      v.index_i := P_BANDS-1;
      v.index_j := P_BANDS-2;
    end if;
    r_in                                                 <= v;
    -- data
    output_backward_elim.new_row_j                       <= r.row_j;
    output_backward_elim.new_inv_row_j                   <= r.inv_row_j;
    -- control
    output_backward_elim.state_reg                       <= r.state_reg;
    output_backward_elim.valid_data                      <= r.valid_data;
    output_backward_elim.write_address_even              <= r.write_address_even;
    output_backward_elim.write_address_odd               <= r.write_address_odd;
    output_backward_elim.flag_write_to_even_row          <= r.flag_write_to_even_row;
    output_backward_elim.flag_write_to_odd_row           <= r.flag_write_to_odd_row;
    output_backward_elim.forward_elimination_write_state <= r.forward_elimination_write_state;
  end process;


  sequential_process : process(clk, clk_en)
  begin
    if(rising_edge(clk) and clk_en = '1') then
      r <= r_in;
    end if;
  end process;

end Behavioral;
