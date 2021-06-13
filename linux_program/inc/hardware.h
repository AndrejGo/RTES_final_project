#ifndef MY_HARDWARE_H
#define MY_HANDLERS_H

#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <sys/mman.h>
#include <unistd.h>
#include <inttypes.h>
#include <stdio.h>
#include <string.h>

#include <hps_soc_system.h>
#include <socal.h>

#define ALT_AXI_FPGASLVS_OFST (0xc0000000) // axi master base
#define HW_FPGA_AXI_SPAN (0x05000000)      // cover all of the addresses in the FPGA
#define HW_FPGA_AXI_MASK ( HW_FPGA_AXI_SPAN - 1 )

// Global variables
typedef struct global_addrs_ {
    int fd_dev_mem;
    void* h2f_axi_master;
    size_t h2f_axi_master_span;
    void* fpga_leds;
    void* gpio_0;
    void* encoder_memory;
    void* encoder;
    uint32_t codes;
    uint32_t tree_str;
    uint32_t text_src;
    uint32_t dst_addr;   
} global_addrs;
global_addrs* my_init_global_addrs();

// Memory setup
void open_physical_memory_device(global_addrs*);
void close_physical_memory_device(global_addrs*);
void mmap_fpga_peripherals(global_addrs*);
void munmap_fpga_peripherals(global_addrs*);

// LED PIO
void setup_fpga_leds(global_addrs*);
void handle_fpga_leds(global_addrs*);

// GPIO_1 PIO
void set_bit(global_addrs*, int);
void clear_bit(global_addrs*, int);

// Encoder memory functions
void print_str_from_mem(uint32_t);
void copy_str_to_mem(uint32_t, char*);
void write_codes_to_mem(global_addrs*, char**);
uint32_t str_len_mem(uint32_t);
void write_tree_to_mem(global_addrs*, char*);
void write_text_to_mem(global_addrs*, char*);

void write_addrs_to_encoder(global_addrs*);
void reset_encoder(global_addrs*);
void start_encoder(global_addrs*);
void wait_for_encoder(global_addrs*);

#endif