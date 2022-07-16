/**
 * helloworld.c
 * Example program for printing a greeting in x86-64 assembly.
 * Date: 2022-07-16t17:15
 */

#include <unistd.h>     /* for write, exit, size_t */
#include <stdlib.h>     /* for EXIT_SUCCESS, size_t */
#include <string.h>     /* for strchr, size_t */

#define FD_STOUT (1)    /* file descriptor for STDOUT */

/* store "Hello world!" in GREETING */
const char *GREETING = "Hello world!\x0a";
/* find the end of null-terminated string GREETING */
/* Because C does not have an equivalent to $, we use strchr and
   appreciate that strings are null-terminated in C. */
#define GREET_END (strchr(GREETING, 0))
/* calculate the length of GREETING */
#define GREET_LEN (GREET_END - GREETING)

int main(int argc, char **argv) {
        /* print the greeting to standard output */
        write(FD_STOUT, GREETING, GREET_LEN);
        /* exit without error */
        exit(EXIT_SUCCESS);
} /* end int main(int argc, char **argv) */
