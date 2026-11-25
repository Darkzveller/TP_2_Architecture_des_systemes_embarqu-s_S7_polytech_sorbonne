
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_level is
  port (
    -- Clock
    MAX10_CLK1_50 : in std_logic;

    -- Keys / Switches
    KEY : in std_logic_vector(1 downto 0);
    SW  : in std_logic_vector(9 downto 0);

    -- LEDs
    LEDR : out std_logic_vector(9 downto 0);

    -- 7-segments (actif bas)
    HEX0 : out std_logic_vector(6 downto 0);
    HEX1 : out std_logic_vector(6 downto 0);
    HEX2 : out std_logic_vector(6 downto 0);
    HEX3 : out std_logic_vector(6 downto 0);
    HEX4 : out std_logic_vector(6 downto 0);
    HEX5 : out std_logic_vector(6 downto 0)
  );
end entity;

architecture rtl of top_level is

  component nios2_system is
    port (
      clk_clk       : in std_logic := 'X';
      reset_reset_n : in std_logic := 'X';

      led_external_connection_export :
      out std_logic_vector(9 downto 0);

      sw_external_connection_export :
      in std_logic_vector(9 downto 0) := (others => 'X');

      key_external_connection_export :
      in std_logic_vector(1 downto 0) := (others => 'X');

      pwm01_output : out std_logic;

      hex3_0_external_connection_export :
      out std_logic_vector(31 downto 0);

      hex5_4_external_connection_export :
      out std_logic_vector(15 downto 0)
    );
  end component;

  signal reset_n : std_logic;
  signal hex3_0  : std_logic_vector(31 downto 0);
  signal hex5_4  : std_logic_vector(15 downto 0);

begin

  reset_n <= KEY(0);

  -- Instance du systeme Nios II
  u0 : component nios2_system
    port map
    (
      clk_clk       => MAX10_CLK1_50,
      reset_reset_n => reset_n,

      -- LEDs classiques
      led_external_connection_export(8 downto 0)=> LEDR(8 downto 0),

      led_external_connection_export(9) => open,

      -- LED commandee par le PWM
      pwm01_output => LEDR(9),

      -- Switches et boutons
      sw_external_connection_export  => SW,
      key_external_connection_export => KEY,

      -- Afficheurs 7 segments
      hex3_0_external_connection_export => hex3_0,
      hex5_4_external_connection_export => hex5_4
    );

    -- Unpacking des afficheurs 7 segments
    HEX0 <= hex3_0(6 downto 0);
    HEX1 <= hex3_0(14 downto 8);
    HEX2 <= hex3_0(22 downto 16);
    HEX3 <= hex3_0(30 downto 24);
    HEX4 <= hex5_4(6 downto 0);
    HEX5 <= hex5_4(14 downto 8);

  end architecture;
