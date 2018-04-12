library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;

-- Correlation module with AXI lite stream interface
entity acad_correlation is
  port(din     : in  std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH-1 downto 0);  --
                                        --Horizontal
                                        --input vector
       valid   : in  std_logic;
       clk     : in  std_logic;
       clk_en  : in  std_logic;
       reset_n : in  std_logic;
       dout    : out std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH*2*2 -1 downto
                                   0);  -- writing two 32-bit elements per cycle
       writes_done_on_row : out std_logic_vector(log2(P_BANDS/2) downto 0)
       );
end acad_correlation;

architecture Behavioral of acad_correlation is
  --signal r, r_in                               : std_logic_vector(63 downto 0);
  --signal din_transpose                         : std_logic_vector (P_BANDS*PIXEL_DATA_WIDTH-1 downto 0);
  constant N_BRAMS                             : integer range 0 to P_BANDS   := P_BANDS;
  constant NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM : integer range 0 to 2         := 2;  -- using True dual port BRAM
  --constant EXPECTED_CLK_BRAM_UPDATE_TIME       : integer                                             := P_BANDS * P_BANDS/(NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM * N_BRAMS);
  --constant EXPECTED_CLK_BRAM_UPDATE_TIME       : integer range 0 to  := P_BANDS * P_BANDS/(2);
  constant NUMBER_OF_WRITES_PER_ROW            : integer range 0 to P_BANDS/2 := P_BANDS/2;

  signal r_address_counter : std_logic_vector (BRAM_TDP_ADDRESS_WIDTH-1 downto 0) := (others => '0');
  --signal input_a, input_b                      : std_logic_vector(31 downto 0);
  -- signal DIA, DIB                              : std_logic_vector(31 downto 0);
  signal index_vert_vector : std_logic_vector(log2(P_BANDS) downto 0)             := (others => '0');  -- index for controlling element using for writing
  signal write_done_on_row : std_logic_vector (log2(P_BANDS/2) downto 0)          := (others => '0');
  signal RST               : std_logic;
  signal ADDRA             : std_logic_vector(BRAM_TDP_ADDRESS_WIDTH-1 downto 0)  := (others => '0');
-- width defined in TDP spec
  signal ADDRB             : std_logic_vector(BRAM_TDP_ADDRESS_WIDTH-1 downto 0)  := "0000000001";
  signal ADDRA_temp        : std_logic_vector(BRAM_TDP_ADDRESS_WIDTH-1 downto 0)  := (others => '0');
  signal ADDRB_temp        : std_logic_vector(BRAM_TDP_ADDRESS_WIDTH-1 downto 0)  := "0000000001";
  --signal DOA                                   : std_logic_vector(31 downto 0);
  --signal DOB                                   : std_logic_vector(31 downto 0);




begin

  -- BRAM_1 : entity work.BRAM
  --   port map (
  --     DOA    => DOA,
  --     DOB    => DOB,
  --     ADDRA  => ADDRA,
  --     ADDRB  => ADDRB,
  --     CLKA   => clk,
  --     CLKB   => clk,
  --     DIA    => DIA,
  --     DIB    => DIB,
  --     ENA    => valid,
  --     ENB    => valid,
  --     REGCEA => clk_en,
  --     REGCEB => clk_en,
  --     RSTA   => RST,
  --     RSTB   => RST,
  --     WEA    => (others => '1'),
  --     WEB    => (others => '1'));
  --WEB    => (others => clk_en));

---- generating P_BANDS number of DOUT and DIN signals to/from the different BRAMs
--  gen_DIN_DOUT : for i in 0 to P_BANDS-1 generate
--    signal DOA_i, DOB_i, DIA_i, DIB_i : std_logic_vector(31 downto 0);
--  begin
--  end generate;
---- generating P_BANDS number of input_a and input_b signals
--  gen : for i in 0 to P_BANDS-1 generate
--    signal input_a_i, input_b_i : std_logic_vector(31 downto 0);
--  begin
--  end generate;



--  process(clk, clk_en, din, valid)
--    variable a_factor_01 : std_logic_vector(PIXEL_DATA_WIDTH-1 downto 0);
--    variable a_factor_02 : std_logic_vector(PIXEL_DATA_WIDTH-1 downto 0);
--    variable b_factor_01 : std_logic_vector(PIXEL_DATA_WIDTH-1 downto 0);
--    variable b_factor_02 : std_logic_vector(PIXEL_DATA_WIDTH-1 downto 0);
--    variable v_address   : std_logic_vector(9 downto 0);
--  begin
--
--    if rising_edge(clk) and reset_n = '0' then
--      a_factor_01       := (others => '0');
--      a_factor_02       := (others => '0');
--      b_factor_01       := (others => '0');
--      b_factor_02       := (others => '0');
--      index_vert_vector <= (others => '0');
--      write_done_on_row <= (others => '0');
--      r_address_counter <= (others => '0');
--    elsif rising_edge(clk) and clk_en = '1' and to_integer(unsigned(write_done_on_row)) <= NUMBER_OF_WRITES_PER_ROW-1 and valid = '1' then
--      --input din is horizontal vector. A/B_factor 01 is the transposed
--      --vertical element factor of the product din.' * din. A/B_factor_02 is
--      --the horizontal element.
--      v_address   := r_address_counter;
--      a_factor_01 := din(P_BANDS*PIXEL_DATA_WIDTH - ((P_BANDS- to_integer(unsigned(index_vert_vector)))*PIXEL_DATA_WIDTH) + PIXEL_DATA_WIDTH-1 downto P_BANDS*PIXEL_DATA_WIDTH- ((P_BANDS- to_integer(unsigned(index_vert_vector)))*PIXEL_DATA_WIDTH));
--      -- "Horizontal" element
--      a_factor_02 := din(P_BANDS*PIXEL_DATA_WIDTH - (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH +PIXEL_DATA_WIDTH-1 + to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH downto P_BANDS*PIXEL_DATA_WIDTH- (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH+to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH);
--
--      b_factor_01 := a_factor_01;
--      --"Horizontal" element
--      b_factor_02 := din(P_BANDS*PIXEL_DATA_WIDTH - (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH +NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM*PIXEL_DATA_WIDTH-1 + to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH downto P_BANDS*PIXEL_DATA_WIDTH- (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH+to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH +PIXEL_DATA_WIDTH);
--
--      input_a           <= std_logic_vector(to_signed(to_integer(signed(a_factor_01))*to_integer(signed(a_factor_02)), input_a'length));
--      input_b           <= std_logic_vector(to_signed(to_integer(signed(b_factor_01))*to_integer(signed(b_factor_02)), input_b'length));
--      write_done_on_row <= std_logic_vector(to_unsigned(to_integer(unsigned(write_done_on_row)) + 1, write_done_on_row'length));
--      ADDRA_temp        <= v_address;
--      ADDRB_temp        <= std_logic_vector(to_unsigned(to_integer(unsigned(v_address)) + 1, ADDRB_temp'length));
--      -- Increasing the address by two for each write
--      r_address_counter <= std_logic_vector(to_unsigned(to_integer(unsigned(r_address_counter))+2, r_address_counter'length));
--
--    elsif rising_edge(clk) and clk_en = '1' and to_integer(unsigned(write_done_on_row)) >= NUMBER_OF_WRITES_PER_ROW and to_integer(unsigned(index_vert_vector)) < P_BANDS-1 then
--      -- start next row calculation. Similar logic if increasing number of BRAM.
--      index_vert_vector <= std_logic_vector(to_unsigned(to_integer(unsigned(index_vert_vector)) +1, index_vert_vector'length));
--      write_done_on_row <= (others => '0');
--      r_address_counter <= std_logic_vector(to_unsigned(to_integer(unsigned(r_address_counter))+2, r_address_counter'length));
--
--    end if;
--  end process;

                                        -- input to BRAM
  --DIA <= input_a;
  --DIB <= input_b;


  gen_BRAM_updates : for i in 0 to P_BANDS-1 generate
    -- Generating N_BRAMS = P_BANDS BRAMS.
    signal DOA_i, DOB_i, DIA_i, DIB_i : std_logic_vector(31 downto 0);
    signal input_a_i, input_b_i       : std_logic_vector(31 downto 0);
  begin
    BRAM : entity work.BRAM
      port map(
        DOA    => DOA_i,
        DOB    => DOB_i,
        ADDRA  => ADDRA,
        ADDRB  => ADDRB,
        CLKA   => clk,
        CLKB   => clk,
        DIA    => DIA_i,
        DIB    => DIB_i,
        ENA    => valid,
        ENB    => valid,
        REGCEA => clk_en,
        REGCEB => clk_en,
        RSTA   => RST,
        RSTB   => RST,
        WEA    => (others => '1'),
        WEB    => (others => '1'));
  --WEB    => (others => clk_en));

-- generate P_BAND PROCESSES
    process(clk, clk_en, din, valid)
      variable a_factor_01_i : std_logic_vector(PIXEL_DATA_WIDTH-1 downto 0);
      variable a_factor_02_i : std_logic_vector(PIXEL_DATA_WIDTH-1 downto 0);
      variable b_factor_01_i : std_logic_vector(PIXEL_DATA_WIDTH-1 downto 0);
      variable b_factor_02_i : std_logic_vector(PIXEL_DATA_WIDTH-1 downto 0);
      variable v_address     : std_logic_vector(9 downto 0);
    begin

      if rising_edge(clk) and clk_en = '1' then
        if reset_n = '0' then
          a_factor_01_i     := (others => '0');
          a_factor_02_i     := (others => '0');
          b_factor_01_i     := (others => '0');
          b_factor_02_i     := (others => '0');
          index_vert_vector <= (others => '0');
          write_done_on_row <= (others => '0');
          r_address_counter <= (others => '0');
        elsif to_integer(unsigned(write_done_on_row)) <= NUMBER_OF_WRITES_PER_ROW-1 and valid = '1' then
          --input din is horizontal vector. A/B_factor 01 is the transposed
          --vertical element factor of the product din.' * din. A/B_factor_02 is
          --the horizontal element.
          v_address     := r_address_counter;
          a_factor_01_i := din(P_BANDS*PIXEL_DATA_WIDTH - ((P_BANDS- i)*PIXEL_DATA_WIDTH) + PIXEL_DATA_WIDTH-1 downto P_BANDS*PIXEL_DATA_WIDTH- ((P_BANDS- i)*PIXEL_DATA_WIDTH));
          -- "Horizontal" element
          a_factor_02_i := din(P_BANDS*PIXEL_DATA_WIDTH - (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH +PIXEL_DATA_WIDTH-1 + to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH downto P_BANDS*PIXEL_DATA_WIDTH- (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH+to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH);

          b_factor_01_i := a_factor_01_i;
          --"Horizontal" element
          b_factor_02_i := din(P_BANDS*PIXEL_DATA_WIDTH - (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH +NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM*PIXEL_DATA_WIDTH-1 + to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH downto P_BANDS*PIXEL_DATA_WIDTH- (P_BANDS- to_integer(unsigned(write_done_on_row)))*PIXEL_DATA_WIDTH+to_integer(unsigned(write_done_on_row))*PIXEL_DATA_WIDTH +PIXEL_DATA_WIDTH);

          input_a_i         <= std_logic_vector(to_signed(to_integer(signed(a_factor_01_i))*to_integer(signed(a_factor_02_i)), input_a_i'length));
          input_b_i         <= std_logic_vector(to_signed(to_integer(signed(b_factor_01_i))*to_integer(signed(b_factor_02_i)), input_b_i'length));
          write_done_on_row <= std_logic_vector(to_unsigned(to_integer(unsigned(write_done_on_row)) + 1, write_done_on_row'length));
          ADDRA_temp        <= v_address;
          ADDRB_temp        <= std_logic_vector(to_unsigned(to_integer(unsigned(v_address)) + 1, ADDRB_temp'length));
          -- Increasing the address by two for each write
          r_address_counter <= std_logic_vector(to_unsigned(to_integer(unsigned(r_address_counter))+2, r_address_counter'length));

          --elsif to_integer(unsigned(write_done_on_row)) >= NUMBER_OF_WRITES_PER_ROW and to_integer(unsigned(index_vert_vector)) < P_BANDS-1 then
          --  -- start next row calculation. Similar logic if increasing number of BRAM.
          --  index_vert_vector <= std_logic_vector(to_unsigned(to_integer(unsigned(index_vert_vector)) +1, index_vert_vector'length));
          --  write_done_on_row <= (others => '0');
          --  r_address_counter <= std_logic_vector(to_unsigned(to_integer(unsigned(r_address_counter))+2, r_address_counter'length));

        end if;
      end if;
    end process;
    DIA_i                                                                                                                                                                                                                                                                                                                                                            <= input_a_i;
    DIB_i                                                                                                                                                                                                                                                                                                                                                            <= input_b_i;
    dout(P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM + PIXEL_DATA_WIDTH*2-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM)                                                        <= DOA_i;
    dout(P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM + PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM-1 downto P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM+PIXEL_DATA_WIDTH*2) <= DOB_i;
  --dout(P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM-(P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM + PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM -1
  -- downto P_BANDS*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM - (P_BANDS-i)*PIXEL_DATA_WIDTH*2*NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM + PIXEL_DATA_WIDTH*2*) <= DOB_i;
  end generate;

  ADDRA <= ADDRA_temp;
  ADDRB <= ADDRB_temp;
  RST   <= not(reset_n);
  writes_done_on_row <= write_done_on_row;



end Behavioral;
