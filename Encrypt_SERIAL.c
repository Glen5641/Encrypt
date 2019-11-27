#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>

/**
 * Encrypt Program Serial
 *
 * This program encrypts a file using a degree 2 formula
 * and then decrypts the file using another degree 2
 * formula.
 *
 * @Author: Clayton Chase Glenn
 */

#define MAX 20
#define DEBUG 0

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
  int i = 0;
  while (i < N) {
    h_p[i] = buf[i];
    i++;
  }

  float final_time = 0;

  // Print N for distinguish
  printf("N: %d\n", N);

  // If debug on, show plain text
  if(DEBUG) {
    printf("Plain Text: ");
    i = 0;
    while(i < N) printf("%c", h_p[i++]);
    printf("\n");
  }

  clock_t beginf = clock();
  clock_t begin1 = clock();
  i = 0;
  while (i < N) {
    h_p[i] = (h_p[i] * 171 + 55) % 256;
    i++;
  }
  clock_t end1 = clock();
  double time_spent1 = (double)(end1 - begin1) / CLOCKS_PER_SEC;


  // If debug on, show encrypted text
  if(DEBUG) {
    printf("Encrypted Text: ");
    i = 0;
    while(i < N) printf("%c", h_p[i++]);
    printf("\n");
  }

  i = 0;
  while (i < N) {
    h_p[i] = (h_p[i] * 3 + 91) % 256;
    i++;
  }

  // If debug on, show decrypted text
  if(DEBUG) {
    printf("Decrypted Text: ");
    i = 0;
    while(i < N) printf("%c", h_p[i++]);
    printf("\n");
  }

  clock_t begin2 = clock();
  i = 0;
  while (i < N) {
    if(h_p[i] != buf[i]) {
      fprintf(stdout, "Does not match\n");
    }
    i++;
  }
  clock_t end2 = clock();
  double time_spent2 = (double)(end2 - begin2) / CLOCKS_PER_SEC;
  clock_t endf = clock();
  double time_spentf = (double)(endf - beginf) / CLOCKS_PER_SEC;

  printf("%4.10f\n", time_spent1);
  printf("%4.10f\n", time_spent2);
  printf("%4.10f\n\n", time_spentf);

}
