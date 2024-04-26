#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>

#include "trng_x_heep.h"
#include "core_v_mini_mcu.h"
#include "trng_driver_solo.h"
#include "trng_ctrl_auto.h"
#include "trng_data_auto.h"

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
    uint32_t volatile *ctrl_reg = (uint32_t*) TRNG_CTRL_START_ADDR;
    uint32_t volatile *Dout_reg = (uint32_t*) TRNG_DOUT_START_ADDR;
    uint32_t volatile *status_reg = (uint32_t*) TRNG_STATUS_START_ADDR;
    uint8_t volatile key_ready;
    // Performance regs variables
    unsigned int volatile cycles = 0;
    
    // Starting the performance counter
    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    CSR_WRITE(CSR_REG_MCYCLE, 0);

    // trigger 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 1 << TRNG_CTRL_CTRL_TRNG_EN_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_TRNG_EN_BIT;

    // poll
    do {
        key_ready = (*status_reg) & (1 << TRNG_CTRL_STATUS_TRNG_BIT);
    } while (key_ready == 0);
  
    // get key
    *Dout = Dout_reg[0];

    // acknowledge key
    *ctrl_reg = 1 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    
    // stop the HW counter used for monitoring
    CSR_READ(CSR_REG_MCYCLE, &cycles);
    printf("\nNumber of clock cycles to generate the key - polling: %d\n", cycles);
}

void get_rnd_key_intr(uint8_t conditioning, uint32_t* Dout)
{
    uint32_t volatile *ctrl_reg = (uint32_t*) TRNG_CTRL_START_ADDR;
    uint32_t volatile *Dout_reg = (uint32_t*) TRNG_DOUT_START_ADDR;
    uint32_t volatile *status_reg = (uint32_t*) TRNG_STATUS_START_ADDR;
    uint8_t volatile key_ready;
    // Performance regs variables
    unsigned int volatile cycles = 0;

    // Interrupt 
    plic_Init();     
    plic_irq_set_priority(EXT_INTR_0, 1);
    plic_irq_set_enabled(EXT_INTR_0, kPlicToggleEnabled);

    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    CSR_WRITE(CSR_REG_MCYCLE, 0);
    CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
    // Set mie.MEIE bit to one to enable machine-level external interrupts
    const uint32_t mask = 1 << 11;//IRQ_EXT_ENABLE_OFFSET;
    CSR_SET_BITS(CSR_REG_MIE, mask);

    // trigger 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 1 << TRNG_CTRL_CTRL_TRNG_EN_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_TRNG_EN_BIT;
    
    while(plic_intr_flag==0) {
        wait_for_interrupt();
    }
    
    // get key
    *Dout = Dout_reg[0];
    *ctrl_reg = 1 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    
    CSR_READ(CSR_REG_MCYCLE, &cycles);
    printf("\nNumber of clock cycles to generate the key - interrupt: %d\n", cycles);
}


void get_rnd_bytes_poll(size_t nbytes, uint8_t *Dout)
{
    uint32_t volatile *ctrl_reg = (uint32_t*) TRNG_CTRL_START_ADDR;
    uint32_t volatile *Dout_reg = (uint32_t*) TRNG_DOUT_START_ADDR;
    uint32_t volatile *status_reg = (uint32_t*) TRNG_STATUS_START_ADDR;
    uint8_t volatile key_ready;
    // Performance regs variables
    unsigned int volatile cycles = 0;
    
    // Starting the performance counter
    //CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    //CSR_WRITE(CSR_REG_MCYCLE, 0);

    // trigger 
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 1 << TRNG_CTRL_CTRL_TRNG_EN_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_TRNG_EN_BIT;

    // poll
    uint32_t mask = 0x000000FF;
    for(int i = 0; i < nbytes; i=i+4){
        asm volatile ("": : : "memory");
        *ctrl_reg = 0 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
        asm volatile ("": : : "memory");
        do {
            key_ready = (*status_reg) & (1 << TRNG_CTRL_STATUS_TRNG_BIT);
        } while (key_ready == 0);

        for(int j = 0; j < 4; j++)
         Dout[i+j] = (Dout_reg[0] >> (j<<3)) & mask;
        
        *ctrl_reg = 1 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    }
}

void get_rnd_bytes_intr(size_t nbytes, uint8_t* Dout)
{
    uint32_t volatile *ctrl_reg = (uint32_t*) TRNG_CTRL_START_ADDR;
    uint32_t volatile *Dout_reg = (uint32_t*) TRNG_DOUT_START_ADDR;
    uint32_t volatile *status_reg = (uint32_t*) TRNG_STATUS_START_ADDR;
    uint8_t volatile key_ready;
    // Performance regs variables
    unsigned int volatile cycles = 0;

    // Interrupt 
    plic_Init();     
    plic_irq_set_priority(EXT_INTR_0, 1);
    plic_irq_set_enabled(EXT_INTR_0, kPlicToggleEnabled);

    CSR_CLEAR_BITS(CSR_REG_MCOUNTINHIBIT, 0x1);
    CSR_WRITE(CSR_REG_MCYCLE, 0);
    CSR_SET_BITS(CSR_REG_MSTATUS, 0x8);
    // Set mie.MEIE bit to one to enable machine-level external interrupts
    const uint32_t mask = 1 << 11;//IRQ_EXT_ENABLE_OFFSET;
    CSR_SET_BITS(CSR_REG_MIE, mask);

    
    asm volatile ("": : : "memory");
    *ctrl_reg = 1 << TRNG_CTRL_CTRL_TRNG_EN_BIT;
    asm volatile ("": : : "memory");
    *ctrl_reg = 0 << TRNG_CTRL_CTRL_TRNG_EN_BIT;
    
    uint32_t mask_bits = 0x000000FF;
    for(int i = 0; i < nbytes; i=i+4){
        asm volatile ("": : : "memory");
        *ctrl_reg = 0 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
        asm volatile ("": : : "memory");

        while(plic_intr_flag==0) {
            wait_for_interrupt();
        }
        for(int j = 0; j < 4; j++)
         Dout[i+j] = (Dout_reg[0] >> (j<<3)) & mask_bits;
        
        *ctrl_reg = 1 << TRNG_CTRL_CTRL_ACK_KEY_READ_BIT;
    }
    
    CSR_READ(CSR_REG_MCYCLE, &cycles);
    printf("\nNumber of clock cycles to generate the key - interrupt: %d\n", cycles);
}
