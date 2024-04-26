#ifndef _TRNG_H_
#define _TRNG_H_

#include <stdint.h>

void get_rnd_key(uint8_t conditioning, uint32_t* Dout);
void get_rnd_key_intr(uint8_t conditioning, uint32_t* Dout);
void get_rnd_bytes_intr(size_t nbytes, uint8_t* Dout);
void get_rnd_bytes_poll(size_t nbytes, uint8_t* Dout);

#endif
