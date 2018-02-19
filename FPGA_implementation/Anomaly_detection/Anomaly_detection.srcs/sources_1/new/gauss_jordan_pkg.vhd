----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/17/2018 11:57:08 AM
-- Design Name: 
-- Module Name: gauss_jordan_pkg - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
-- This is a package containing constants and types used by the gauss_jordan_inverse module


package gauss_jordan_pkg is

constant STATE_IDLE_DRIVE :                       		std_logic_vector(1 downto 0) :="00";
constant STATE_FORWARD_ELIMINATION_FINISHED :        	std_logic_vector(1 downto 0) :="01";
constant STATE_BACKWARD_ELIMINATION_FINISHED:      		std_logic_vector(1 downto 0) :="10";
constant STATE_IDENTITY_MATRIX_BUILDING_FINISHED:    	std_logic_vector(1 downto 0) :="11";

type state_type is (STATE_IDLE, STATE_FORWARD_ELIMINATION, STATE_BACKWARD_ELIMINATION, STATE_IDENTITY_MATRIX_BUILDING);

type reg_state_type is record
    state : state_type;
    drive : std_logic_vector(1 downto 0);
    end record;

end gauss_jordan_pkg;

