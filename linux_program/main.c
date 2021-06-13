#include <stdlib.h>
#include <stdio.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>
#include <unistd.h>
#include <errno.h>
#include <pthread.h>
#include <conn_queue.h>
#include <handlers.h>
#include <time.h>

#define PORT 8080
#define MAX_CONN 10
#define THREAD_COUNT 10
#define DEBUG 1

pthread_t thread_pool[THREAD_COUNT];
pthread_mutex_t queue_mutex;

global_addrs* addrs = NULL;

void* common_thread_function(void* arg) {
    while(1) {
        pthread_mutex_lock(&queue_mutex);
        int* client_socket = dequeue();
        pthread_mutex_unlock(&queue_mutex);
        if(client_socket != NULL) {
            handler(addrs, client_socket);
        }
    }
}

void* led_function(void* arg) {
    setup_fpga_leds(addrs);
    int counter = 0;
    while(1) {
        if(counter % 9 == 0) {
            counter = 0;
            usleep(5000);
        } else {
            usleep(50000);
        }
        counter++;
        handle_fpga_leds(addrs);
    }
}

int main() {

    // Populate thread pool
    for(int i = 0; i < THREAD_COUNT; i++) {
        if(pthread_create(&thread_pool[i], NULL, common_thread_function, NULL) < 0) {
            printf("Error creating thread %d\n", i);
        }
    }

    // Create the server socket
    int socket_fd = socket(AF_INET, SOCK_STREAM, 0);
    if(socket_fd < 0) {
        printf("Error creating socket\n");
        exit(EXIT_FAILURE);
    }

    // Enable the socket to be "forced" onto a port
    int option = 1;
    if (setsockopt(socket_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT, &option, sizeof(option))) {
        printf("Error setting socket opt\n");
        exit(EXIT_FAILURE);
    }

    struct sockaddr_in server_address;
    server_address.sin_family = AF_INET;
    server_address.sin_port = htons(PORT);
    server_address.sin_addr.s_addr = htonl(INADDR_ANY);

    // Bind the socket to the port
    if(bind(socket_fd, (struct sockaddr*)(&server_address), sizeof(server_address)) < 0) {
        printf("Error binding socket %d\n", errno);
        exit(EXIT_FAILURE);
    }

    // Start listening
    if(listen(socket_fd, MAX_CONN) < 0) {
        printf("Error listening on socket\n");
        exit(EXIT_FAILURE);
    }

    addrs = my_init_global_addrs();

    // Setup the memory interface to the FPGA
    open_physical_memory_device(addrs);
    mmap_fpga_peripherals(addrs);

    pthread_t led_thread;
    if(pthread_create(&led_thread, NULL, led_function, NULL) < 0) {
        printf("Error creating led thread\n");
    }

    printf("Server listening on port %d\n", PORT);

    struct sockaddr_in client_address;
    socklen_t len;
    int connection_fd;
    pthread_t thread_id;
    // Wait for connections and add them to the queue
    while( (connection_fd = accept(socket_fd, (struct sockaddr*)(&client_address), &len)) ) {
        int* client_socket = malloc(sizeof(int));
        *client_socket = connection_fd;
        enqueue(client_socket);
    }

    close_physical_memory_device(addrs);
    munmap_fpga_peripherals(addrs);
    close(socket_fd);
    return 0;
}