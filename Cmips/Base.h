//
// Created by rafa on 7/10/23.
//

#ifndef AMD_SUMMERPRACTICE_BASE_H
#define AMD_SUMMERPRACTICE_BASE_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

long strToInt(char* str,int base)
{
    char*output;
    long intstr = strtol(str, &output, base);
    if (*output) {
        printf("Error occurred");
        exit(3);
    }
    return intstr;
}

#endif //AMD_SUMMERPRACTICE_BASE_H
