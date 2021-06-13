#include <stdlib.h>
#include <stdio.h>
#include <string.h>

typedef struct hf_node {
    char letter;
    int frequency;
    struct hf_node* left;
    struct hf_node* right;
} HF_Node;

typedef struct hf_heap {
    int size;
    int capacity;
    HF_Node** array;
} HF_Heap;

// Create a new heap node
HF_Node* new_HF_Node(char letter, int frequency) {
    HF_Node* new_node = (HF_Node*)malloc(sizeof(HF_Node));
    new_node->letter = letter;
    new_node->frequency = frequency;
    new_node->left = NULL;
    new_node->right = NULL;
    return new_node;
}

// Create a new heap
HF_Heap* new_HF_Heap(int capacity) {
    HF_Heap* new_heap = (HF_Heap*)malloc(sizeof(HF_Heap));
    new_heap->size = 0;
    new_heap->capacity = capacity;
    new_heap->array = (HF_Node**)malloc(capacity * sizeof(HF_Node*));
    return new_heap;
}

void swap_HF_Nodes(HF_Node** a, HF_Node** b) {
    HF_Node* temp = *a;
    *a = *b;
    *b = temp;
}

// Turn a parent node and two children nodes into a valid heap
// assuming that the children are themselves valid heaps.
// Can be used to transform an array into a heap.
void heapify(HF_Heap* heap, int index) {
    // Assume that the parent is the smallest
    int smallest = index;
    int left_index = 2 * index + 1;
    int right_index = 2 * index + 2;

    // Find the smallest among the three nodes in question
    // (parent, left child, right child)
    if( left_index < heap->size &&
        heap->array[left_index]->frequency < heap->array[smallest]->frequency) {
        smallest = left_index;
    }
    if( right_index < heap->size &&
        heap->array[right_index]->frequency < heap->array[smallest]->frequency) {
        smallest = right_index;
    }

    // If the parent is not the smallest, swap the nodes and fix the heap 
    if(smallest != index) {
        swap_HF_Nodes(&(heap->array[smallest]), &(heap->array[index]));
        heapify(heap, smallest);
    }
}

int is_size_one(HF_Heap* heap) {
    return heap->size == 1;
}

HF_Node* pop(HF_Heap* heap) {
    // The root contains the smallest node
    HF_Node* temp = heap->array[0];

    // Insert the last leaf in the root and fix the heap
    heap->array[0] = heap->array[heap->size -1];
    heap->size--;
    heapify(heap, 0);

    return temp;
}

void push(HF_Heap* heap, HF_Node* new_node) {
    if(heap->size == heap->capacity) {
        printf("Cannot insert, heap already full\n");
        return;
    }

    heap->size++;
    int i = heap->size - 1;

    // (i-1) / 2 is the index of the parent node
    while(i && new_node->frequency < heap->array[(i-1) / 2]->frequency) {
        // As long as the new node is smaller, keep pushing it's parents
        // down, making room for the new smallest node.
        heap->array[i] = heap->array[(i-1) / 2];
        i = (i-1) / 2;
    }

    heap->array[i] = new_node;
}

void build_heap(HF_Heap* heap) {
    int n = heap->size - 1;

    // Start at the last parent and fix the heap
    for(int i = (n-1) / 2; i >= 0; i--) {
        heapify(heap, i);
    }
}

HF_Heap* create_HF_Heap(char data[], int frequencies[], int size) {

    HF_Heap* heap = new_HF_Heap(size);

    for(int i = 0; i < size; i++) {
        heap->array[i] = new_HF_Node(data[i], frequencies[i]);
    }

    heap->size = size;
    build_heap(heap);

    return heap;
}

// HUFFMAN TREE FUNCIONS
HF_Node* build_HF_Tree(char data[], int frequencies[], int size) {

    HF_Heap* heap = create_HF_Heap(data, frequencies, size);

    HF_Node* left;
    HF_Node* right;
    HF_Node* top;
    while(!is_size_one(heap)) {
        left = pop(heap);
        right = pop(heap);

        top = new_HF_Node('$', left->frequency + right->frequency);
        top->left = left;
        top->right = right;

        push(heap, top);
    }

    return heap->array[0];
}

int is_leaf(HF_Node* node) {
    return node->left == NULL && node->right == NULL;
}

void get_codes(HF_Node* root, int arr[], int top, char data[], char** codes) {
    if(root->left) {
        arr[top] = 0;
        get_codes(root->left, arr, top+1, data, codes);
    }

    if(root->right) {
        arr[top] = 1;
        get_codes(root->right, arr, top+1, data, codes);
    }

    if(is_leaf(root)) {
        int i;
        for(i = 0; i < 56; i++) {
            if(data[i] == root->letter) {
                break;
            }
        }
        char* code = calloc(top+1, sizeof(char));
        for(int j = 0; j < top; j++) {
            sprintf(code, "%s%d", code, arr[j]);
        }
        codes[i] = code;
    }
}

void HF_tree_to_string(HF_Node* node, char* str, int* i) {
    if(node) {
        if(is_leaf(node)) {
            str[*i] = '1';
            str[(*i)+1] = node->letter;
            *i += 2;
        } else {
            HF_tree_to_string(node->left, str, i);
            HF_tree_to_string(node->right, str, i);
            str[*i] = '0';
            *i += 1;
        }
    }
}

char* HuffmanCodes(char data[], int frequencies[], int size, char** codes) {
    HF_Node* root = build_HF_Tree(data, frequencies, size);
    int arr[256];
    int top = 0;
    get_codes(root, arr, top, data, codes);

    char* str_rep = calloc(256, sizeof(char));
    int i = 0;
    HF_tree_to_string(root, str_rep, &i);
    return str_rep;
}

void prepare_frequencies(char* text, char letters[], int frequencies[]) {

    for(int i = 0; i < 56; i++) {
        frequencies[i] = 0;
    }

    int index = 0;
    char current_letter = text[index];
    while(current_letter != '\0') {
        int freq_index;
        for(freq_index = 0; freq_index < 56; freq_index++) {
            if(current_letter == letters[freq_index]) {
                break;
            }
        }
        frequencies[freq_index]++;

        index++;
        current_letter = text[index];
    }
}

HF_Node* rebuild_tree(char* str_rep) {

    HF_Node** node_stack = (HF_Node**)calloc(112, sizeof(HF_Node*));
    int node_stack_index = 0;

    int string_index = 0;
    while(str_rep[string_index] != '\0') {
        if(str_rep[string_index] == '1') {
            // Create a new leaf node
            HF_Node* new_node = (HF_Node*)calloc(1, sizeof(HF_Node));
            new_node->letter = str_rep[string_index+1];
            // Push the node to the stack
            node_stack[node_stack_index] = new_node;
            node_stack_index++;
            string_index += 2;
        } else {
            HF_Node* new_node = (HF_Node*)calloc(1, sizeof(HF_Node));
            new_node->letter = '$';
            node_stack_index--;
            new_node->right = node_stack[node_stack_index];
            node_stack_index--;
            new_node->left = node_stack[node_stack_index];
            node_stack[node_stack_index] = new_node;
            node_stack_index++;
            string_index += 1;
        }
    }

    return node_stack[0];
}

unsigned char str_to_byte(char* str) {
    unsigned char res = 0;
    for(int i = 0; i < 8; i++) {
        res = res * 2;
        if(str[i] == '1') {
            res++;
        }
    }
    return res;
}

char* byte_to_str(unsigned char b) {
    char* res = calloc(9, sizeof(char));
    for(unsigned char i = 0; i < 8; i++) {
        if(b & (1 << i)) {
            res[7-i] = '1';
        } else {
            res[7-i] = '0';
        }
    }
    return res;
}