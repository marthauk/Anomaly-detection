
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;

-- The toppermost level for Adaptive Causal anomaly detection(ACAD).
-- This entity is AXI4-LITE compatible

entity top_d_acad is
  port(M_TDATA  : in  std_logic_vector (63 downto 0);  -- input pixel data from
                                                       -- cube DMA
       M_TVALID : in  std_logic;        -- handshake axi lite signal
       clk : in std_logic;
       clk_en : in std_logic;
       reset_n : in std_logic;
       S_TREADY : out std_logic        -- handshake axi lite signal
    );
end top_d_acad;


architecture Behavioral of top_d_acad is
signal shift_counter

begin
  -- Shiftregister for shifting in data from cube DMA.
  shiftregister_four_pixels_1: entity work.shiftregister_four_pixels
    port map (
      din           => M_TDATA,
      valid         => M_TVALID,
      clk           => clk,
      clk_en        => clk_en,
      reset_n       => reset_n,
      shift_counter => shift_counter,
      dout          => dout);

end Behavioral;
