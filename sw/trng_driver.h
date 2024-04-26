#ifndef _TRNG_H_
#define _TRNG_H_

#include <stdint.h>
//#include "core_v_mini_mcu.h"

void get_rnd_key(uint8_t conditioning, uint32_t* Dout);

#endif
