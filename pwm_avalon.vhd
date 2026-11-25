library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity avalon_pwm is
  port (
    clk     : in std_logic;
    reset_n : in std_logic;
    -- Avalon-MM slave (registre addressing)
    avs_s0_address   : in std_logic; -- 0: DUTY, 1: PERIOD
    avs_s0_write     : in std_logic;
    avs_s0_writedata : in std_logic_vector(31 downto 0);
    avs_s0_read      : in std_logic;
    avs_s0_readdata  : out std_logic_vector(31 downto 0);
    -- PWM output
    pwm_led : out std_logic
  );
end entity;
architecture rtl of avalon_pwm is
  signal duty_reg   : unsigned(31 downto 0) := (others => '0');
  signal period_reg : unsigned(31 downto 0) := to_unsigned(99999, 32); -- défaut : à adapter
  signal counter    : unsigned(31 downto 0) := (others => '0');
begin
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      duty_reg   <= (others => '0');
      period_reg <= to_unsigned(99999, 32);
      counter    <= (others => '0');
    elsif rising_edge(clk) then
      -- Écritures Avalon
      if avs_s0_write = '1' then
        if avs_s0_address = '0' then
          duty_reg <= unsigned(avs_s0_writedata);
        else
          period_reg <= unsigned(avs_s0_writedata);
          -- Optionnel : si on change la période, on remet le compteur à 0
          counter <= (others => '0');
        end if;
      end if;
      -- Compteur PWM : 0..period_reg puis reset
      -- Cas limite: period_reg = 0 -> PWM dégénéré (counter reste 0)
      if period_reg = 0 then
        counter <= (others => '0');
      else
        if counter >= period_reg then
          counter <= (others => '0');
        else
          counter <= counter + 1;
        end if;
      end if;
    end if;
  end process;
  -- Sortie PWM, comparateur
  pwm_led <= '1' when (counter < duty_reg) else
    '0';
  -- Lecture Avalon (readback registres)
  process (avs_s0_address, duty_reg, period_reg)
  begin
    if avs_s0_address = '0' then
      avs_s0_readdata <= std_logic_vector(duty_reg);
    else
      avs_s0_readdata <= std_logic_vector(period_reg);
    end if;
  end process;
end architecture;