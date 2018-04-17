library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.Common_types_and_functions.all;

library UNISIM;
use UNISIM.vcomponents.all;
library UNIMACRO;
use unimacro.Vcomponents.all;

--BRAM_TDP_MACRO:TrueDualPortRAM
-- 7Series
entity BRAM is

  port(
    DOA    : out std_logic_vector (31 downto 0);  --Outputport-Adata,widthdefinedbyREAD_WIDTH_Aparameter
    DOB    : out std_logic_vector (31 downto 0);  --Outputport-Bdata,widthdefinedbyREAD_WIDTH_Bparameter
    ADDRA  : in  std_logic_vector(9 downto 0);  --Inputport-Aaddress,widthdefinedbyPortAdepth
    ADDRB  : in  std_logic_vector(9 downto 0);  --Inputport-Baddress,widthdefinedbyPortBdepth
    CLKA   : in  std_logic;             --1-bitinputport-Aclock
    CLKB   : in  std_logic;             --1-bitinputport-Bclock
    DIA    : in  std_logic_vector(31 downto 0);  --Inputport-Adata,widthdefinedbyWRITE_WIDTH_Aparameter
    DIB    : in  std_logic_vector(31 downto 0);  --Inputport-Bdata,widthdefinedbyWRITE_WIDTH_Bparameter
    ENA    : in  std_logic;             --1-bitinputport-Aenable
    ENB    : in  std_logic;             --1-bitinputport-Benable
    REGCEA : in  std_logic;             --1-bitinputport-Aoutputregisterenable
    REGCEB : in  std_logic;             --1-bitinputport-Boutputregisterenable
    RSTA   : in  std_logic;             --1-bitinputport-Areset
    RSTB   : in  std_logic;             --1-bitinputport-Breset
    WEA    : in  std_logic_vector(3 downto 0);
--Inputport-Awriteenable,widthdefinedbyPortAdepth found in UG953 
    WEB    : in  std_logic_vector(3 downto 0));  --Inputport-Bwriteenable,widthdefinedbyPortBdepth
end BRAM;
architecture Behavioral of BRAM is
begin

  BRAM_TDP_MACRO_inst : BRAM_TDP_MACRO
    generic map(
      BRAM_SIZE     => "36Kb",          --TargetBRAM,"18Kb"or"36Kb"
      DEVICE        => "7SERIES",  --TargetDevice:"VIRTEX5","VIRTEX6","7SERIES","SPARTAN6"
      READ_WIDTH_A  => 32,  --Validvaluesare1-36(19-36onlyvalidwhenBRAM_SIZE="36Kb")
      READ_WIDTH_B  => 32,  --Validvaluesare1-36(19-36onlyvalidwhenBRAM_SIZE="36Kb"
      WRITE_MODE_A  => "READ_FIRST",  -- WRITE FIRST", "READ_FIRST" or "NO_CHANGE
      WRITE_MODE_B  => "READ_FIRST",  -- WRITE FIRST", "READ_FIRST" or "NO_CHANGE
      WRITE_WIDTH_A => 32,  --Validvaluesare1-36(19-36onlyvalidwhenBRAM_SIZE="36Kb")
      WRITE_WIDTH_B => 32)  --Validvaluesare1-36(19-36onlyvalidwhenBRAM_SIZE="36Kb"
    port map(
      DOA    => DOA,  --Outputport-Adata,widthdefinedbyREAD_WIDTH_Aparameter
      DOB    => DOB,  --Outputport-Bdata,widthdefinedbyREAD_WIDTH_Bparameter
      ADDRA  => ADDRA,      --Inputport-Aaddress,widthdefinedbyPortAdepth
      ADDRB  => ADDRB,      --Inputport-Baddress,widthdefinedbyPortBdepth
      CLKA   => CLKA,                   --1-bitinputport-Aclock
      CLKB   => CLKB,                   --1-bitinputport-Bclock
      DIA    => DIA,  --Inputport-Adata,widthdefinedbyWRITE_WIDTH_Aparameter
      DIB    => DIB,  --Inputport-Bdata,widthdefinedbyWRITE_WIDTH_Bparameter
      ENA    => ENA,                    --1-bitinputport-Aenable
      ENB    => ENB,                    --1-bitinputport-Benable
      REGCEA => REGCEA,                 --1-bitinputport-Aoutputregisterenable
      REGCEB => REGCEB,                 --1-bitinputport-Boutputregisterenable
      RSTA   => RSTA,                   --1-bitinputport-Areset
      RSTB   => RSTB,                   --1-bitinputport-Breset
      WEA    => WEA,  --Inputport-Awriteenable,widthdefinedbyPortAdepth
      WEB    => WEB   --Inputport-Bwriteenable,widthdefinedbyPortBdepth
      );
end Behavioral;
--EndofBRAM_TDP_MACRO_instinstantiatio
