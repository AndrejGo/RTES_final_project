#include <stdlib.h>
#include <stdio.h>
#include <handlers.h>
#include <sys/socket.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>
#include <dirent.h>
#include <huffman.h>
#include <errno.h>

#define HOMEPATH "files"

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

// Main handler
void handler(global_addrs* addrs, int* client_socket) {
    int connection_fd = *client_socket;
    if(connection_fd < 0) {
        printf("Error bad connection\n");
    }

    request* req = NULL;
    response* res = NULL;

    char* buffer = malloc(65536 * sizeof(char));
    if(buffer == NULL) {
        printf("Error allocating buffer for request\n");
        server_err_handler(client_socket, req, res);
    } else {
        int len_received = recv(connection_fd, buffer, 65535, 0);
        if(len_received < 0) {
            printf("Error receiving message\n");
            server_err_handler(client_socket, req, res);
        } else if(len_received == 0) {
            close(connection_fd);
        } else {
            req = parse_request(buffer);
            free(buffer);
            req->client_socket = connection_fd;

            res = calloc(1, sizeof(response));

            char* req_path = strdup(req->url);
            char* hardware_param;
            char* url = strtok_r(req_path, "?", &hardware_param);
            switch(req->method) {
            case GET:
                // Check if requesting a .txt file
                if(strcmp(url + strlen(url) - 4, ".txt") == 0) {

                    char* file_path = url;
                    while(*file_path != '/') {
                        file_path++;
                    }
                    char* path = strdup(file_path);

                    unsigned char* compressed;

                    if(strcmp(hardware_param, "hardware") == 0) {
                        // Compress with hardware acceleration
                        compressed = hw_compress(addrs, path);
                    } else {
                        // Regular compression
                        compressed = compress(addrs, path);
                    }
                    unsigned int* size = (unsigned int*)compressed;

                    res->status = 200;
                    res->header_head = NULL;
                    res->header_tail = NULL;

                    add_header_to_response(res, "Content-Type", "application/octet-stream");

                    char* file_name_temp = url + strlen(url) - 1;
                    while(*file_name_temp != '/') {
                        file_name_temp--;
                    }
                    file_name_temp++;
                    char* file_name = strdup(file_name_temp);
                    file_name[strlen(file_name) - 4] = 0;
                    char file_name_header[512];
                    if(strcmp(hardware_param, "hardware") == 0) {
                        sprintf(file_name_header, "attachment; filename=%s_hw.hfc", file_name);
                    } else {
                        sprintf(file_name_header, "attachment; filename=%s.hfc", file_name);
                    }
                    add_header_to_response(res, "Content-Disposition", file_name_header);

                    char* length_num = malloc(100 * sizeof(char));
                    sprintf(length_num, "%u", *size);
                    add_header_to_response(res, "Content-Length", length_num);

                    // Prepare a response without a body
                    unsigned char* res_str = response_to_string(res);

                    int prev_len = strlen(res_str);

                    memcpy(res_str + strlen(res_str), compressed, *size);

                    int len_sent = send(req->client_socket, res_str, prev_len + *size, 0);
                    if(len_sent < 0) {
                        printf("Error sending message: %d\n", errno);
                    }

                    free(compressed);
                    close(req->client_socket);
                    free_req(req);
                    free_res(res);

                } else {
                    get_handler(req, res);
                    char* res_str = response_to_string(res);
                    if(res_str == NULL) {
                        printf("Error transforming response to string\n");
                        server_err_handler(client_socket, req, res);
                    } else {
                        int len_sent = send(req->client_socket, res_str, strlen(res_str), 0);
                        if(len_sent < 0) {
                            printf("Error sending message: %d\n", errno);
                        }

                        close(req->client_socket);
                        free_req(req);
                        free_res(res);
                    }
                }
                break;
            default:
                server_err_handler(client_socket, req, res);
                break;
            }
        }
    }
}

char* compress(global_addrs* addrs, char* file_name) {
    char full_path[512];
    sprintf(full_path, "%s%s", HOMEPATH, file_name);

    // Open file
    FILE* example_file = fopen(full_path, "r");
    if(example_file == NULL) {
        printf("Error opening input file: %d\n", errno);
        return NULL;
    }

    // Get the number of characters (bytes) in the file
    fseek(example_file, 0, SEEK_END);
    unsigned int file_size = ftell(example_file);
    fseek(example_file, 0, SEEK_SET);

    // Read the file contents into text
    char* text = malloc(file_size * sizeof(char));
    fread(text, sizeof(char), file_size, example_file);

    set_bit(addrs, 2);

    // Compute the frequency of each character
    int* frequencies = (int*)calloc(56, sizeof(int));
    prepare_frequencies(text, letters, frequencies);

    // Do Huffman encoding
    char** codes = (char**)malloc(56 * sizeof(char*));
    int size = sizeof(letters) / sizeof(letters[0]);
    char* str_rep = HuffmanCodes(letters, frequencies, size, codes);

    clear_bit(addrs, 2);

    set_bit(addrs, 1);

    // Prepare encoded file headers
    unsigned int header_len = strlen(str_rep);
    unsigned int uncompressed_len = file_size;

    unsigned char* encoded_data = (char*)calloc(65536, sizeof(char));

    memcpy(encoded_data + 4, &header_len, sizeof(header_len));
    memcpy(encoded_data + 8, &uncompressed_len, sizeof(uncompressed_len));

    // Write the Huffman tree representation
    memcpy(encoded_data + 12, str_rep, header_len);

    // Write the bytes using Huffman encoding
    int written = 0;
    char* working_string = (char*)calloc(64, sizeof(char));
    int offset = 0;
    char* str8 = (char*)calloc(9, sizeof(char));
    for(int i = 0; i < file_size; i++) {
        // Find the index of the letter we are encoding
        int j;
        for(j = 0; j < 56; j++) {
            if(text[i] == letters[j]) {
                break;
            }
        }
        // Add the code of the letter to the working string
        strcpy(working_string + offset, codes[j]);
        offset += strlen(codes[j]);
        // While the working string contains at least 8 characters, we can convert
        // them into a byte and write them to the buffer
        while(strlen(working_string) >= 8) {
            memcpy(str8, working_string, 8);
            unsigned char b = str_to_byte(str8);
            memcpy(encoded_data + 12 + header_len + written, &b, 1);
            written++;
            strcpy(working_string, working_string+8);
            offset -= 8;
        }
    }
    // Check if we have any bits left over and pad if necessary
    if(strlen(working_string) > 0) {
        char* padded = (char*)calloc(8, sizeof(char));
        strcpy(padded, working_string);
        unsigned char b = str_to_byte(padded);
        memcpy(encoded_data + 12 + header_len + written, &b, 1);
        written++;
    }
    unsigned int total_len = 12 + header_len + written;
    memcpy(encoded_data, &total_len, sizeof(total_len));

    clear_bit(addrs, 1);

    return encoded_data;
}

char* hw_compress(global_addrs* addrs, char* file_name) {
    char full_path[512];
    sprintf(full_path, "%s%s", HOMEPATH, file_name);

    // Open file
    FILE* example_file = fopen(full_path, "r");
    if(example_file == NULL) {
        printf("Error opening input file: %d\n", errno);
        return NULL;
    }

    // Get the number of characters (bytes) in the file
    fseek(example_file, 0, SEEK_END);
    unsigned int file_size = ftell(example_file);
    fseek(example_file, 0, SEEK_SET);

    // Read the file contents into text
    char* text = malloc(file_size * sizeof(char));
    fread(text, sizeof(char), file_size, example_file);

    // Compute the frequency of each character
    int* frequencies = (int*)calloc(56, sizeof(int));
    prepare_frequencies(text, letters, frequencies);

    // Do Huffman encoding
    char** codes = (char**)malloc(56 * sizeof(char*));
    int size = sizeof(letters) / sizeof(letters[0]);
    char* str_rep = HuffmanCodes(letters, frequencies, size, codes);

    set_bit(addrs, 0);

    write_codes_to_mem(addrs, codes);
    write_tree_to_mem(addrs, str_rep);
    write_text_to_mem(addrs, text);
    write_addrs_to_encoder(addrs);
    reset_encoder(addrs);
    start_encoder(addrs);
    wait_for_encoder(addrs);

    uint32_t total_len = alt_read_word(addrs->dst_addr);

    unsigned char* encoded = (char*)calloc(total_len, sizeof(unsigned char));
    for(int i = 0; i < total_len; i++) {
        encoded[i] = alt_read_byte(addrs->dst_addr + i);
    }

    clear_bit(addrs, 0);

    return encoded;
}

void get_handler(request* req, response* res) {
    if(strcmp(req->url, "/style.css") == 0) {
        style_handler(req, res);
    } else if(strcmp(req->url, "/favicon.ico") == 0) {
        // Do nothing
    } else {
        index_handler(req, res, req->url);
    }
}

void index_handler(request* req, response* res, char* path) {
    FILE* index_file = fopen("html/index.html", "r");
    if(index_file == NULL) {
        printf("Error opening index file: %d\n", errno);
        return;
    } 

    res->status = 200;
    res->header_head = NULL;
    res->header_tail = NULL;

    // Get the number of characters (bytes) in the file
    fseek(index_file, 0, SEEK_END);
    int size = ftell(index_file);
    fseek(index_file, 0, SEEK_SET);

    add_header_to_response(res, "Content-Type", "text/html");

    char* index_html = malloc((size+1) * sizeof(char));
    fread(index_html, sizeof(char), size, index_file);
    index_html[size] = '\0';
    res->body = add_items(path, index_html);

    char* length_num = malloc(100 * sizeof(char));
    sprintf(length_num, "%d", strlen(res->body));
    add_header_to_response(res, "Content-Length", length_num);
    free(length_num);

    free(index_html);
    fclose(index_file);
}

char* add_items(char* path, char* html) {
    char* tail;
    char* working_str = (char*)calloc(16384, sizeof(char*));
    strcpy(working_str, strtok_r(html, "?", &tail));

    // Up one folder button
    char* path_copy = strdup(path);
    char* rem_path;
    char* path_segment = strtok_r(path_copy, "/", &rem_path);
    while(path_segment != NULL) {
        strcat(working_str, "/");
        if(strlen(rem_path) > 0) {
            strcat(working_str, path_segment);
        }
        path_segment = strtok_r(NULL, "/", &rem_path);
    }

    // Next static section of HTML
    strcat(working_str, strtok_r(NULL, "?", &tail));

    // Path string
    strcat(working_str, path);

    // Remainder of page
    strcat(working_str, strtok_r(NULL, "?", &tail));

    DIR* d;
    struct dirent* dir;
    char full_path[512];
    sprintf(full_path, "%s%s", HOMEPATH, path);
    d = opendir(full_path);
    if(d) {
        char item_string[2048];
        char link_path[512];
        while (1) {
            dir = readdir(d);
            if(dir == NULL) {
                break;
            }
            if(memcmp(dir->d_name, ".", 1)) {
                if(strcmp(path, "/") == 0) {
                    sprintf(link_path, "%s%s", path, dir->d_name);
                } else {
                    sprintf(link_path, "%s/%s", path, dir->d_name);
                }
                if(dir->d_type == DT_DIR) {
                    sprintf(item_string, "<a class=\"folder-item\" href=\"%s\">&#x1F4C1; %s</a>\n", link_path, dir->d_name);
                    strcat(working_str, item_string);
                } else {
                    sprintf(item_string, "<div class=\"file-item\"><a class=\"sw-dl-btn\" href=\"%s\">&#8664;</a><a class=\"hw-dl-btn\" href=\"%s?hardware\">&#8664;</a>&#x1F4C3; %s</div>\n", link_path, link_path, dir->d_name);
                    strcat(working_str, item_string);
                }
            };
        };
        closedir(d);
    }
    strcat(working_str, tail);
    return working_str;
}

void style_handler(request* req, response* res) {
    FILE* style_file = fopen("html/style.css", "r");
    if(style_file == NULL) {
        printf("Error opening index file: %d\n", errno);
        return;
    }

    // Get the number of characters (bytes) in the file
    fseek(style_file, 0, SEEK_END);
    int size = ftell(style_file);
    fseek(style_file, 0, SEEK_SET);

    char* style_text = malloc(size * sizeof(char));
    fread(style_text, sizeof(char), size, style_file);

    res->status = 200;
    res->header_head = NULL;
    res->header_tail = NULL;

    add_header_to_response(res, "Content-Type", "text/css");

    char* length_num = malloc(100 * sizeof(char));
    sprintf(length_num, "%d", size);
    add_header_to_response(res, "Content-Length", length_num);
    free(length_num);

    res->body = style_text;

    fclose(style_file);
}

request* parse_request(char* request_string) {
    request* req = calloc(1, sizeof(request));
    if(req == NULL) {
        return req;
    }

    char* working_string = strdup(request_string);
    char* state1;
    char* method = strtok_r(working_string, " ", &state1);
    if(strcmp(method, "GET") == 0) {
        req->method = GET;
    } else if(strcmp(method, "POST") == 0) {
        req->method = POST;
    } else {
        printf("Error, unsupported request method\n");
        // Turn the reqest into a GET for an error page
        return req;
    }

    req->url = strdup(strtok_r(NULL, " ", &state1));

    strtok_r(NULL, "\r\n", &state1);
    char* line = strtok_r(NULL, "\r\n", &state1);

    char* state2;
    while(line != NULL) {
        char* key = strdup(strtok_r(line, ":", &state2));
        char* value = strdup(strtok_r(NULL, " ", &state2));

        add_header_to_request(req, key, value);

        if(strlen(state1) > 1) {
            if(state1[1] == 10 || state1[1] == 13) {
                break;
            }
        }
        line = strtok_r(NULL, "\r\n", &state1);
    }

    if(strlen(state1) <= 2) {
        req->body = NULL;
    } else {
        req->body = strdup(state1 + 2);
    }

    free(working_string);

    return req;
}

void add_header_to_request(request* req, char* key, char* value) {
    header* h = (header*)calloc(1, sizeof(header));
    h->key = key;
    h->value = value;
    if(req->header_head == NULL) {
        req->header_head = h;
    } else {
        req->header_tail->next = h;
    }
    req->header_tail = h;
}

void add_header_to_response(response* res, char* key, char* value) {
    header* h = (header*)calloc(1, sizeof(header));
    h->key = strdup(key);
    h->value = strdup(value);
    if(res->header_head == NULL) {
        res->header_head = h;
    } else {
        res->header_tail->next = h;
    }
    res->header_tail = h;
}

char* response_to_string(response* res) {
    char* buffer = malloc(65536 * sizeof(char));
    if(buffer == NULL) {
        printf("Malloc failed\n");
        exit(EXIT_FAILURE);
    }

    sprintf(buffer, "HTTP/1.1 %d OK\n", res->status);
    header* curr = res->header_head;
    while(curr != NULL) {
        sprintf(buffer, "%s%s: %s\n", buffer, curr->key, curr->value);
        curr = curr->next;
    }
    if(res->body != NULL) {
        sprintf(buffer, "%s\n%s", buffer, res->body);
    }
    strcat(buffer, "\n");
    return buffer;
}

void free_headers(header* head) {
    header* temp;
    while(head) {
        temp = head->next;
        free(head);
        head = temp;
    }
}

void free_req(request* req) {
    free_headers(req->header_head);
    free(req->url);
    free(req->body);
    free(req);
}

void free_res(response* res) {
    free_headers(res->header_head);
    free(res->body);
    free(res);
}

void server_err_handler(int* client_socket, request* req, response* res) {
    char* response = "HTTP/1.1 500 Internal Server Error\nContent-Type: text/plain\nContent-Length: 33\n\nThere was an error on the server.";
    int len_sent = send(*client_socket, response, strlen(response), 0);
    if(len_sent < 0) {
        printf("Error sending error message: %d\n", errno);
    }

    close(*client_socket);
    free(client_socket);
    if(res) {
        free_res(res);
    }
    if(req) {
        free_req(req);
    }
}
