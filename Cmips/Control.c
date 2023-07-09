//
// Created by rafa on 7/10/23.
//

#include "controlPath.h"

void Control(char* opcode,int ctlOut)
{
    static int state=0;
    static char* clk="0";

    //ctrlSignals=PCSource(2)+PCWrite+PCWriteCond+IorD+MemRead+MemWrite+IRWrite+MemtoReg+RegDst+RegWrite+AluSrcA+AluSrcB(2)+AluOP(2)
    static char ctrlSignals[ctrlBits+1]="";

    switch (state) {
        case 0://Instruction Fetch
            strcpy(ctrlSignals,"0000010100000000");
            state=1;
            break;
        case 1://Instruction Decode/Register Fetch
            strcpy(ctrlSignals,"0000000000001100");
            switch (strToInt(opcode,10)) {//next state
                case -1://Sw||Lw
                    state=2;
                    break;
                case 0://R-Type
                    state=6;
                    break;
                case 8://addi
                    //state=10;
                    break;
                case 4://beq
                    state=8;
                    break;
                case 2://j
                    state=9;
                    break;
                default:
                    printf("Default on Ctrl switch\n");
                    exit(1);
            }
            break;
        case 2://Memory address computation
            strcpy(ctrlSignals,"0000000000011000");
            switch (strToInt(opcode,10)) {//next state
                case 35://LW:
                    state=3;
                    break;
                case 43://SW
                    state=5;
                    break;
                default:
                    printf("Default on Ctrl switch\n");
                    exit(1);
            }
            break;
        case 3://Memory access
            strcpy(ctrlSignals,"0000110000000000");
            state=4;
            break;
        case 4://Memory read completion step
            strcpy(ctrlSignals,"0000000001100000");
            state=0;
            break;
        case 5://Memory access
            strcpy(ctrlSignals,"0000101000000000");
            state=0;
            break;
        case 6://Execution
            strcpy(ctrlSignals,"0000000000010010");
            state=7;
            break;
        case 7://R-Type completion
            strcpy(ctrlSignals,"0000000001100000");
            state=0;
            break;
        case 8://branch completion
            strcpy(ctrlSignals,"0101000000010001");
            state=0;
            break;
        case 9://jump completion
            strcpy(ctrlSignals,"1010000000000000");
            state=0;
            break;
            //case 10://addi... to be extended

        default:
            printf("Default on Ctrl switch\n");
            exit(1);
    }
    write(ctlOut,ctrlSignals,ctrlBits+1);
}