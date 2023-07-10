#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define bit 1
#define byte 8
#define word 32
#define regBits 5
#define shmatBits 5
#define fieldBits 6
#define aluOpBits 4
#define immBits 16
#define deOutBits (regBits+regBits+regBits+shmatBits+aluOpBits+immBits)

#define ctrlPCBits 4
#define ctrlIMBits 3
#define ctrlDEBits 1
#define ctrlEXBits 8
#define ctrlBits 16

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

char* toBinaryString(int n) {
    int num_bits = sizeof(int) * 8;
    char *string = malloc(num_bits + 1);
    if (!string) {
        return NULL;
    }
    for (int i = num_bits - 1; i >= 0; i--) {
        string[i] = (n & 1) + '0';
        n >>= 1;
    }
    string[num_bits] = '\0';
    return string;
}

void Control(char* opcode,int ctlPCOut,int ctlIMOut,int ctlDEOut,int ctlEXOut);

void PC(char*clk,char* pcIn,char* zero,int pcOut,char* ctrlSignals);
void InstrMem(char* clk,char* addr,int addrOut,char* ctrlSignals);
void Decode(char* clk, char*deDataIn, int deOut, int DataCtrlPipe,char* ctrlSignals);
void Exec(char* clk,char* signals,int exOut,int zeroOut,char* ctrlSignals);

int main() {
    long nbytes;
    int CtrlPCPipe[2],CtrlIMPipe[2],CtrlDEPipe[2],CtrlEXPipe[2];
    int DataCtrlPipe[2];//1-write 0-read
    if (pipe(CtrlPCPipe) < 0 || pipe(CtrlIMPipe) < 0 ||pipe(CtrlDEPipe) < 0 ||pipe(CtrlEXPipe) < 0 ||pipe(DataCtrlPipe) < 0)
        exit(1);

    //fork to have separate processes
    if(fork()>0){//(Control runs on this process)
        write(DataCtrlPipe[1],"xxxxxx",fieldBits + 1);//Start Control module
        close(DataCtrlPipe[1]);
        close(CtrlPCPipe[0]);
        close(CtrlIMPipe[0]);
        close(CtrlDEPipe[0]);
        close(CtrlEXPipe[0]);

        char DataCtrlBuff[fieldBits + 1];
        while ((nbytes = read(DataCtrlPipe[0], DataCtrlBuff, fieldBits + 1)) > 0) {
            printf("opcode:%s\n", DataCtrlBuff);
            Control(DataCtrlBuff,CtrlPCPipe[1],CtrlIMPipe[1],CtrlDEPipe[1],CtrlEXPipe[1]);
        }
        if (nbytes != 0) {
            exit(2);
        }

        wait(NULL);

        close(DataCtrlPipe[0]);
        close(CtrlPCPipe[1]);
        close(CtrlIMPipe[1]);
        close(CtrlDEPipe[1]);
        close(CtrlEXPipe[1]);
    }else{
        close(DataCtrlPipe[0]);
        close(CtrlPCPipe[1]);
        close(CtrlIMPipe[1]);
        close(CtrlDEPipe[1]);
        close(CtrlEXPipe[1]);

        int ImDePipe[2], ExPcPipe[2],zeroPipe[2];//1-write 0-read
        //create pipes
        if (pipe(ImDePipe) < 0 || pipe(ExPcPipe) < 0|| pipe(zeroPipe) < 0)
            exit(1);

        if (fork() > 0) {//PC & InM
            close(ImDePipe[0]);
            close(ExPcPipe[1]);
            close(zeroPipe[1]);

            int PcImPipe[2];//1-write 0-read
            if (pipe(PcImPipe) < 0)
                exit(1);


            if (fork() > 0) {//(PC runs on this process)
                close(ImDePipe[1]);
                close(PcImPipe[0]);
                close(CtrlIMPipe[0]);

                char ExPcBuff[word+1];
                char zeroBuff[bit+1];
                char CtrlPCBuff[ctrlPCBits+1]="";
                while ((nbytes = read(ExPcPipe[0], ExPcBuff, word + 1)) > 0) {
                    read(zeroPipe[0],zeroBuff,bit + 1);
                    read(CtrlPCPipe[0],CtrlPCBuff,ctrlPCBits+1);
                    printf("PC:%lx\n",strToInt(ExPcBuff,2));
                    PC("1", ExPcBuff,zeroBuff, PcImPipe[1],CtrlPCBuff);
                }
                if (nbytes != 0)
                    exit(2);

                close(ExPcPipe[0]);
                close(zeroPipe[0]);
                close(PcImPipe[1]);
                close(CtrlPCPipe[0]);
            } else {//(Instruction memory runs on this process)
                close(ExPcPipe[0]);
                close(zeroPipe[0]);
                close(PcImPipe[1]);
                close(CtrlPCPipe[0]);

                char PcImBuff[word + 1];
                char CtrlIMBuff[ctrlIMBits+1]="";
                while ((nbytes = read(PcImPipe[0], PcImBuff, word + 1)) > 0) {
                    read(CtrlIMPipe[0],CtrlIMBuff,ctrlIMBits+1);
                    printf("IM:%lx\n",strToInt(PcImBuff,2));
                    InstrMem("1", PcImBuff, ImDePipe[1],CtrlIMBuff);
                }
                if (nbytes != 0)
                    exit(2);

                close(PcImPipe[0]);
                close(ImDePipe[1]);
                close(CtrlIMPipe[0]);
            }
        } else {//DE & EX
            close(ExPcPipe[0]);
            close(zeroPipe[0]);
            close(ImDePipe[1]);

            int DeExPipe[2];
            if (pipe(DeExPipe) < 0)
                exit(1);

            if (fork() > 0) {//(Decode runs on this process )
                close(ExPcPipe[1]);
                close(zeroPipe[1]);
                close(DeExPipe[0]);
                close(CtrlEXPipe[0]);

                char ImDeBuff[word + 1];
                char CtrlDEBuff[ctrlDEBits+1];
                while ((nbytes = read(ImDePipe[0], ImDeBuff, word + 1)) > 0) {
                    printf("addrout:%lx\n", strToInt(ImDeBuff,2));
                    read(CtrlDEPipe[0],CtrlDEBuff,ctrlDEBits+1);
                    Decode("1", ImDeBuff, DeExPipe[1],DataCtrlPipe[1],CtrlDEBuff);
                }
                if (nbytes != 0)
                    exit(2);

                close(ImDePipe[0]);
                close(DeExPipe[1]);
                close(CtrlDEPipe[0]);
                close(DataCtrlPipe[1]);
            } else {//(Exec runs on this process)
                close(ImDePipe[0]);
                close(DeExPipe[1]);
                close(CtrlDEPipe[1]);
                close(DataCtrlPipe[1]);

                write(ExPcPipe[1], "00000000000000000000000000000000", word + 1); //PC start Load
                write(zeroPipe[1],"0",bit+1);

                char DeExBuff[deOutBits + 1];
                char CtrlEXBuff[ctrlEXBits+1];
                while ((nbytes = read(DeExPipe[0], DeExBuff, deOutBits + 1)) > 0) {
                    printf("signalsbuff:%s\n", DeExBuff);
                    read(CtrlEXPipe[0],CtrlEXBuff,ctrlEXBits+1);
                    Exec("1",DeExBuff,ExPcPipe[1],zeroPipe[1],CtrlEXBuff);
                }
                if (nbytes != 0)
                    exit(2);

                close(DeExPipe[0]);
                close(ExPcPipe[1]);
                close(zeroPipe[1]);
                close(CtrlEXPipe[0]);
            }
        }
    }
    return 0;
}

void PC(char*clk,char* pcIn,char* zero,int pcOut,char* ctrlSignals){
    static char pc[word+1]="00000000000000000000000000000000";
    static char writedataReg[word+1]="";
    if(strcmp(clk,"1")!=0){
        printf("PC-clk!=1\n");
        return;
    }
    strncpy(writedataReg,pcIn,word+1);
    if(ctrlSignals[2]=='1'||(ctrlSignals[3]=='1'&&zero[0]=='1'))
    {
        strncpy(pc,pcIn,word+1);
        printf("PC:%lx\n",strToInt(pc,2));
    }
    write(pcOut,pc,word + 1);
}

void InstrMem(char* clk,char* addr,int addrOut,char* ctrlSignals) {
//    static char mem[124]={(char)0b00000110,(char)0b00000000,(char)0b00010000,(char)0b00100000,
//                          (char)0b00001000,(char)0b00000000,(char)0b00010001,(char)0b00100000,
//                          (char)0b00100000,(char)0b10000000,(char)0b00000000,(char)0b00000000,
//                          (char)0b00000001,(char)0b00000000,(char)0b00010001,(char)0b00100010,
//                          (char)0b00100000,(char)0b01001000,(char)0b00100000,(char)0b00000010};
    static char mem[124][byte + 1] = {"00000110", "00000000", "00010000","00100000", //addi $s0, $zero, 6
                                      "00001000", "00000000", "00010001","00100000", //addi $s1, $zero, 8
                                      "00100000", "10000000", "00000000","00000000", //add $s0,$zero,$zero
                                      "00000001", "00000000", "00010001","00100010", //addi $s1,$s0,1
                                      "00100000", "01001000", "00100000","00000010"};//add $t1,$s1,$zero
    if (strcmp(clk,"1")!=0) {
        printf("IM-clk!=1\n");//debug
        return;
    }
//convert addr from "hex"string to int
    long nraddr = strToInt(addr,2);
//read from memory (little-endian)
    char memOut[word + 1] = "";
    sprintf(memOut, "%s%s%s%s", mem[nraddr + 3], mem[nraddr + 2], mem[nraddr + 1], mem[nraddr]);

//    printf("memOut:%s\n",memOut);
//output memOut
    write(addrOut, memOut, word + 1);
}

void Decode(char* clk, char*deDataIn, int deOut, int DataCtrlPipe,char* ctrlSignals){
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
        case 000000://R-Type
            switch (strToInt(fnct,10)) {
                case 100000:
                    strcpy(aluOp,"0010");//add
                    break;
                case 100100:
                    strcpy(aluOp,"0110");//sub
                    break;
                case 100110:
                    strcpy(aluOp,"0000");//and
                    break;
                case 100111:
                    strcpy(aluOp,"0001");//or
                    break;
                case 101010:
                    strcpy(aluOp,"0111");//slt
                    break;
                case 101000:
                    strcpy(aluOp,"0011");//xor
                    break;
                case 101001:
                    strcpy(aluOp,"0100");//nor
                    break;
                default:
                    printf("Default on DE switch(fnct)\n");
                    exit(1);
            }
            break;
        case 1000://addi-001000
            strcpy(aluOp,"0010");//add
            break;
        case 100://beq-000100
            strcpy(aluOp,"0110");//sub
            break;
        case 10://jump-000010
            break;
        default:
            printf("opcode:%s, intopcode:%ld\n",opcode,strToInt(opcode,10));
            printf("Default on DE switch(opcode)\n");
            exit(1);
    }

    char signals[deOutBits+1];//rs+rt+rd+shmat+aluOp+imm
    sprintf(signals, "%s%s%s%s%s%s", rs,rt,rd,shmat,aluOp,imm);

//    char signals[deOutBits+1];//opA+opB+aluOp

//    printf("signals    :%s\n",signals);
    //output signals
    write(DataCtrlPipe,opcode,fieldBits+1);
    write(deOut, signals, deOutBits + 1);

}

void Exec(char* clk,char* signals,int exOut,int zeroOut,char* ctrlSignals){
    static long int i=0;
    static char registers[32][word+1]={ "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000"};
    if(strcmp(clk,"1")!=0){
        printf("EX-clk!=1\n");
        return;
    }

    if(i<3)
    {
        write(exOut,toBinaryString(i*4), word + 1);
        write(zeroOut,"0",bit+1);
        i++;
    }else
    {
        close(exOut);
    }

}


void Control(char* opcode,int ctlPCOut,int ctlIMOut,int ctlDEOut,int ctlEXOut){
    static int state=0;
    static char* clk="0";
    printf("state:%d\n",state);

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
                case -1://Sw||Lw (not -1)
                    state=2;
                    break;
                case 000000://R-Type
                    state=6;
                    break;
                case 1000://addi-001000
                    state=10;
                    break;
                case 100://beq-000100
                    state=8;
                    break;
                case 10://j-000010
                    state=9;
                    break;
                default:
                    printf("Default on Ctrl switch(1)\n");
                    exit(1);
            }
            break;
        case 2://Memory address computation
            strcpy(ctrlSignals,"0000000000011000");
            switch (strToInt(opcode,10)) {//next state
                case 100011://LW:
                    state=3;
                    break;
                case 101011://SW
                    state=5;
                    break;
                default:
                    printf("Default on Ctrl switch(1)\n");
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
        case 10://addi... to be extended
            strcpy(ctrlSignals,"0000000000011000");
            state=11;
            break;
        case 11:
            strcpy(ctrlSignals,"0000000000100000");
            state=0;
            break;
        default:
            printf("Default on Ctrl switch(state)\n");
            exit(1);
    }
    char tempPC[ctrlPCBits+1]="";
    char tempIM[ctrlIMBits+1]="";
    char tempDE[ctrlDEBits+1]="";
    char tempEX[ctrlEXBits+1]="";
    strncpy(tempPC,ctrlSignals,ctrlPCBits);
    write(ctlPCOut,tempPC,ctrlPCBits+1);
    strncpy(tempIM,ctrlSignals+ctrlPCBits,ctrlIMBits);
    write(ctlIMOut,tempIM,ctrlIMBits+1);
    strncpy(tempDE,ctrlSignals+ctrlPCBits+ctrlIMBits,ctrlDEBits);
    write(ctlDEOut,tempDE,ctrlDEBits+1);
    strncpy(tempEX,ctrlSignals+ctrlPCBits+ctrlIMBits+ctrlDEBits,ctrlEXBits);
    write(ctlEXOut,tempEX,ctrlEXBits+1);
}
