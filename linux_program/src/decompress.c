#include <stdlib.h>
#include <stdio.h>
#include "huffman.h"
#include <errno.h>

char letters[] = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
    'Y', 'Z', 
    'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h',
    'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
    'q', 'r', 's', 't', 'u', 'v', 'w', 'x',
    'y', 'z', 
    ' ', ',', '.', '\n'
};

int main(int argc, char* argv[]) {

    if(argc < 2) {
        printf("Usage: decompress <path-to-file>\n");
        return 0;
    }

    // ================================================================ //
    // Open file
    FILE* input_file = fopen(argv[1], "rb");
    if(input_file == NULL) {
        printf("Error opening input file: %d\n", errno);
        exit(EXIT_FAILURE);
    }

    // Read the three numbers
    unsigned int header_len;
    unsigned int uncompressed_len;
    unsigned int total_len;

    fread(&total_len, sizeof(total_len), 1, input_file);
    fread(&header_len, sizeof(header_len), 1, input_file);
    fread(&uncompressed_len, sizeof(uncompressed_len), 1, input_file);

    // Read the tree representation string
    char* tree_string = (char*)calloc(header_len, sizeof(char));
    fread(tree_string, header_len, 1, input_file);

    HF_Node* rebuilt = rebuild_tree(tree_string);

    char** codes = (char**)malloc(56 * sizeof(char*));
    int arr[256];
    int top = 0;
    get_codes(rebuilt, arr, top, letters, codes);

    char* uncompressed_string = (char*)malloc((uncompressed_len+1) * sizeof(char));
    int uncomp_str_index = 0;
    char* working_string = (char*)calloc(64, sizeof(char));
    int offset = 0;
    unsigned char b;
    for(int i = 0; i < total_len - 12 - header_len; i++) {
        fread(&b, sizeof(unsigned char), 1, input_file);

        strcpy(working_string + offset, byte_to_str(b));
        offset += 8;

        int matches = 1;
        while(matches) {
            matches = 0;
            for(int j = 0; j < 56; j++) {
                if(memcmp(working_string, codes[j], strlen(codes[j])) == 0) {
                    matches = 1;

                    uncompressed_string[uncomp_str_index] = letters[j];
                    uncomp_str_index++;
                    strcpy(working_string, working_string + strlen(codes[j]));
                    offset -= strlen(codes[j]);
                }
            }
        }
    }
    uncompressed_string[uncompressed_len] = '\0';

    printf("%s\n", uncompressed_string);

    return 0;
}