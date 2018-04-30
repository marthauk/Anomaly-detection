library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;

entity top_last_division is
  port(clk                  : in  std_logic;
       reset_n              : in  std_logic;
       clk_en               : in  std_logic;
       input_last_division  : in  input_last_division_reg_type;
       output_last_division : out output_last_division_reg_type);
end top_last_division;

architecture Behavioral of top_last_division is

  signal r, r_in             : input_last_division_reg_type;
-- number of shifts required to approximate the division
  signal number_of_shifts    : integer range 0 to 32;
  signal divisor_is_negative : std_logic;
  -- If the divisor is negative, we need to take two's complement of the divisor
  signal divisor             : std_logic_vector(PIXEL_DATA_WIDTH*2 -1 downto 0);
  signal divisor_valid       : std_logic                             := '0';
  signal remainder_valid     : std_logic                             := '0';
  signal shifter_valid       : std_logic                             := '0';
  signal msb_of_divisor      : integer range 0 to 31;
  type remainders_array is array(0 to PIXEL_DATA_WIDTH*2-2) of std_logic_vector(PIXEL_DATA_WIDTH*2-1 downto 0);
  signal remainders          : remainders_array;
  constant ONE               : signed(PIXEL_DATA_WIDTH*2-1 downto 0) := (0 => '1', others => '0');
  -- to be used in two's complement.

  type remainder_after_approximation_record is record
    remainder        : std_logic_vector(PIXEL_DATA_WIDTH*2-1 downto 0);  -- For PIXEL_DATA_WIDTH of 16
    number_of_shifts : integer range 0 to 31;
    remainder_valid  : std_logic;
    shifter_valid    : std_logic;
  end record;
  constant INITIAL_BEST_APPROX : remainder_after_approximation_record := (
    remainder        => (PIXEL_DATA_WIDTH*2-1 => '0', others => '1'),
    number_of_shifts => 0,
    remainder_valid  => '0',
    shifter_valid    => '0'
    );

begin

  check_if_divisor_is_negative : process(input_last_division.state_reg.state, input_last_division.row_i, input_last_division.valid_data, reset_n)
    variable divisor_valid_temp       : std_logic        := '0';
    variable divisor_is_negative_temp : std_logic        := '0';
    variable divisor_temp             : std_logic_vector := std_logic_vector(to_signed(1, PIXEL_DATA_WIDTH*2));
  begin
    if reset_n ='0' or not(input_last_division.state_reg.state =STATE_LAST_DIVISION)  then 
      divisor_valid_temp       := '0';
      divisor_is_negative_temp := '0';
      divisor_temp             := std_logic_vector(to_signed(1, PIXEL_DATA_WIDTH*2));
    elsif(input_last_division.row_i(input_last_division.index_i)(PIXEL_DATA_WIDTH*2-1) = '1' and input_last_division.valid_data = '1') then
      -- row[i][i] is negative
      -- using the absolute value
      divisor_is_negative_temp := '1';
      divisor_temp             := std_logic_vector(abs(signed(input_last_division.row_i(input_last_division.index_i))));
      divisor_valid_temp       := '1';
    elsif input_last_division.row_i(input_last_division.index_i)(PIXEL_DATA_WIDTH*2-1) = '0' and input_last_division.valid_data = '1' then
      divisor_is_negative_temp := '0';
      divisor_temp             := std_logic_vector(input_last_division.row_i(input_last_division.index_i));
      divisor_valid_temp       := '1';
    else
      divisor_valid_temp       := '0';
      divisor_is_negative_temp := '0';
      divisor_temp             := std_logic_vector(to_signed(1, PIXEL_DATA_WIDTH*2));
    end if;
    divisor_valid       <= divisor_valid_temp;
    divisor_is_negative <= divisor_is_negative_temp;
    divisor             <= divisor_temp;
  end process;

  find_msb_of_divisor : process(input_last_division.row_i, divisor_valid)
    variable msb_index : integer range 0 to 31;
  begin
    if(divisor_valid = '1' and input_last_division.state_reg.state = STATE_LAST_DIVISION) then
      for i in 0 to PIXEL_DATA_WIDTH*2-2 loop
        if(input_last_division.row_i(input_last_division.index_i)(i) = '1') then
          -- the first '1' found is the msb.
          msb_index := i;
        end if;
      end loop;
    else
      msb_index := 31;
    end if;
    msb_of_divisor <= msb_index;
  end process;


-- generate PIXEL_DATA_WIDTH*2-1 number of shifters that shifts
-- A[i][i] n places in order to see how many shifts yield the best
-- approximation to the division. Don't need to shift the
-- 31 bit as this is the sign bit.
  generate_shifters : for i in 1 to PIXEL_DATA_WIDTH*2-1 generate
    signal remainder_after_approximation_i : remainder_after_approximation_record;
  begin
    process(divisor, divisor_valid, reset_n, input_last_division.state_reg)
    begin
      if reset_n = '0' or not(input_last_division.state_reg.state = STATE_LAST_DIVISION) then
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
        remainder_after_approximation_i.remainder_valid  <= '0';
      end if;
    end process;
    remainders(i-1) <= remainder_after_approximation_i.remainder;
    remainder_valid <= remainder_after_approximation_i.remainder_valid;
  end generate;

  find_closest_approximation : process (remainders, msb_of_divisor, reset_n, input_last_division.state_reg, remainder_valid)
    variable best_approx : remainder_after_approximation_record := INITIAL_BEST_APPROX;
  begin
    if reset_n = '0' or input_last_division.state_reg.state /= STATE_LAST_DIVISION then
      best_approx := INITIAL_BEST_APPROX;
    elsif(remainder_valid = '1') then
      for i in 1 to PIXEL_DATA_WIDTH*2-2 loop
        if to_integer(unsigned(remainders(i))) < to_integer(unsigned(best_approx.remainder)) and (i <= msb_of_divisor) then
          -- This is a better approximation
          best_approx.remainder        := remainders(i);
          best_approx.number_of_shifts := i;
          best_approx.remainder_valid  := remainder_valid;
          best_approx.shifter_valid    := '1';
        else
          best_approx := INITIAL_BEST_APPROX;
        end if;
      end loop;
    else
      best_approx := INITIAL_BEST_APPROX;
    end if;
    number_of_shifts <= best_approx.number_of_shifts;
    shifter_valid    <= best_approx.shifter_valid;
  end process;


  comb_process : process(input_last_division, r, reset_n, number_of_shifts, divisor_is_negative, divisor, shifter_valid)
    variable v : input_last_division_reg_type;
  begin

    v := r;
    if(input_last_division.state_reg.state = STATE_LAST_DIVISION and input_last_division.valid_data = '1' and shifter_valid = '1') then
      v := input_last_division;
      if divisor_is_negative = '1' then
        for i in 0 to P_BANDS-1 loop
          v.inv_row_i(i) := shift_right(input_last_division.inv_row_i(i), number_of_shifts);
          -- Negating the number with two's complement
          v.inv_row_i(i) := not(v.inv_row_i(i)) + ONE;
        end loop;
      else
        for i in 0 to P_BANDS-1 loop
          v.inv_row_i(i) := shift_right(input_last_division.inv_row_i(i), number_of_shifts);
        end loop;
      end if;
    end if;

    if(reset_n = '0') then
      v.valid_data := '0';
    end if;
    r_in                                        <= v;
    output_last_division.new_inv_row_i          <= r.inv_row_i;
    output_last_division.valid_data             <= r.valid_data;
    output_last_division.index_i                <= r.index_i;
    output_last_division.write_address_even     <= r.write_address_even;
    output_last_division.write_address_odd      <= r.write_address_odd;
    output_last_division.flag_write_to_even_row <= r.flag_write_to_even_row;
    output_last_division.state_reg              <= r.state_reg;
  end process;


  sequential_process : process(clk, clk_en)
  begin
    if(rising_edge(clk) and clk_en = '1') then
      r <= r_in;
    end if;
  end process;

end Behavioral;
