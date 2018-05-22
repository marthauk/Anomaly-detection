
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
--use IEEE.fixed_pkg.all;

library work;
use work.Common_types_and_functions.all;

-- This core is utilized by both backward and forward elimination
entity backward_elim_core is
  port(clk                  : in  std_logic;
       reset_n              : in  std_logic;
       clk_en               : in  std_logic;
       input_backward_elim  : in  input_elimination_reg_type;
       output_backward_elim : out output_backward_elimination_reg_type);
end backward_elim_core;

architecture Behavioral of backward_elim_core is

  signal r, r_in           : input_elimination_reg_type;
  constant ONE             : signed(PIXEL_DATA_WIDTH*2-1 downto 0) := (0 => '1', others => '0');
  constant PRECISION_SHIFT : integer range 0 to 3                  := 3;  -- Used to specify numbers of
                                        -- shift of r_j_i
  signal divisor_is_negative : std_logic;
  -- If the divisor is negative, we need to take two's complement of the divisor
  signal divisor             : std_logic_vector(PIXEL_DATA_WIDTH*2 -1 downto 0);
  signal divisor_valid       : std_logic                             := '0';
  signal remainder_valid     : std_logic                             := '0';
  type remainders_array is array(0 to PIXEL_DATA_WIDTH*2-2) of std_logic_vector(PIXEL_DATA_WIDTH*2-1 downto 0);
  signal remainders          : remainders_array;
  signal msb_index           : integer range 0 to 31;  -- msb of the divisor(unsigned)
  signal msb_valid           : std_logic                             := '0';
  -- to be used in two's complement.
  signal divisor_lut         : unsigned(DIV_PRECISION-1 downto 0);
  signal divisor_inv         : unsigned(DIV_PRECISION-1 downto 0);
begin

  division_lut_2 : entity work.division_lut
    port map (
      y     => divisor_lut,
      y_inv => divisor_inv);

  input_to_divisor_lut: process(msb_valid,msb_index)
  begin
    if msb_valid ='1' then
        divisor_lut      <= to_unsigned(msb_index, DIV_PRECISION);
    else
        divisor_lut      <= to_unsigned(0, DIV_PRECISION);
    end if;
  end process;
      

  check_if_divisor_is_negative : process(input_backward_elim.state_reg.state, input_backward_elim.row_i, input_backward_elim.valid_data, reset_n)
  begin
    if reset_n = '0' or not(input_backward_elim.state_reg.state = STATE_LAST_DIVISION) then
      divisor_valid       <= '0';
      divisor_is_negative <= '0';
      divisor             <= std_logic_vector(to_signed(1, PIXEL_DATA_WIDTH*2));
    elsif(input_backward_elim.row_i(input_backward_elim.index_i)(PIXEL_DATA_WIDTH*2-1) = '1' and input_backward_elim.valid_data = '1') then
      -- row[i][i] is negative
      -- using the absolute value
      divisor_is_negative <= '1';
      divisor             <= std_logic_vector(abs(signed(input_backward_elim.row_i(input_backward_elim.index_i))));
      divisor_valid       <= '1';
    elsif input_backward_elim.valid_data = '1' then
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
      if reset_n = '0' or not(input_backward_elim.state_reg.state = STATE_LAST_DIVISION) then
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


  find_msb : process(divisor_valid, input_backward_elim, reset_n, divisor)
  begin
    if divisor_valid = '1' and reset_n = '1' then
      --For PIXEL_DATA_WIDTH = 16.
      if divisor(30) = '1' then
        msb_index <= 30;
      elsif divisor(29) = '1' then
        msb_index <= 29;
      elsif divisor(28) = '1' then
        msb_index <= 28;
      elsif divisor(27) = '1' then
        msb_index <= 27;
      elsif divisor(26) = '1'then
        msb_index <= 26;
      elsif divisor(25) = '1' then
        msb_index <= 25;
      elsif divisor(24) = '1' then
        msb_index <= 24;
      elsif divisor(23) = '1' then
        msb_index <= 23;
      elsif divisor(22) = '1' then
        msb_index <= 22;
      elsif divisor(21) = '1' then
        msb_index <= 21;
      elsif divisor(20) = '1' then
        msb_index <= 20;
      elsif divisor(19) = '1' then
        msb_index <= 19;
      elsif divisor(18) = '1' then
        msb_index <= 18;
      elsif divisor(17) = '1'then
        msb_index <= 17;
      elsif divisor(16) = '1' then
        msb_index <= 16;
      elsif divisor(15) = '1' then
        msb_index <= 15;
      elsif divisor(14) = '1' then
        msb_index <= 14;
      elsif divisor(13) = '1' then
        msb_index <= 13;
      elsif divisor(12) = '1' then
        msb_index <= 12;
      elsif divisor(11) = '1' then
        msb_index <= 11;
      elsif divisor(10) = '1'then
        msb_index <= 10;
      elsif divisor(9) = '1' then
        msb_index <= 9;
      elsif divisor(8) = '1' then
        msb_index <= 8;
      elsif divisor(7) = '1' then
        msb_index <= 7;
      elsif divisor(6) = '1' then
        msb_index <= 6;
      elsif divisor(5) = '1' then
        msb_index <= 5;
      elsif divisor(4) = '1' then
        msb_index <= 4;
      elsif divisor(3) = '1' then
        msb_index <= 3;
      elsif divisor(2) = '1' then
        msb_index <= 2;
      elsif divisor(1) = '1' then
        msb_index <= 1;
      elsif divisor(0) = '1' then
        msb_index <= 0;
      end if;
      msb_valid <= '1';
    else
      msb_index <= 0;
      msb_valid <= '0';
    end if;
  end process;

  comb_process : process(input_backward_elim, r, reset_n, divisor_is_negative, divisor, remainder_valid, remainders, msb_valid, divisor, divisor_inv, msb_index)
    variable v                          : input_elimination_reg_type;
    variable r_j_i                      : signed(PIXEL_DATA_WIDTH*2 + PRECISION_SHIFT-1 downto 0);
    variable r_i_i                      : integer;
    variable temp                       : integer;
    --variable r_j_i_divided              : signed (PIXEL_DATA_WIDTH*2+PRECISION_SHIFT-1 downto 0);
    variable inner_product              : signed(PIXEL_DATA_WIDTH*2 + PIXEL_DATA_WIDTH*2+PRECISION_SHIFT-1 downto 0);
    variable shifted_down_inner_product : signed(PIXEL_DATA_WIDTH*2-1 downto 0);
    --variable r_i_i_halv                 : integer;
    variable r_i_i_halv                 : signed(PIXEL_DATA_WIDTH*2 +PRECISION_SHIFT-1 downto 0);
    variable divisor_inv_from_lut : integer range 0 to 2**DIV_PRECISION:=0;
  ---
  begin
    v := r;

    if((input_backward_elim.state_reg.state = STATE_BACKWARD_ELIMINATION or input_backward_elim.state_reg.state = STATE_FORWARD_ELIMINATION) and input_backward_elim.valid_data = '1' and remainder_valid='1' and msb_valid='1') then
      -- Load data set index_j
      v.row_j     := input_backward_elim.row_j;
      v.row_i     := input_backward_elim.row_i;
      v.inv_row_j := input_backward_elim.inv_row_j;
      v.inv_row_i := input_backward_elim.inv_row_i;
      v.index_i   := input_backward_elim.index_i;
      v.index_j   := input_backward_elim.index_j;
      v.best_approx := INITIAL_BEST_APPROX;
      v.msb_index   := msb_index;

      r_i_i         := to_integer(input_backward_elim.row_i(input_backward_elim.index_i));
      --r_i_i_halv    := to_integer(shift_right(to_signed(r_i_i, PIXEL_DATA_WIDTH*2), 1));  -- dividing
      r_i_i_halv    := shift_left((shift_right(to_signed(r_i_i, r_i_i_halv'length), 1)),PRECISION_SHIFT);
--dividing by two, then shifting up again with precision shift.

      r_j_i         := shift_left(resize(input_backward_elim.row_j(input_backward_elim.index_i), r_j_i'length), PRECISION_SHIFT);
      -- For more precise integer division(in Vivado the rounding is always downwards)
      r_j_i         := r_j_i+r_i_i_halv;

      if v.msb_index <= DIV_PRECISION then
        divisor_inv_from_lut := to_integer(divisor_inv);
      else
        --Using shifting approach
        divisor_inv_from_lut := to_integer(divisor_inv);

        -- The best approximation may be either the msb-shifted division, or the
        -- msb+1 shifted division.
        v.best_approx.remainder        := remainders(v.msb_index);
        v.best_approx.number_of_shifts := v.msb_index;
        -- The best approximation to the divisor may be larger than the divisor.
        if to_integer(signed(divisor))- to_integer(shift_left(to_signed(1, PIXEL_DATA_WIDTH*2), v.best_approx.number_of_shifts)) > to_integer(shift_left(to_signed(1, PIXEL_DATA_WIDTH*2), v.best_approx.number_of_shifts+1))- to_integer(signed(divisor)) then
          -- This is a better approximation
          v.best_approx.remainder        := std_logic_vector(to_signed(to_integer(shift_left(to_signed(1, PIXEL_DATA_WIDTH*2), v.best_approx.number_of_shifts+1))-to_integer(signed(divisor)), PIXEL_DATA_WIDTH*2));
          v.best_approx.number_of_shifts := v.best_approx.number_of_shifts+1;
        end if;
      end if;

      for i in 0 to P_BANDS-1 loop
        --inner_product := to_signed(to_integer(input_backward_elim.row_i(i))*to_integer(r_j_i_divided), inner_product'length);
        if v.msb_index <= DIV_PRECISION then
          -- Using lut-table
         inner_product := resize(input_backward_elim.row_i(i)* r_j_i*divisor_inv_from_lut,inner_product'length); 
        shifted_down_inner_product :=resize(shift_right(inner_product,PRECISION_SHIFT+DIV_PRECISION),shifted_down_inner_product'length);
         -- To matrix A
        v.row_j(i)    := to_signed(to_integer(signed(input_backward_elim.row_j(i)))-to_integer(shifted_down_inner_product), PIXEL_DATA_WIDTH*2);

         inner_product := resize(input_backward_elim.inv_row_i(i)* r_j_i*divisor_inv_from_lut,inner_product'length); 
        shifted_down_inner_product :=resize(shift_right(inner_product,PRECISION_SHIFT+DIV_PRECISION),shifted_down_inner_product'length);
        -- To matrix A_inv
        v.inv_row_j(i) := to_signed(to_integer(input_backward_elim.inv_row_j(i))-to_integer(shifted_down_inner_product), PIXEL_DATA_WIDTH*2);

          else
            -- Using shifting approach to division
            inner_product := shift_right(input_backward_elim.row_i(i)*r_j_i,v.best_approx.number_of_shifts);
            shifted_down_inner_product :=resize(shift_right(inner_product,PRECISION_SHIFT),shifted_down_inner_product'length);
         -- To matrix A
        v.row_j(i)    := to_signed(to_integer(signed(input_backward_elim.row_j(i)))-to_integer(shifted_down_inner_product), PIXEL_DATA_WIDTH*2);
            inner_product := shift_right(input_backward_elim.inv_row_i(i)*r_j_i,v.best_approx.number_of_shifts);
            shifted_down_inner_product :=resize(shift_right(inner_product,PRECISION_SHIFT),shifted_down_inner_product'length);
        -- To matrix A_inv
        v.inv_row_j(i) := to_signed(to_integer(input_backward_elim.inv_row_j(i))-to_integer(shifted_down_inner_product), PIXEL_DATA_WIDTH*2);

            end if;
        --inner_product := input_backward_elim.row_i(i)*r_j_i_divided;
        --shift down again since shifting r_j_i by PRECISION_SHIFT number of
        --shifts
        --shifted_down_inner_product :=resize(shift_right(inner_product,PRECISION_SHIFT+PIXEL_DATA_WIDTH*2),shifted_down_inner_product'length);
        --temp          := (inner_product+r_i_i_halv);
        -- The r_i_i_halv is added to get a better approximation when
        -- dividing. This is done because of integer math.
        --temp          := to_integer(shift_right(to_signed(temp, PIXEL_DATA_WIDTH*2), v.best_approx.number_of_shifts));
        --v.row_j(i)    := to_signed(to_integer(signed(input_backward_elim.row_j(i)))-temp, 32);
        --v.row_j(i)    := to_signed(to_integer(signed(input_backward_elim.row_j(i)))-to_integer(shifted_down_inner_product), PIXEL_DATA_WIDTH*2);

        --inner_product := input_backward_elim.inv_row_i(i)*r_j_i_divided;
        --inner_product  := to_signed(to_integer(input_backward_elim.inv_row_i(i))*to_integer(r_j_i_divided), inner_product'length);
        --shift down again since shifting r_j_i
        --shifted_down_inner_product :=resize(shift_right(inner_product,PRECISION_SHIFT+PIXEL_DATA_WIDTH*2),shifted_down_inner_product'length);
        --temp           := (inner_product+r_i_i_halv);
        --temp           := to_integer(shift_right(to_signed(temp, PIXEL_DATA_WIDTH*2), v.best_approx.number_of_shifts));
        --v.inv_row_j(i) := to_signed(to_integer(input_backward_elim.inv_row_j(i))-to_integer(shifted_down_inner_product), PIXEL_DATA_WIDTH*2);
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
    if(reset_n = '0') then
      v.index_i    := P_BANDS-1;
      v.index_j    := P_BANDS-2;
      v.valid_data := '0';
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
