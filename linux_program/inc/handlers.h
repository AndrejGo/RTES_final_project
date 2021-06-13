#ifndef HANDLERS_H
#define HANDLERS_H

#include <hardware.h>

#define GET 0
#define POST 1

typedef struct header_ {
    char* key;
    char* value;
    struct header_* next;
} header;

typedef struct request_ {
    int client_socket;
    int method;
    char* url;
    char* body;
    header* header_head;
    header* header_tail;
} request;

typedef struct response_ {
    int status;
    header* header_head;
    header* header_tail;
    char* body;
} response;

void handler(global_addrs*, int*);
void add_header_to_request(request*, char*, char*);
request* parse_request(char*);
void get_handler(request*, response*);
void index_handler(request*, response*, char*);
void server_err_handler(int*, request*, response*);
void style_handler(request*, response*);
char* add_items(char*, char*);
void add_header_to_response(response*, char*, char*);
char* response_to_string(response*);
void free_headers(header*);
void free_req(request*);
void free_res(response*);

char* compress(global_addrs*, char*);
char* hw_compress(global_addrs*, char*);

#endif