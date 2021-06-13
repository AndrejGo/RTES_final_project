#include <stdlib.h>
#include <stdio.h>
#include "huffman.h"
#include <errno.h>
#include <string.h>

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
    
    if(argc < 3) {
        printf("Usage: compress <path-to-input> <path-to-output>\n");
        return 0;
    }

    // ================================================================ //
    // Open file
    FILE* example_file = fopen(argv[1], "r");
    if(example_file == NULL) {
        printf("Error opening input file: %d\n", errno);
        exit(EXIT_FAILURE);
    }

    // Get the number of characters (bytes) in the file
    fseek(example_file, 0, SEEK_END);
    unsigned int file_size = ftell(example_file);
    fseek(example_file, 0, SEEK_SET);

    // Read the file contents into text
    char* text = malloc(file_size * sizeof(char));
    fread(text, sizeof(char), file_size, example_file);

    // ================================================================ //
    // Compute the frequency of each character
    int* frequencies = (int*)calloc(56, sizeof(int));
    prepare_frequencies(text, letters, frequencies);

    // Do Huffman encoding
    char** codes = (char**)malloc(56 * sizeof(char*));
    int size = sizeof(letters) / sizeof(letters[0]);
    char* str_rep = HuffmanCodes(letters, frequencies, size, codes);

    FILE* output_file = fopen(argv[2], "wb");
    if(output_file == NULL) {
        printf("Error opening output file: %d\n", errno);
        exit(EXIT_FAILURE);
    }

    unsigned int header_len = strlen(str_rep);
    unsigned int uncompressed_len = file_size;
    unsigned int total_len = 0;

    // Write the three lengths at the start
    fwrite(&total_len, sizeof(total_len), 1, output_file);
    fwrite(&header_len, sizeof(header_len), 1, output_file);
    fwrite(&uncompressed_len, sizeof(uncompressed_len), 1, output_file);

    // Write the Huffman tree representation
    fwrite(str_rep, header_len, 1, output_file);

    // Write the bytes using Huffman encoding
    int written = 0;
    char* working_string = (char*)calloc(64, sizeof(char));
    int offset = 0;
    char* str8 = (char*)calloc(9, sizeof(char));
    for(int i = 0; i < file_size; i++) {
        // Find the index of the letter we are encoding
        int l = -1;
        int j;
        for(j = 0; j < 56; j++) {
            if(text[i] == letters[j]) {
                l = j;
                break;
            }
        }
        if(l == -1) {
            printf("Invalid character %c\n", text[i]);
            return 0;
        }

        strcpy(working_string + offset, codes[j]);
        offset += strlen(codes[j]);
        while(strlen(working_string) >= 8) {
            memcpy(str8, working_string, 8);
            unsigned char b = str_to_byte(str8);
            fwrite(&b, sizeof(unsigned char), 1, output_file);
            written++;
            strcpy(working_string, working_string+8);
            offset -= 8;
        }
    }
    if(strlen(working_string) > 0) {
        char* padded = (char*)calloc(8, sizeof(char));
        strcpy(padded, working_string);
        unsigned char b = str_to_byte(padded);
        fwrite(&b, sizeof(unsigned char), 1, output_file);
        written++;
    }

    fseek(output_file, 0, SEEK_SET);
    total_len = 12 + header_len + written;
    fwrite(&total_len, sizeof(total_len), 1, output_file);

    fclose(output_file);

    return 0;
}