
#ifndef AVALON_PWM_REGS_H
#define AVALON_PWM_REGS_H

#include <io.h>
#include <stdint.h>

// Adresse relative des deux registres du PWM
#define PWM_REG_DUTY_OFST   0
#define PWM_REG_PERIOD_OFST 1

// Ecrire dans le registre du rapport cyclique
static inline void pwm_write_duty(uint32_t base, uint32_t duty)
{
    IOWR(base, PWM_REG_DUTY_OFST, duty);
}

// Ecrire dans le registre de la periode
static inline void pwm_write_period(uint32_t base, uint32_t period)
{
    IOWR(base, PWM_REG_PERIOD_OFST, period);
}

// Lire la valeur du registre du rapport cyclique
static inline uint32_t pwm_read_duty(uint32_t base)
{
    return IORD(base, PWM_REG_DUTY_OFST);
}

// Lire la valeur du registre de la periode
static inline uint32_t pwm_read_period(uint32_t base)
{
    return IORD(base, PWM_REG_PERIOD_OFST);
}

#endif
