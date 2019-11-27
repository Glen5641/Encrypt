#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <cuda.h>

/**
 * Encrypt Program Cuda
 *
 * This program encrypts a file using a degree 2 formula using Cuda
 * Parallelization and then decrypts the file using another degree 2
 * formula.
 *
 * @Author: Clayton Chase Glenn
 */

#define MAX 20
#define DEBUG 0

/** Kernel Function
  * First finds the Thread ID within the block of GPU Threads
  * and if the Thread is Correct, it Encrypts the corresponding
  * Character in the String.
 **/
__global__
void encrypt(char *p, char *c, int a, int b, int n) {
  int tid = blockIdx.x * blockDim.x + threadIdx.x;
  if(tid < n) c[tid] = (a*p[tid] + b) % 256;
}

/** Kernel Function
  * First finds the Thread ID within the block of GPU Threads
  * and if the Thread is Correct, it Encrypts the corresponding
  * Character in the String.
 **/
__global__
void decrypt(char *p, char *c, int a, int b, int n) {
  int tid = blockIdx.x * blockDim.x + threadIdx.x;
  if(tid < n) c[tid] = (a*p[tid] + b) % 256;
}

/** Kernel Function
  * First finds the Thread ID within the block of GPU Threads
  * and if the Thread is Correct, it checks if the corresponding
  * character in array a matches b.
 **/
__global__
void isMatch(char *p, char *c, int *a, int n) {
  int tid = blockIdx.x * blockDim.x + threadIdx.x;
  if(tid < n) {
    if (c[tid] != p[tid]) {
      *a = 1;
    }
  }
}

/**
  * Helper Function
  * Prints an string to standard error showing help
  * for valid arguments in the executable
 **/
void printerror(){
  fprintf(stderr, "Invalid Arguments\n");
  fprintf(stderr, "Correct Form: ./encrypt [File to Encrypt]\n");
  fprintf(stderr, "              or\n");
  fprintf(stderr, "              ./encrypt -n [2^(1:20)]\n");
  exit(0);
}
/**
  * Main Program
  * This Program is for Homework 6 to encrypt some text or show
  * the encryption method of text that is 2 to the power of N
  * characters long all initialized to zero.
 **/
int main(int argc, char **argv) {

  // Declare a buffer of max size to start
  int     N = MAX;
  char *buf;

  // Check for immediate errors in args
  if (argc < 2)                           printerror();
  if (argc == 3 && strcmp(argv[1], "-n")) printerror();

  // If args match for testing, Initiallize the program
  if(!strcmp(argv[1], "-n") && argc == 3){

    // Get total characters from args
    N = strtol(argv[2], NULL, 10);

    // Show error if N isn't within constraints
    if(N < 1 || N > 20) printerror();

    // N <- calc to 2^N as size and allocate space
    N   = (int)pow(2, N);
    buf = (char*)malloc(N*sizeof(char));

    //Initiallize the buffer to Zero
    int i = 0;
    while (i < N) buf[i++] = 48;
  }

  // If 2 args, this means file
  if(argc == 2) {

    // Declare a file pointer, character array, and single character for reading
    FILE *fp;
    char c;
    char chars[1048576];
    int i = 0;

    // Open the file for reading
    fp = fopen(argv[1], "r");

    // If file is null, file does not exist or error
    if (fp == NULL) {
      fprintf(stderr, "Not a Valid File\n");
      return (-1);
    }

    // Read each character and keep within 2^20, add to array
    while((c = fgetc(fp)) != EOF) {
      if (i >= 1048576) {
        fprintf(stderr, "File Too Large\n");
        return (-1);
      }
      chars[i++] = c;
    }

    // Increment i for space and allocate space for buffer
    N = i + 1;
    buf = (char*)malloc(N*sizeof(char));

    // Copy read elements into buffer
    i = 0;
    while(i < N) buf[i] = chars[i++];

    // Close File, not needed anymore
    fclose(fp);
  }

  // Initiallize Character Arrays for Encrypting and manual memset
  char h_p[N];
  char h_c[N];
  char h_r[N];
  int i = 0;
  while (i < N) {
    h_p[i] = buf[i];
    h_c[i] = 32;
    h_r[i++] = 32;
  }

  // Init all other variables
  char *dev_p, *dev_c, *dev_r;
  int *match;
  int h_match = 0;
  int h_a = 171, h_b = 55;
  int r_a = 3,   r_b = 91;
  cudaEvent_t start1, start2, start3, startf, stop1, stop2, stop3, stopf;
  cudaEventCreate(&start1);
  cudaEventCreate(&stop1);
  cudaEventCreate(&start2);
  cudaEventCreate(&stop2);
  cudaEventCreate(&start3);
  cudaEventCreate(&stop3);
  cudaEventCreate(&startf);
  cudaEventCreate(&stopf);
  float final_time1 = 0.0, final_time2 = 0.0, final_time3 = 0.0, final_timef = 0.0;

  // Allocate Memory for match flag
  match = (int*)malloc(sizeof(int));
  *match = 0;

  // Allocate memory in the GPU for the character arrays
  cudaMalloc(&dev_p, N*sizeof(char));
  cudaMalloc(&dev_c, N*sizeof(char));
  cudaMalloc(&dev_r, N*sizeof(char));
  cudaMalloc(&match, sizeof(int));

  // Print N for distinguish
  printf("N: %d\n", N);

  // If debug on, show plain text
  if(DEBUG) {
    printf("Plain Text:     ");
    i = 0;
    while(i < N) printf("%c", h_p[i++]);
    printf("\n");
  }

  // Copy the Memory from the arrays to the array pointers
  cudaMemcpy(dev_p, h_p, N*sizeof(char), cudaMemcpyHostToDevice);
  cudaMemcpy(dev_c, h_c, N*sizeof(char), cudaMemcpyHostToDevice);
  cudaMemcpy(dev_r, h_r, N*sizeof(char), cudaMemcpyHostToDevice);

  // Start Total Time Record
  cudaEventRecord(startf);

  // Encrypt the Plain Text and Record Start and Finish
  cudaEventRecord(start1);
  encrypt<<<128, 128>>>(dev_p, dev_c, h_a, h_b, N);
  cudaEventRecord(stop1);

  // Copy the results from GPU to the CPU
  cudaMemcpy(h_c, dev_c, N*sizeof(char), cudaMemcpyDeviceToHost);

  // If debug on, show encrypted text
  if(DEBUG) {
    printf("Encrypted Text: ");
    i = 0;
    while(i < N) printf("%c", h_c[i++]);
    printf("\n");
  }

  // Syncronize all blocks and threads in GPU and get time
  cudaEventSynchronize(stop1);
  cudaEventElapsedTime(&final_time1, start1, stop1);

  // Decrypt the Encrypted Text
  cudaEventRecord(stop2);
  decrypt<<<128, 128>>>(dev_c, dev_r, r_a, r_b, N);
  cudaEventRecord(stop2);

  // Copy the results from GPU to CPU
  cudaMemcpy(h_r, dev_r, N*sizeof(char), cudaMemcpyDeviceToHost);

  // If debug on, show decrypted text
  if(DEBUG) {
    printf("Decrypted Text: ", h_r);
    i = 0;
    while(i < N) printf("%c", h_r[i++]);
    printf("\n");
  }

  // Syncronize all blocks and threads in GPU and get time
  cudaEventSynchronize(stop2);
  cudaEventElapsedTime(&final_time2, start2, stop2);

  // Check if Plain Text and Encrypt<-->Decrypt Text is matching by GPU
  cudaEventRecord(start3);
  isMatch<<<128, 128>>>(dev_r, dev_p, match, N);
  cudaEventRecord(stop3);

  // Copy the Match Result from GPU to CPU
  cudaMemcpy(&h_match, match, sizeof(int), cudaMemcpyDeviceToHost);

  // If match is zero, success, else, no success
  if (h_match) fprintf(stdout, "Does not Match\n");
  else         fprintf(stdout, "Does Match\n");

  // Syncronize all blocks and threads in GPU and get time
  cudaEventSynchronize(stop3);
  cudaEventElapsedTime(&final_time3, start3, stop3);

  // Syncronize all blocks and threads in GPU and get time
  cudaEventRecord(stopf);
  cudaEventSynchronize(stopf);
  cudaEventElapsedTime(&final_timef, startf, stopf);

  // Print Times
  printf("Encrypt Time:   %4.10f seconds\n",   final_time1/1000);
  printf("Decrypt Time:   %4.10f seconds\n",   final_time2/1000);
  printf("Match Time:     %4.10f seconds\n",   final_time3/1000);
  printf("Total Time:     %4.10f seconds\n\n", final_timef/1000);

  // Free the GPU memory
  cudaFree(dev_p);
  cudaFree(dev_c);
  cudaFree(dev_r);
}
