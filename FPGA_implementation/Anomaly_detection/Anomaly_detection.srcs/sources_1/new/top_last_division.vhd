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

  signal r, r_in                         : input_last_division_reg_type;
  constant PRECISION_SHIFT_LAST_DIVISION : integer range 0 to PIXEL_DATA_WIDTH*2 := PIXEL_DATA_WIDTH*2-2;
  constant ONE                           : signed(PIXEL_DATA_WIDTH*2-1 downto 0) := (0 => '1', others => '0');
  constant DIVISION_FACTOR : integer range 0 to 31:= 27;
  constant MULTIPLICATION_FACTOR : integer range 0 to 31 := 20;

begin

  comb_process : process(input_last_division, r, reset_n)
    variable v                                   : input_last_division_reg_type;
    --variable dividend_shifted                    : signed(PIXEL_DATA_WIDTH*2-1 downto 0);
    variable dividend_shifted                    : signed(PIXEL_DATA_WIDTH*2-1-DIVISION_FACTOR downto 0);
    variable tmp                                 : signed(PIXEL_DATA_WIDTH*2-1-DIVISION_FACTOR downto 0);
    variable multiplication_product              : signed(PIXEL_DATA_WIDTH*2*2-1-DIVISION_FACTOR-MULTIPLICATION_FACTOR downto 0);
    variable shifted_down_multiplication_product : signed(PIXEL_DATA_WIDTH*2-1 downto 0);
    variable resized_multiplicator               : signed(PIXEL_DATA_WIDTH*2-1-MULTIPLICATION_FACTOR downto 0);
  begin

    v := r;
    if(input_last_division.state_reg.state = STATE_LAST_DIVISION and input_last_division.valid_data = '1') then
      v.inv_row_i              := input_last_division.inv_row_i;
      v.row_i                  := input_last_division.row_i;
      v.valid_data             := input_last_division.valid_data;
      v.index_i                := input_last_division.index_i;
      v.state_reg.state        := input_last_division.state_reg.state;
      v.write_address_even     := input_last_division.write_address_even;
      v.write_address_odd      := input_last_division.write_address_odd;
      v.flag_write_to_even_row := input_last_division.flag_write_to_even_row;

      --dividend_shifted := resize(shift_left(ONE, PRECISION_SHIFT_LAST_DIVISION), dividend_shifted'length);
      --dividend_shifted := to_signed(to_integer(dividend_shifted)/to_integer(input_last_division.row_i(input_last_division.index_i)), dividend_shifted'length);
      dividend_shifted := resize(shift_left(ONE, PRECISION_SHIFT_LAST_DIVISION-DIVISION_FACTOR), dividend_shifted'length);
      tmp              := resize(input_last_division.row_i(input_last_division.index_i), tmp'length);
      dividend_shifted := to_signed(to_integer(dividend_shifted)/to_integer(tmp), dividend_shifted'length);
      for i in 0 to P_BANDS-1 loop
        resized_multiplicator               := resize(input_last_division.inv_row_i(i), resized_multiplicator'length);
        multiplication_product              := dividend_shifted*resized_multiplicator;
        --multiplication_product              := dividend_shifted*input_last_division.inv_row_i(i);
        --  multiplication_product              := resize(dividend_shifted,multiplication_product'length);
        -- shift down  
        shifted_down_multiplication_product := resize(shift_right(multiplication_product, PRECISION_SHIFT_LAST_DIVISION), shifted_down_multiplication_product'length);
        v.inv_row_i(i)                      := shifted_down_multiplication_product;
      end loop;
    end if;

    if(reset_n = '0' or input_last_division.state_reg.state /= STATE_LAST_DIVISION) then
      v.valid_data := '0';
      for i in 0 to P_BANDS-1 loop
        v.inv_row_i(i) := to_signed(0, PIXEL_DATA_WIDTH*2);
        v.row_i(i)     := to_signed(0, PIXEL_DATA_WIDTH);
      end loop;
      v.index_i                := 0;
      v.state_reg.state        := STATE_IDLE;
      v.write_address_odd      := 0;
      v.write_address_even     := 0;
      v.flag_write_to_even_row := '0';
    end if;
    r_in                                        <= v;
  end process;
  -- Driving outputs from register
    output_last_division.new_inv_row_i          <= r.inv_row_i;
    output_last_division.valid_data             <= r.valid_data;
    output_last_division.index_i                <= r.index_i;
    output_last_division.write_address_even     <= r.write_address_even;
    output_last_division.write_address_odd      <= r.write_address_odd;
    output_last_division.flag_write_to_even_row <= r.flag_write_to_even_row;
    output_last_division.state_reg.state        <= r.state_reg.state;


  sequential_process : process(clk, clk_en)
  begin
    if(rising_edge(clk)) then
      if clk_en = '1' then
        r <= r_in;
      end if;
    end if;
  end process;

end Behavioral;
