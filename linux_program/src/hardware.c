#include <hardware.h>

global_addrs* my_init_global_addrs() {
    global_addrs* addrs = (global_addrs*)malloc(1 * sizeof(global_addrs));

    addrs->fd_dev_mem           = 0;
    addrs->h2f_axi_master       = NULL;
    addrs->h2f_axi_master_span  = HW_FPGA_AXI_SPAN;
    addrs->fpga_leds            = NULL;
    addrs->gpio_0               = NULL;
    addrs->encoder_memory       = NULL;
    addrs->encoder              = NULL;
    addrs->codes                = 0;
    addrs->tree_str             = 0;
    addrs->text_src             = 0;
    addrs->dst_addr             = 0; 

    return addrs;
}

void open_physical_memory_device(global_addrs* addrs) {
    addrs->fd_dev_mem = open("/dev/mem", O_RDWR | O_SYNC);
    if(addrs->fd_dev_mem  == -1) {
        printf("ERROR: could not open \"/dev/mem\".\n");
        printf("    errno = %s\n", strerror(errno));
        exit(EXIT_FAILURE);
    }
}

void close_physical_memory_device(global_addrs* addrs) {
    close(addrs->fd_dev_mem);
}

void mmap_fpga_peripherals(global_addrs* addrs) {
    addrs->h2f_axi_master = mmap(NULL, addrs->h2f_axi_master_span, PROT_READ | PROT_WRITE, MAP_SHARED, addrs->fd_dev_mem, ALT_AXI_FPGASLVS_OFST);
    if(addrs->h2f_axi_master == MAP_FAILED) {
        printf("Error: h2f_axi_master mmap() failed.\n");
        printf("    errno = %s\n", strerror(errno));
        close(addrs->fd_dev_mem);
        exit(EXIT_FAILURE);
    }

    addrs->fpga_leds      = addrs->h2f_axi_master + LED_PIO_BASE;
    addrs->gpio_0         = addrs->h2f_axi_master + GPIO_PIO_BASE;
    addrs->encoder_memory = addrs->h2f_axi_master + SDRAM_CONTROLLER_0_BASE;
    addrs->encoder        = addrs->h2f_axi_master + ENCODER_0_BASE;
}

void munmap_fpga_peripherals(global_addrs* addrs) {
    if (munmap(addrs->h2f_axi_master, addrs->h2f_axi_master_span) != 0) {
        printf("Error: h2f_axi_master munmap() failed\n");
        printf("    errno = %s\n", strerror(errno));
        close(addrs->fd_dev_mem);
        exit(EXIT_FAILURE);
    }

    addrs->h2f_axi_master = NULL;
    addrs->fpga_leds      = NULL;
    addrs->gpio_0         = NULL;
    addrs->encoder_memory = NULL;
    addrs->encoder        = NULL;
}

void setup_fpga_leds(global_addrs* addrs) {
    alt_write_word(addrs->fpga_leds, 0x1);
}

int dir = 1;
void handle_fpga_leds(global_addrs* addrs) {
    uint32_t leds_mask = alt_read_word(addrs->fpga_leds);

    if(dir) {
        // Left
        if(leds_mask != (0x01 << (LED_PIO_DATA_WIDTH - 1))) {
            // rotate leds
            leds_mask <<= 1;
        } else {
            dir = 0;
        }
    } else {
        // Right
        if(leds_mask != 0x01) {
            // rotate leds
            leds_mask >>= 1;
        } else {
            dir = 1;
        }
    }

    alt_write_word(addrs->fpga_leds, leds_mask);
}

void set_bit(global_addrs* addrs, int index) {
    alt_write_word(addrs->gpio_0 + 16, 1 << index);
}

void clear_bit(global_addrs* addrs, int index) {
    alt_write_word(addrs->gpio_0 + 20, 1 << index);
}

void print_str_from_mem(uint32_t src) {
    uint32_t i = 0;
    while(i < (1 << 26)) {
        uint8_t c = alt_read_byte(src + i);
        if(c == 0) {
            break;
        }
        printf("%c", c);
        i++;
    }
    printf("\n");
}

void copy_str_to_mem(uint32_t dst, char* str) {
    uint32_t i = 0;
	while(i < (1 << 26)) {
		alt_write_byte(dst + i, str[i]);
		if(str[i] == 0) {
			break;
		}
		i++;
	}
}

void write_codes_to_mem(global_addrs* addrs, char** cds) {
    // Codes are at the start of the FPGA SDRAM
	addrs->codes = (uint32_t)addrs->encoder_memory;

	uint32_t code_1 = addrs->codes + 256;
    copy_str_to_mem(code_1, cds[0]);
	alt_write_word(addrs->codes, code_1 - (uint32_t)addrs->encoder_memory);
	for(int i = 1; i < 56; i++) {
		uint32_t prev = alt_read_word(addrs->codes + 4*(i-1)) + (uint32_t)addrs->encoder_memory;
		uint32_t code_2 = prev + str_len_mem(prev) + 1;
		copy_str_to_mem(code_2, cds[i]);
		alt_write_word(addrs->codes + i*4, code_2 - (uint32_t)addrs->encoder_memory);
	}
}

uint32_t str_len_mem(uint32_t src) {
    uint32_t i = 0;
	while(alt_read_byte(src + i) != 0) {
		i++;
	}
	return i;
}

void write_tree_to_mem(global_addrs* addrs, char* tree) {
    // The tree comes after all of the codes
	uint32_t last_code_addr = alt_read_word(addrs->codes + 55*4) + (uint32_t)addrs->encoder_memory;
	addrs->tree_str = last_code_addr + str_len_mem(last_code_addr) + 4;
    copy_str_to_mem(addrs->tree_str, tree);
}

void write_text_to_mem(global_addrs* addrs, char* text) {
    // The src text comes after the tree
	addrs->text_src = addrs->tree_str + str_len_mem(addrs->tree_str) + 4;
	copy_str_to_mem(addrs->text_src, text);
    addrs->dst_addr = addrs->text_src + str_len_mem(addrs->text_src) + 4;
}

void write_addrs_to_encoder(global_addrs* addrs) {
    alt_write_word(addrs->encoder, addrs->codes - (uint32_t)addrs->encoder_memory);
    alt_write_word(addrs->encoder+4, addrs->tree_str - (uint32_t)addrs->encoder_memory);
    alt_write_word(addrs->encoder+8, addrs->text_src - (uint32_t)addrs->encoder_memory);
    alt_write_word(addrs->encoder+12, addrs->dst_addr - (uint32_t)addrs->encoder_memory);
}

void reset_encoder(global_addrs* addrs) {
    alt_write_word(addrs->encoder+16, 0x1);
}

void start_encoder(global_addrs* addrs) {
    alt_write_word(addrs->encoder+16, 0x2);
}

void wait_for_encoder(global_addrs* addrs) {
    while(1) {
        uint32_t done = alt_read_word(addrs->encoder+20);
        if(done) {
            break;
        }
    }
}