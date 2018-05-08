library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;

-- Correlation module with AXI lite stream interface
entity acad_correlation is
  port(din                : in    std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH-1 downto 0);  --
                                        --Horizontal
                                        --input vector
       valid              : in    std_logic;
       clk                : in    std_logic;
       clk_en             : in    std_logic;
       reset_n            : in    std_logic;
       dout               : inout std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto
                                     0);  -- writing two 32-bit elements per cycle
       valid_out : out std_logic;
       writes_done_on_row : out   std_logic_vector(log2(P_BANDS/2) downto 0)
       );
end acad_correlation;

architecture Behavioral of acad_correlation is
  constant N_BRAMS                    : integer range 0 to P_BANDS*2 := P_BANDS*2;
-- using 18kbit BRAM, one for odd indexes, one for even per row of the
-- correlation matrix. This results in P_BANDS 36kbit BRAMs actually being synthesized.
  constant NUMBER_OF_WRITES_PER_CYCLE : integer range 0 to 2         := 2;  --
                                                                            --see
                                                                            --above comment
  constant NUMBER_OF_WRITES_PER_ROW   : integer range 0 to P_BANDS/2 := P_BANDS/2;

  signal r_write_address     : integer range 0 to B_RAM_SIZE-1             := 0;
  signal write_done_on_row   : std_logic_vector (log2(P_BANDS/2) downto 0) := (others => '0');
-- width defined in TDP spec
  signal flag_has_read_first : std_logic :=
    '0';  --first element in the read-write pipeline 
  signal flag_has_read_second : std_logic :=
    '0';  --second element in the read-write pipeline 
  signal write_enable     : std_logic := '0';
  signal read_enable      : std_logic := '1';
  signal read_address     : integer range 0 to B_RAM_SIZE-1;
  signal write_address    : integer range 0 to B_RAM_SIZE-1;
  signal flag_first_pixel : std_logic := '1';
-- indicates that the current pixel working on is the first pixel 
  signal r_dout_prev : std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2-1 downto
                                        0);  -- Previous value
                                             -- outputted from the BRAMs.
  signal r_read_address : integer range 0 to B_RAM_SIZE-1 := 0;




begin


  gen_BRAM_18_updates : for i in 0 to P_BANDS-1 generate
    -- Generating N_BRAMS = P_BANDS BRAM 36 kbits.
    signal data_in_even_i, data_in_odd_i, data_out_even_i, data_out_odd_i : std_logic_vector(B_RAM_BIT_WIDTH -1 downto 0);
--value read from BRAM (odd index) before writing to address
  begin
    -- Block ram row for even addresses and row indexes of the correlation matrix
    block_ram_even : entity work.block_ram
      generic map (
        B_RAM_SIZE      => B_RAM_SIZE,
        B_RAM_BIT_WIDTH => B_RAM_BIT_WIDTH)
      port map (
        clk           => clk,
        aresetn       => reset_n,
        data_in       => data_in_even_i,
        write_enable  => write_enable,
        read_enable   => read_enable,
        read_address  => read_address,
        write_address => write_address,
        data_out      => data_out_even_i);
    -- Block ram row for odd addresses and row indexes of the correlation matrix
    block_ram_odd : entity work.block_ram
      generic map (
        B_RAM_SIZE      => B_RAM_SIZE,
        B_RAM_BIT_WIDTH => B_RAM_BIT_WIDTH)
      port map (
        clk           => clk,
        aresetn       => reset_n,
        data_in       => data_in_odd_i,
        write_enable  => write_enable,
        read_enable   => read_enable,
        read_address  => read_address,
        write_address => write_address,
        data_out      => data_out_odd_i);

-- generate P_BAND write PROCESSES writes on clock cycle after 
    process(clk, clk_en, din, valid, reset_n, r_write_address, read_address, write_address, data_out_odd_i, data_out_even_i, write_done_on_row, flag_first_pixel, write_enable)
      variable a_factor_01_i                 : std_logic_vector(PIXEL_DATA_WIDTH-1 downto 0);
      variable a_factor_02_i                 : std_logic_vector(PIXEL_DATA_WIDTH-1 downto 0);
      variable b_factor_01_i                 : std_logic_vector(PIXEL_DATA_WIDTH-1 downto 0);
      variable b_factor_02_i                 : std_logic_vector(PIXEL_DATA_WIDTH-1 downto 0);
      variable v_input_even_i, v_input_odd_i : std_logic_vector(B_RAM_BIT_WIDTH-1 downto 0);  --
      variable v_data_out_prev_even_i        : std_logic_vector(PIXEL_DATA_WIDTH*2-1 downto 0);
      variable v_data_out_prev_odd_i         : std_logic_vector(PIXEL_DATA_WIDTH*2-1 downto 0);
    begin

      if rising_edge(clk) and clk_en = '1' then
        if reset_n = '0' or valid = '0' then
          a_factor_01_i := (others => '0');
          a_factor_02_i := (others => '0');
          b_factor_01_i := (others => '0');
          b_factor_02_i := (others => '0');

        elsif valid = '1' and to_integer(unsigned(write_done_on_row)) <= NUMBER_OF_WRITES_PER_ROW-1 and write_enable = '1' then  --and to_integer(unsigned(write_done_on_row)) > 0 then
          if flag_first_pixel = '0' then
            --input din is horizontal vector. A/B_factor 01 is the transposed
            --vertical element factor of the product din.' * din. A/B_factor_02 is
            --the horizontal element.
            a_factor_01_i := din(P_BANDS*PIXEL_DATA_WIDTH - ((P_BANDS- i)*PIXEL_DATA_WIDTH) + PIXEL_DATA_WIDTH-1 downto P_BANDS*PIXEL_DATA_WIDTH- ((P_BANDS- i)*PIXEL_DATA_WIDTH));
            b_factor_01_i := a_factor_01_i;
            -- "Horizontal" element
            a_factor_02_i := din(P_BANDS*PIXEL_DATA_WIDTH - (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH +PIXEL_DATA_WIDTH-1 + to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH downto P_BANDS*PIXEL_DATA_WIDTH- (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH+to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH);
            b_factor_02_i := din(P_BANDS*PIXEL_DATA_WIDTH - (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH +NUMBER_OF_WRITES_PER_CYCLE*PIXEL_DATA_WIDTH-1 + to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH downto P_BANDS*PIXEL_DATA_WIDTH- (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH+to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH +PIXEL_DATA_WIDTH);

            v_input_even_i         := std_logic_vector(to_signed(to_integer(signed(a_factor_01_i))*to_integer(signed(a_factor_02_i)), v_input_even_i'length));
            v_input_odd_i          := std_logic_vector(to_signed(to_integer(signed(b_factor_01_i))*to_integer(signed(b_factor_02_i)), v_input_odd_i'length));
            v_data_out_prev_even_i := r_dout_prev(P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE + PIXEL_DATA_WIDTH*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE);
            v_data_out_prev_odd_i  := r_dout_prev(P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE +PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE+PIXEL_DATA_WIDTH*2);
            data_in_even_i         <= std_logic_vector(to_signed(to_integer(signed(v_input_even_i))+ to_integer(signed(v_data_out_prev_even_i)), data_in_even_i'length));
            data_in_odd_i          <= std_logic_vector(to_signed(to_integer(signed(v_input_odd_i)) + to_integer(signed(v_data_out_prev_odd_i)), data_in_odd_i'length));

          elsif flag_first_pixel = '1' then
            -- special case for the first pixel written, where
            -- the data contained in the BRAM is not
            -- initialized to something known.
            --input din is horizontal vector. A/B_factor 01 is the transposed
            --vertical element factor of the product din.' * din. A/B_factor_02 is
            --the horizontal element.
            a_factor_01_i := din(P_BANDS*PIXEL_DATA_WIDTH - ((P_BANDS- i)*PIXEL_DATA_WIDTH) + PIXEL_DATA_WIDTH-1 downto P_BANDS*PIXEL_DATA_WIDTH- ((P_BANDS- i)*PIXEL_DATA_WIDTH));
            b_factor_01_i := a_factor_01_i;
            -- "Horizontal" element
            a_factor_02_i := din(P_BANDS*PIXEL_DATA_WIDTH - (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH +PIXEL_DATA_WIDTH-1 + to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH downto P_BANDS*PIXEL_DATA_WIDTH- (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH+to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH);
            b_factor_02_i := din(P_BANDS*PIXEL_DATA_WIDTH - (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH +NUMBER_OF_WRITES_PER_CYCLE*PIXEL_DATA_WIDTH-1 + to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH downto P_BANDS*PIXEL_DATA_WIDTH- (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH+to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH +PIXEL_DATA_WIDTH);

            v_input_even_i := std_logic_vector(to_signed(to_integer(signed(a_factor_01_i))*to_integer(signed(a_factor_02_i)), v_input_even_i'length));
            v_input_odd_i  := std_logic_vector(to_signed(to_integer(signed(b_factor_01_i))*to_integer(signed(b_factor_02_i)), v_input_odd_i'length));
            data_in_even_i <= v_input_even_i;
            data_in_odd_i  <= v_input_odd_i;
          end if;

        end if;
      end if;

    end process;
    dout(P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE + PIXEL_DATA_WIDTH*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE)                                              <= data_out_even_i;
    dout(P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE +PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE+PIXEL_DATA_WIDTH*2) <= data_out_odd_i;
  end generate;

  -- Register in old values of dout
  process (clk, clk_en, dout)
  begin
    if rising_edge(clk) and clk_en = '1' then
      r_dout_prev <= dout;
    end if;
  end process;



-- process to drive address and control
  process(clk, clk_en, r_write_address, write_done_on_row, reset_n, valid, flag_has_read_second, flag_has_read_first)

  begin
    if rising_edge(clk) and clk_en = '1' then
      if reset_n = '0' then             --or valid = '0' then
        r_write_address     <= 0;
        read_address        <= 0;
        write_enable        <= '0';
        read_enable         <= '1';
        write_done_on_row   <= (others => '0');
        flag_has_read_first <= '0';
        flag_first_pixel    <= '1';
      elsif valid = '0' then
        write_enable         <= '0';
        flag_has_read_first  <= '0';
        flag_has_read_second <= '0';
      elsif valid = '1' and to_integer(unsigned(write_done_on_row)) <= NUMBER_OF_WRITES_PER_ROW-1 and flag_first_pixel = '1' then
        if flag_has_read_first = '0' then
          -- Need to read first element of the pixel before starting any writes
          flag_has_read_first <= '1';
          read_address        <= r_write_address;
          write_address       <= r_write_address;
          read_enable         <= '1';
          write_enable        <= '1';
        elsif flag_has_read_first = '1' and write_enable = '1' then
          r_write_address   <= r_write_address +1;
          write_address     <= r_write_address;
          read_address      <= r_write_address+1;
          write_enable      <= '1';
          write_done_on_row <= std_logic_vector(to_unsigned(to_integer(unsigned(write_done_on_row)) + 1, write_done_on_row'length));
        end if;
      -- Going to buffer two read elements.
      elsif valid = '1' and to_integer(unsigned(write_done_on_row)) <= NUMBER_OF_WRITES_PER_ROW-1 and flag_first_pixel = '0' then
        if flag_has_read_first = '0' and flag_has_read_second = '0' then
          -- Need to read first element of the pixel before starting any writes
          flag_has_read_first <= '1';
          read_address        <= r_write_address;
          write_address       <= r_write_address;
          read_enable         <= '1';
          write_enable        <= '0';
        elsif flag_has_read_first = '1' and write_enable = '0' and flag_has_read_second = '0' then
          read_address         <= r_write_address +1;
          read_enable          <= '1';
          flag_has_read_second <= '1';
          r_read_address       <= r_read_address +1;
        end if;
        if flag_has_read_second = '1' and write_enable = '0' then
          write_address  <= r_write_address;
          read_address   <= r_write_address+2;
          write_enable   <= '1';
          r_read_address <= r_read_address +1;
        elsif flag_has_read_second = '1' and write_enable = '1' then
          r_write_address   <= r_write_address +1;
          write_address     <= r_write_address;
          read_address      <= r_read_address;
          r_read_address    <= r_read_address +1;
          write_done_on_row <= std_logic_vector(to_unsigned(to_integer(unsigned(write_done_on_row)) + 1, write_done_on_row'length));
        end if;
      elsif valid = '1' and to_integer(unsigned(write_done_on_row)) > NUMBER_OF_WRITES_PER_ROW-1 then
        -- New pixel coming on data_in input
        -- Assuming consequent pixels are hold valid, starting working on
        -- next pixel next cycle;
        if(flag_first_pixel ='0') then
        	valid_out<='1'; -- data outputted from correlation module will always "lag" one pixel
        	end if;
        r_write_address      <= 0;
        r_read_address       <= 0;
        read_address         <= 0;
        write_enable         <= '0';
        write_done_on_row    <= (others => '0');
        flag_has_read_first  <= '0';
        flag_has_read_second <= '0';
        -- Now one pixel has been finished processed, the contents of the
        -- BRAM is at least known
        flag_first_pixel     <= '0';
      end if;

    end if;
  end process;


  writes_done_on_row <= write_done_on_row;

end Behavioral;
