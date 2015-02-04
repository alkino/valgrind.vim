#include <stdio.h>
#include <stdlib.h>

#include "b.h"

int main(int argc, char *argv[])
{
    int *a = (int*)malloc(sizeof(int));
    *a=1;
    my_function();
    return EXIT_SUCCESS;
}
