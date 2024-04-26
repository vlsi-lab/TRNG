#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>

#include "trng_keccak_x_heep.h"
#include "core_v_mini_mcu.h"
#include "trng_driver.h"
#include "trng_keccak_ctrl_auto.h"
#include "trng_keccak_data_auto.h"

#include "stats.h"

// To manage interrupt
#include "csr.h"
#include "rv_plic.h"
#include "rv_plic_regs.h"
#include "rv_plic_structs.h"
#include "hart.h"

// To manage DMA
#include "dma.h"


void get_rnd_key(uint8_t conditioning, uint32_t* Dout)
{
    uint32_t volatile *ctrl_reg = (uint32_t*) KECCAK_CTRL_START_ADDR;
    uint32_t volatile *Dout_reg = (uint32_t*) KECCAK_DOUT_START_ADDR;
    uint32_t volatile *status_reg = (uint32_t*) KECCAK_STATUS_START_ADDR;
    uint8_t volatile key_ready;
    // Performance regs variables
	unsigned int volatile cycles = 0;
    
    // Starting the performance counter
    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    CSR_WRITE(CSR_REG_MCYCLE, 0);

    // trigger 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 1 << TRNG_KECCAK_CTRL_CTRL_TRNG_EN_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_TRNG_EN_BIT;

    if (conditioning)
        *ctrl_reg = 1 << TRNG_KECCAK_CTRL_CTRL_CONDITIONING_BIT;
    else
        *ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_CONDITIONING_BIT;
    
    // poll
    do {
        key_ready = (*status_reg) & (1 << TRNG_KECCAK_CTRL_STATUS_TRNG_BIT);
    } while (key_ready == 0);
  
    // get key
    *Dout = Dout_reg[50];

    // acknowledge key
    *ctrl_reg = 1 << TRNG_KECCAK_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_KECCAK_CTRL_CTRL_ACK_KEY_READ_BIT;
    
    // stop the HW counter used for monitoring
    CSR_READ(CSR_REG_MCYCLE, &cycles);
    printf("\nNumber of clock cycles to generate the key - polling: %d\n", cycles);
}

