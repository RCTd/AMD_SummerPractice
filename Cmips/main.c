#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define byte 8
#define word 32
#define hexWord 8
#define regBits 5
#define shmatBits 5
#define fieldBits 6
#define aluOpBits 4
#define immBits 16
#define deOutBits (regBits+regBits+regBits+shmatBits+aluOpBits+immBits)
#define ctrlBits 16


void InstrMem(char* clk,char* addr,int addrOut);
void PC(char*clk,char* pcIn,int pcOut);
void Decode(char* clk, char* dedataIn, int deOut);

void Exec(char* clk,char* signals,int exOut)
{
    static char registers[32][hexWord+1]={"00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000",
                                          "00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000",
                                          "00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000",
                                          "00000000","00000000","00000000","00000000","00000000","00000000","00000000","00000000"};
    if(strcmp(clk,"1")!=0){
        printf("EX-clk!=1\n");
        return;
    }

}

void Control(char* opcode,int ctlOut)
{
    static int state=0;
    static char* clk="0";

    //ctrlSignals=PCSource(2)+PCWrite+PCWriteCond+IorD+MemRead+MemWrite+IRWrite+MemtoReg+RegDst+RegWrite+AluSrcA+AluSrcB(2)+AluOP(2)
    static char ctrlSignals[ctrlBits+1]="";

    switch (state) {
        case 0:
            strcpy(ctrlSignals,"0000010100000000");
            state++;
            break;
        case 1:
            strcpy(ctrlSignals,"0000000000001100");
            break;
    }
}

int main() {
    long nbytes;
    int CtrlDataPipe[2],DataCtrlPipe[2];//1-write 0-read
    if (pipe(CtrlDataPipe) < 0 || pipe(DataCtrlPipe) < 0)
        exit(1);

    //fork to have separate processes
    if(fork()>0){//(Control runs on this process)
        close(DataCtrlPipe[1]);
        close(CtrlDataPipe[0]);

        wait(NULL);

        close(CtrlDataPipe[1]);
        close(DataCtrlPipe[0]);
    }else{
        close(DataCtrlPipe[0]);
        char ImDeBuff[word + 1];
        int ImDePipe[2], ExPcPipe[2];//1-write 0-read
        //create pipes
        if (pipe(ImDePipe) < 0 || pipe(ExPcPipe) < 0)
            exit(1);

        if (fork() > 0) {//DE & EX
        char DeExBuff[deOutBits + 1];
        int DeExPipe[2];
        if (pipe(DeExPipe) < 0)
            exit(1);

        if (fork() > 0) {//(Exec runs on this process)
            close(ImDePipe[1]);
            close(ImDePipe[0]);

            close(ExPcPipe[0]);
            write(ExPcPipe[1], "00000004", hexWord + 1);
            write(ExPcPipe[1], "00000000", hexWord + 1);
            write(ExPcPipe[1], "0000000c", hexWord + 1);
            close(ExPcPipe[1]);

            close(DeExPipe[1]);
            while ((nbytes = read(DeExPipe[0], DeExBuff, deOutBits + 1)) > 0) {
                printf("signalsbuff:%s\n", DeExBuff);
            }
            if (nbytes != 0) {
                exit(2);
            }
            close(DeExPipe[0]);
        } else {//(Decode runs on this process )
            close(ExPcPipe[1]);
            close(ExPcPipe[0]);

            close(ImDePipe[1]);
            close(DeExPipe[0]);
            while ((nbytes = read(ImDePipe[0], ImDeBuff, word + 1)) > 0) {
//                printf("addrout:%s\n", ImDeBuff);
                Decode("1", ImDeBuff, DeExPipe[1]);
            }
            if (nbytes != 0) {
                exit(2);
            }
            close(DeExPipe[1]);
            close(ImDePipe[0]);
        }
    } else {//PC & InM
        char PcImBuff[hexWord + 1];
        int PcImPipe[2];//1-write 0-read
        if (pipe(PcImPipe) < 0)
            exit(1);

        if (fork() > 0) {//(PC runs on this process)
            close(ImDePipe[1]);
            close(ImDePipe[0]);

            close(PcImPipe[0]);
            close(ExPcPipe[1]);
            while ((nbytes = read(ExPcPipe[0], PcImBuff, hexWord + 1)) > 0) {
                PC("1", PcImBuff, PcImPipe[1]);
            }
            if (nbytes != 0) {
                exit(2);
            }
            close(ExPcPipe[0]);
            close(PcImPipe[1]);
            wait(NULL);
        } else {//(Instruction memory runs on this process)
            close(ExPcPipe[1]);
            close(ExPcPipe[0]);

            close(PcImPipe[1]);
            close(ImDePipe[0]);
            //read from PcImPipe pipe
            while ((nbytes = read(PcImPipe[0], PcImBuff, hexWord + 1)) > 0) {
                InstrMem("1", PcImBuff, ImDePipe[1]);
            }
            if (nbytes != 0) {
                exit(2);
            }
            close(ImDePipe[1]);
            close(PcImPipe[0]);
        }
        return 0;
    }
    }
}

void PC(char*clk,char*pcIn,int pcOut){
    static char pc[hexWord+1]="00000000";
    if(strcmp(clk,"1")!=0){
        printf("PC-clk!=1\n");
        return;
    }
//    for(int i=0;i<hexWord+1;i++){
//        pc[i]=pcIn[i];
//    }
    strncpy(pc,pcIn,hexWord);
//    printf("PC:%s\n",pc);
    write(pcOut,pc,hexWord + 1);
}

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
    char *output;
    long nraddr = strtol(addr, &output, 16);
    if (*output) {
        printf("Error occurred");
        exit(3);
    }
//read from memory (little-endian)
    char memOut[word + 1] = "";
    sprintf(memOut, "%s%s%s%s", mem[nraddr + 3], mem[nraddr + 2], mem[nraddr + 1], mem[nraddr]);

//    printf("memOut:%s\n",memOut);
//output memOut
    write(addrOut, memOut, word + 1);
}

void Decode(char* clk, char*dedataIn, int deOut){
    //static char instruction[word+1]="00000000000000000000000000000000";

    if(strcmp(clk,"1")!=0){
        printf("DC-clk!=1\n");
        return;
    }

    //    if(irWrite=="1") strcpy(instruction,memOut);

    //char var[nrBits+\0];
    char aluOp[aluOpBits+1]="";
    char opcode[fieldBits+1]="";
    char rs[regBits+1]="";
    char rt[regBits+1]="";
    char rd[regBits+1]="";
    char fnct[fieldBits+1]="";
    char shmat[shmatBits+1]="";
    char imm[immBits+1]="";
    //dedataIn=opcode+( rs+rt+(rd+shmat+fnct || imm) // ||  addr )
    strncpy(opcode, (word-1) - 31 + dedataIn, 6);
    strncpy(rs, (word-1) - 25 + dedataIn, 5);
    strncpy(rt, (word-1) - 20 + dedataIn, 5);
    strncpy(rd, (word-1) - 15 + dedataIn, 5);
    strncpy(shmat, (word-1) - 10 + dedataIn, 5);
    strncpy(fnct, (word-1) - 5 + dedataIn, 6);
    strncpy(imm, (word-1) - 15 + dedataIn, 16);

    char *output;
    long intopcode = strtol(opcode, &output, 10);
    if (*output) {
        printf("Error occurred");
        exit(3);
    }
//    if(opcode=="000010"){//jump
//
//    }else
    if (strcmp(opcode,"000000") != 0) {//R-Type
        if(strcmp(fnct,"100000") != 0) {
            strcpy(aluOp,"0010");//add
        }else if(strcmp(fnct,"100010") != 0){
            strcpy(aluOp,"0110");//sub
        }else if(strcmp(fnct,"100100") != 0){
            strcpy(aluOp,"0000");//and
        }else if(strcmp(fnct,"100101") != 0){
            strcpy(aluOp,"0001");//or
        }else if(strcmp(fnct,"101010") != 0){
            strcpy(aluOp,"0111");//slt
        }else if(strcmp(fnct,"100110") != 0){
            strcpy(aluOp,"0011");//xor
        }else if(strcmp(fnct,"100111") != 0){
            strcpy(aluOp,"0100");//nor
        }
    }else if (strcmp(opcode , "001000") != 0) {//addi
        strcpy(aluOp,"0010");//add
    }else if (strcmp(opcode , "000100") != 0) {//beq
        strcpy(aluOp,"0110");//sub
    }
    char signals[deOutBits+1];//rs+rt+rd+shmat+aluOp+imm
    sprintf(signals, "%s%s%s%s%s%s", rs,rt,rd,shmat,aluOp,imm);

//    char signals[deOutBits+1];//opA+opB+aluOp

//    printf("signals    :%s\n",signals);
    //output signals
    write(deOut, signals, deOutBits + 1);

}