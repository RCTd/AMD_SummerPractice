//
// Created by rafa on 7/10/23.
//

#ifndef AMD_SUMMERPRACTICE_DATAPATH_H
#define AMD_SUMMERPRACTICE_DATAPATH_H

#include "Base.h"

#define byte 8
#define word 32
#define hexWord 8
#define regBits 5
#define shmatBits 5
#define fieldBits 6
#define aluOpBits 4
#define immBits 16
#define deOutBits (regBits+regBits+regBits+shmatBits+aluOpBits+immBits)

void InstrMem(char* clk,char* addr,int addrOut);
void PC(char*clk,char* pcIn,int pcOut);
void Decode(char* clk, char* deDataIn, int deOut);

#endif //AMD_SUMMERPRACTICE_DATAPATH_H
