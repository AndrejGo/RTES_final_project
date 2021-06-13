#include <stdlib.h>
#include <conn_queue.h>

node* head = NULL;
node* tail = NULL;

// Add a client socket to the queue
void enqueue(int* client_socket) {
    // Create a new node
    node* new_node = malloc(sizeof(node));
    new_node->next = NULL;
    new_node->client_socket = client_socket;
    if(tail == NULL) {
        head = new_node;
    } else {
        tail->next = new_node;
    }
    tail = new_node;
}

int* dequeue() {
    if(head == NULL) {
        return NULL;
    } else {
        int* client_socket = head->client_socket;
        node* old_head = head;
        head = head->next;
        if(head == NULL) {
            tail = NULL;
        }
        free(old_head);
        return client_socket;
    }
}