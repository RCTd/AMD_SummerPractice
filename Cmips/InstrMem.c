//
// Created by rafa on 7/10/23.
//
#include "dataPath.h"

void InstrMem(char* clk,char* addr,int addrOut) {
//    static char mem[124]={(char)0b00000110,(char)0b00000000,(char)0b00010000,(char)0b00100000,
//                          (char)0b00001000,(char)0b00000000,(char)0b00010001,(char)0b00100000,
//                          (char)0b00100000,(char)0b10000000,(char)0b00000000,(char)0b00000000,
//                          (char)0b00000001,(char)0b00000000,(char)0b00010001,(char)0b00100010,
//                          (char)0b00100000,(char)0b01001000,(char)0b00100000,(char)0b00000010};
    static char mem[124][byte + 1] = {"00000110", "00000000", "00010000","00100000",
                                      "00001000", "00000000", "00010001","00100000",
                                      "00100000", "10000000", "00000000","00000000",
                                      "00000001", "00000000", "00010001","00100010",
                                      "00100000", "01001000", "00100000","00000010"};
    if (strcmp(clk,"1")!=0) {
        printf("IM-clk!=1\n");//debug
        return;
    }
//convert addr from "hex"string to int
    long nraddr = strToInt(addr,16);
//read from memory (little-endian)
    char memOut[word + 1] = "";
    sprintf(memOut, "%s%s%s%s", mem[nraddr + 3], mem[nraddr + 2], mem[nraddr + 1], mem[nraddr]);

//    printf("memOut:%s\n",memOut);
//output memOut
    write(addrOut, memOut, word + 1);
}