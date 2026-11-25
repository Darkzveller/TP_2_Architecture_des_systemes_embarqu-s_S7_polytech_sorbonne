/*
 * "Hello World" example.
 *
 * This example prints 'Hello from Nios II' to the STDOUT stream. It runs on
 * the Nios II 'standard', 'full_featured', 'fast', and 'low_cost' example
 * designs. It runs with or without the MicroC/OS-II RTOS and requires a STDOUT
 * device in your system's hardware.
 * The memory footprint of this hosted application is ~69 kbytes by default
 * using the standard reference design.
 *
 * For a reduced footprint version of this template, and an explanation of how
 * to reduce the memory footprint for a given application, see the
 * "small_hello_world" template.
 *
 */

// #include <stdio.h>

// int main()
// {
//   printf("pipi!\n");

//   return 0;
// }

#include <stdio.h>
#include <stdlib.h>
#include "avalon_pwm_regs.h"
#include "system.h"
int main()
{
  int rx_char;
  printf("Application - PWM\n");
  printf("\nEnter intensity LED between 1 and 4 (0 to exit)\n");
  pwm_write_period(PWM0_BASE, 0xFF);
  pwm_write_duty(PWM0_BASE, 0xFF);
  while (1)
  {
    rx_char = getc(stdin);
    switch (rx_char)
    {
    case '4':
      pwm_write_duty(PWM0_BASE, 0xFF);
      printf("Intensity level 4\n");
      break;
    case '3':
      pwm_write_duty(PWM0_BASE, 0x80);
      printf("Intensity level 3\n");
      break;
    case '2':
      pwm_write_duty(PWM0_BASE, 0x30);
      printf("Intensity level 2\n");
      break;
    case '1':
      pwm_write_duty(PWM0_BASE, 0x10);
      printf("Intensity level 1\n");
      break;
    case '0':
      printf("\nBye bye ...\n");
      return 0;
      break;
    default:
      printf("Enter intensity LED between 1 and 4\n");
      break;
    }
  }
  return 0;
}
