----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/29/2018 12:31:59 PM
-- Design Name: 
-- Module Name: common_types_and_functions - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

package Common_types_and_functions is 
    -- N_PIXELS is the number of pixels in the hyperspectral image
    constant N_PIXELS : integer;
    -- P_BANDS  is the number of spectral bands
    constant P_BANDS :  integer;
    -- K is size of the kernel used in LRX. 
    constant K :        integer;
    --constant pixel_data_size is std_logic_vector(11 downto 0);
    --type pixel_vector is array (0 to 100 -1) of std_logic_vector(pixel_data_size downto 0);
    --generic ( N_PIXELS: integer := 2578;
    --          P_BANDS : integer := 100);
    --assuming pixel_data_size is 16 bit;          
    type matrix is array (  natural range <> , natural range <>) of std_logic_vector(15 downto 0);
     -- for correlation results
    type matrix_32 is array (  natural range <> , natural range <>) of std_logic_vector(31 downto 0);
    function log2(i : natural) return integer;
    function sel (n : natural) return integer;
    
    type matrix_reg_type is record
        matrix :        matrix_32 (0 to P_BANDS-1 ,0 to P_BANDS-1);
        matrix_inv :    matrix_32 (0 to P_BANDS-1 ,0 to P_BANDS-1);
    end record;

end Common_types_and_functions;

package body Common_types_and_functions is 
    -- Found in SmallSat project description:
    --constant N_PIXELS : integer := 2578;
    --constant P_BANDS :  integer := 100;
    constant N_PIXELS : integer := 3;
    constant P_BANDS :  integer := 3;
     
    constant K      :   integer := 0;

       
    function log2( i : natural) return integer is
        variable temp    : integer := i;
        variable ret_val : integer := 0; 
      begin                    
        while (temp > 1) loop
          ret_val := ret_val + 1;
          temp    := temp / 2;     
        end loop;
          
        return ret_val;
      end function; 
      
    function sel( n : natural ) return integer is       
        begin
        return n;
    end function;

    
    
end Common_types_and_functions;
