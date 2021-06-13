#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct pq_node {
    char* letters;
    int frequency;
    struct pq_node* next;
} PQ_Node;

PQ_Node* newNode(char* l, int f) {
    PQ_Node* n = (PQ_Node*)malloc(sizeof(PQ_Node));
    n->letters = strdup(l);
    n->frequency = f;
    n->next = NULL;

    return n;
}

PQ_Node* peek(PQ_Node** head) {
    return *head;
}

void pop(PQ_Node** head) {
    PQ_Node* temp = *head;
    *head = (*head)->next;
    free(temp);
}

void push(PQ_Node** head, char* l, int f) {
    PQ_Node* curr = (*head);

    PQ_Node* new_node = newNode(l, f);

    if(curr->frequency > new_node->frequency) {
        new_node->next = curr;
        *head = new_node;
    } else {
        while(curr->next != NULL && curr->next->frequency < new_node->frequency) {
            curr = curr->next;
        }
        new_node->next = curr->next;
        curr->next = new_node;
    }
}

int isEmpty(PQ_Node** head) {
    return *head == NULL;
}