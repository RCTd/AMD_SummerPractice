#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>
#define bit 1
#define byte 8
#define word 32
#define hexWord 8

void InstrMem(char* clk,char* addr,int addrOut);
void PC(char*clk,char*pcIn,int pcOut);

int main(){
    char addrInBuff[hexWord + 1];
    char addrOutBuff[word + 1];
    int pcOut[2],addrOut[2],exOut[2];//1-write 0-read
    long nbytes;
    //create pipes
    if (pipe(pcOut) < 0 || pipe(addrOut) < 0|| pipe(exOut) < 0)
        exit(1);

    //fork to have separate processes
    if (fork() > 0) {//parent
        if (fork() > 0) {
            //(PC will run on this process
            close(exOut[1]);
            close(addrOut[1]);

            close(pcOut[0]);
            while ((nbytes = read(exOut[0], addrInBuff, hexWord + 1)) > 0){
                PC("1",addrInBuff, pcOut[1]);
            }
            if (nbytes != 0) {
                exit(2);
            }

            close(pcOut[1]);
            wait(NULL);
        }else {
            close(addrOut[1]);
            close(pcOut[1]);

            close(exOut[0]);
            write(exOut[1],"00000004",hexWord + 1);
            write(exOut[1], "00000000", hexWord + 1);
            write(exOut[1], "0000000c", hexWord + 1);
        }
    }
    else{
        if (fork() > 0) {
            //
            close(addrOut[1]);
            close(pcOut[1]);
            close(exOut[1]);

            while ((nbytes = read(addrOut[0], addrOutBuff, word + 1)) > 0){
                printf("addrout:%s\n", addrOutBuff);
            }
            if (nbytes != 0) {
                exit(2);
            }
            close(addrOut[0]);
        } else {
            //(Instruction memory will run on this process)
            close(pcOut[1]);
            close(exOut[1]);
            close(addrOut[0]);
            //read from pcOut pipe
            while ((nbytes = read(pcOut[0], addrInBuff, hexWord + 1)) > 0){
                InstrMem("1",addrInBuff, addrOut[1]);
            }
            if (nbytes != 0) {
                exit(2);
            }
            close(addrOut[1]);
            close(pcOut[0]);
        }
    }
    return 0;
}

void PC(char*clk,char*pcIn,int pcOut){
    static char pc[hexWord+1]="00000000";
    if(clk!="1"){
        printf("PC-clk!=1\n");
        return;
    }
    for(int i=0;i<hexWord+1;i++){
        pc[i]=pcIn[i];
    }
    //printf("PC:%s\n",pc);
    write(pcOut,pc,hexWord + 1);
}

//    static char mem[124]={(char)0b00000110,(char)0b00000000,(char)0b00010000,(char)0b00100000,
//                          (char)0b00001000,(char)0b00000000,(char)0b00010001,(char)0b00100000,
//                          (char)0b00100000,(char)0b10000000,(char)0b00000000,(char)0b00000000,
//                          (char)0b00000001,(char)0b00000000,(char)0b00010001,(char)0b00100010,
//                          (char)0b00100000,(char)0b01001000,(char)0b00100000,(char)0b00000010};
void InstrMem(char* clk,char* addr,int addrOut) {
    static char mem[124][byte + 1] = {"00000110", "00000000", "00010000","00100000",
                                      "00001000", "00000000", "00010001","00100000",
                                      "00100000", "10000000", "00000000","00000000",
                                      "00000001", "00000000", "00010001","00100010",
                                      "00100000", "01001000", "00100000","00000010"};
    if (clk != "1") {
        printf("IM-clk!=1\n");//debug
        return;
    }
//convert addr from "hex"string to int
    char *output;
    long nraddr = strtol(addr, &output, 16);
    if (*output) {
        printf("Error occurred");
        exit(3);
    }
//read from memory (little-endian)
    char result[word + 1] = "0";
    sprintf(result, "%s%s%s%s", mem[nraddr + 3], mem[nraddr + 2], mem[nraddr + 1], mem[nraddr]);
//        printf("result:%s\n",result);
//output result
    write(addrOut, result, word + 1);
}
