#ifndef CONN_QUEUE_H
#define CONN_QUEUE_H

typedef struct node_ {
    struct node_* next;
    int* client_socket;
} node;

void enqueue(int*);
int* dequeue();

#endif