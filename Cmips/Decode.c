//
// Created by rafa on 7/10/23.
//
#include "dataPath.h"

void Decode(char* clk, char*deDataIn, int deOut){
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
    //deDataIn=opcode+( rs+rt+(rd+shmat+fnct || imm) // ||  addr )
    strncpy(opcode, (word-1) - 31 + deDataIn, 6);
    strncpy(rs, (word-1) - 25 + deDataIn, 5);
    strncpy(rt, (word-1) - 20 + deDataIn, 5);
    strncpy(rd, (word-1) - 15 + deDataIn, 5);
    strncpy(shmat, (word-1) - 10 + deDataIn, 5);
    strncpy(fnct, (word-1) - 5 + deDataIn, 6);
    strncpy(imm, (word-1) - 15 + deDataIn, 16);

    switch (strToInt(opcode,10)) {
        case 0://R-Type
            switch (strToInt(fnct,10)) {
                case 32:
                    strcpy(aluOp,"0010");//add
                    break;
                case 34:
                    strcpy(aluOp,"0110");//sub
                    break;
                case 36:
                    strcpy(aluOp,"0000");//and
                    break;
                case 37:
                    strcpy(aluOp,"0001");//or
                    break;
                case 42:
                    strcpy(aluOp,"0111");//slt
                    break;
                case 38:
                    strcpy(aluOp,"0011");//xor
                    break;
                case 39:
                    strcpy(aluOp,"0100");//nor
                    break;
                default:
                    printf("Default on DE switch\n");
                    exit(1);
            }
            break;
        case 8://addi
            strcpy(aluOp,"0010");//add
            break;
        case 4://beq
            strcpy(aluOp,"0110");//sub
            break;
        case 2://jump
            break;
        default:
            printf("Default on DE switch\n");
            exit(1);
    }

    char signals[deOutBits+1];//rs+rt+rd+shmat+aluOp+imm
    sprintf(signals, "%s%s%s%s%s%s", rs,rt,rd,shmat,aluOp,imm);

//    char signals[deOutBits+1];//opA+opB+aluOp

//    printf("signals    :%s\n",signals);
    //output signals
    write(deOut, signals, deOutBits + 1);

}