library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;

-- Correlation module with AXI lite stream interface
entity acad_correlation is
  port(din    : in std_logic_vector(P_BANDS*PIXEL_DATA_WIDTH-1 downto 0);
       valid  : in std_logic;
       clk    : in std_logic;
       clk_en : in std_logic
       );
end acad_correlation;

architecture Behavioral of acad_correlation is
  signal r, r_in                               : std_logic_vector(63 downto 0);
  signal din_transpose                         : std_logic_vector (P_BANDS*PIXEL_DATA_WIDTH-1 downto 0);
  constant N_BRAMS                             : integer                                             := 1;
  constant NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM : integer                                             := 2;  -- using True dual port BRAM
  --constant EXPECTED_CLK_BRAM_UPDATE_TIME       : integer                                             := P_BANDS * P_BANDS/(NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM * N_BRAMS);
  constant EXPECTED_CLK_BRAM_UPDATE_TIME       : integer                                             := P_BANDS * P_BANDS/(2);
  signal r_address_counter                     : std_logic_vector (log2(P_BANDS*P_BANDS)-1 downto 0) := (others => '0');
  signal input_a, input_b                      : std_logic_vector(32 downto 0);
  signal DIA, DIB                              : std_logic_vector(32 downto 0);
  signal index_j                               : integer                                             := 0;
  --constant NUMBER_OF_WRITES_PER_ROW : integer := P_BANDS/NUMBER_OF_WRITES_PER_CYCLE_PER_BRAM*N_BRAMS; 
  constant NUMBER_OF_WRITES_PER_ROW            : integer                                             := P_BANDS/2;
  signal                                       : write_done_on_row : std_logic_vector (log2(P_BANDS/2) downto 0);
-- transpose of the input vector
-- Some kind of address counter
begin

  BRAM_1 : entity work.BRAM
    port map (
      DOA    => DOA,
      DOB    => DOB,
      ADDRA  => ADDRA,
      ADDRB  => ADDRB,
      CLKA   => clk,
      CLKB   => clk,
      DIA    => DIA,
      DIB    => DIB,
      ENA    => valid,
      ENB    => valid,
      REGCEA => clk_en,
      REGCEB => clk_en,
      RSTA   => not(reset_n),
      RSTB   => not(reset_n),
      WEA    => clk_en,
      WEB    => clk_en);

-- use DSP slice to implement vector multiplication?

--  process
--  begin
--    for i in 0 to P_BANDS*PIXEL_DATA_WIDTH-1 loop
--
--    end process;

  process(clk, clk_en, din, valid)
  begin

    if(rising_edge(clk) and reset_n = '1' then
         input_a <= (others => '0');
         input_b <= (others => '0');

       elsif rising_edge(clk) and clk_en = '1' then
         input_a <=

       end if;
         end process;

         DIA <= input_a;
         DIB <= input_b;


--    comb_process : process(din, valid)
--      variable v : std_logic_vector(63 downto 0);
--    begin
--      v    := M_TDATA;
--      r_in <= v;
--
--
--    end process;
--
--
--    sequential_process : process(clk, clk_en)
--    begin
--      if(rising_edge(clk) and clk_en = '1') then
--        r <= r_in;
--      end if;
--    end process;



         end Behavioral;
