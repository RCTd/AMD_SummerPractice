#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define word 32
#define byte 8
#define regBits 5
#define shmatBits 5
#define fieldBits 6
#define aluOpBits 4
#define immBits 16
#define jaddrBits 26
#define deOutBits (1+2+regBits+regBits+regBits+aluOpBits+immBits+jaddrBits)

long strToInt(char* str,int base)
{
    char*output;
    long intstr = strtol(str, &output, base);
    if (*output) {
        if(strcmp(str,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")==0)
            return -1;
        printf("Error occurred");
        exit(3);
    }
    return intstr;
}

char* toBinaryString(long int n) {
    int num_bits = sizeof(long int)*4;
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

void PC(char* pcIn,int pcOut,int pcexOut)
{
    static char pc[word+1]="00000000000000000000000000000000";
    if(strToInt(pcIn,2)<0)//pc=pc+4
    {
        long int pcint= strToInt(pc,2);
        strncpy(pc, toBinaryString(pcint+4),word+1);
        if(pcint==16) exit(0);//Stop at last instruction
    }else//jump
        strncpy(pc,pcIn,word+1);
    write(pcOut,pc,word + 1);
    write(pcexOut,pc,word + 1);
}

void IM(char* imIn,int imOut)
{
    static char mem[124][byte + 1] = {"00000110", "00000000", "00010000","00100000", //addi $s0, $zero, 6
                                      "00001000", "00000000", "00010001","00100000", //addi $s1, $zero, 8
                                      "00100000", "10000000", "00000000","00000000", //add $s0,$zero,$zero
                                      "00000001", "00000000", "00010001","00100010", //addi $s1,$s0,1
                                      "00100000", "01001000", "00100000","00000010"};//add $t1,$s1,$zero
    long int nraddr= strToInt(imIn,2);
    char memOut[word+1]="";
    sprintf(memOut, "%s%s%s%s", mem[nraddr + 3], mem[nraddr + 2], mem[nraddr + 1], mem[nraddr]);
    write(imOut, memOut, word + 1);
}

void DE(char* deIn, int deOut)
{
    //char var[nrBits+\0];
    char aluOp[aluOpBits+1]="";
    char opcode[fieldBits+1]="";
    char rs[regBits+1]="";
    char rt[regBits+1]="";
    char rd[regBits+1]="";
    char fnct[fieldBits+1]="";
    char shmat[shmatBits+1]="";
    char imm[immBits+1]="";
    char jaddr[jaddrBits+1]="";
    char srcA;
    char srcB[2+1]="";
    //deIn=opcode+( rs+rt+(rd+shmat+fnct || imm) // ||  addr )
    strncpy(opcode, (word-1) - 31 + deIn, fieldBits);
    strncpy(rs, (word-1) - 25 + deIn, regBits);
    strncpy(rt, (word-1) - 20 + deIn, regBits);
    strncpy(rd, (word-1) - 15 + deIn, regBits);
    strncpy(shmat, (word-1) - 10 + deIn, regBits);
    strncpy(fnct, (word-1) - 5 + deIn, fieldBits);
    strncpy(imm, (word-1) - 15 + deIn, immBits);
    strncpy(jaddr,(word-1)-25+deIn,jaddrBits);

    switch (strToInt(opcode,2)) {
        case 0://R-Type
            srcA='1';
            strcpy(srcB,"00");
            switch (strToInt(fnct,2)) {
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
            srcA='1';
            strcpy(srcB,"01");
            strcpy(aluOp,"0010");//add
            break;
        case 4://beq
            srcA='0';
            strcpy(srcB,"10");
            strcpy(aluOp,"0110");//sub
            break;
        case 2://jump
            srcA='x';
            strcpy(aluOp,"xxxx");//jump
            break;
        default:
            printf("Default on DE switch\n");
            exit(1);
    }

    char signals[deOutBits+1];//srcA+srcB+rs+rt+rd+aluOp+imm+jaddr
    sprintf(signals, "%c%s%s%s%s%s%s%s",srcA,srcB, rs,rt,rd,aluOp,imm,jaddr);

    //output signals
    write(deOut, signals, deOutBits + 1);
}

void EX(char* exIn,char* pc,int exOut)
{
    static char registers[32][word+1]={ "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000"};
    //exIn=opA+opB+aluOp
    long int opA,opB,result;
    char srcA=                          exIn[0];
    char srcB[2+1]="";                  strncpy(srcB,exIn+1,2);
    char rs[regBits+1]="";              strncpy(rs,exIn+1+2,regBits);
    char rt[regBits+1]="";              strncpy(rt,exIn+1+2+regBits,regBits);
    char rd[regBits+1]="";              strncpy(rd,exIn+1+2+2*regBits,regBits);
    char aluOp[aluOpBits+1]="";         strncpy(aluOp,exIn+1+2+3*regBits,aluOpBits);
    char imm[immBits+1]="";             strncpy(imm,exIn+1+2+3*regBits+aluOpBits,immBits);
    char jaddr[jaddrBits+1]="";         strncpy(jaddr,exIn+1+2+3*regBits+aluOpBits+immBits,jaddrBits);

    opA=srcA=='0'? strToInt(pc,2): strToInt(registers[strToInt(rs,2)],2);
    opB=srcB[0]=='0'?(srcB[1]=='0'?strToInt(registers[strToInt(rt,2)],2) : strToInt(imm,2)):(srcB[1]=='0'? strToInt(imm,2)*4: 0);

    switch (strToInt(aluOp,2)) {
        case 2://add
            result=opA+opB;
            break;
        case 6://sub
            result=opA-opB;
            break;
        case 0://and
            result=opA&opB;
            break;
        case 1://or
            result=opA|opB;
            break;
        case 7://slt
            result=opA<opB;
            break;
        case 3://xor
            result=opA^opB;
            break;
        case 4://nor
            result=~(opA|opB);
            break;
        default:
            printf("default on alu\n");
            exit(1);
    }
    printf("aluResult:%s/%ld\n", toBinaryString(result),result);

    if(srcA=='0')
        write(exOut,toBinaryString(result),word+1);
    else
        write(exOut,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",word+1);
}

int main()
{
    long nbytes;
    int ExPcPipe[2];//1-write 0-read
    int PcExPipe[2];
    int ImDePipe[2];

    if (pipe(ExPcPipe) < 0 || pipe(ImDePipe) < 0 || pipe(PcExPipe) < 0 )
        exit(1);

    //fork to have separate processes
    if(fork()>0) {//PC&IM
        close(ExPcPipe[1]);
        close(PcExPipe[0]);
        close(ImDePipe[0]);
        int PcImPipe[2];

        if (pipe(PcImPipe) < 0 )
            exit(1);

        if(fork()>0) {//PC
            close(ImDePipe[1]);
            close(PcImPipe[0]);

            char PcBuff[+1];
            while ((nbytes = read(ExPcPipe[0], PcBuff, word + 1)) > 0) {
                PC(PcBuff,PcImPipe[1],PcExPipe[1]);
            }
            if (nbytes != 0)
                exit(2);

            wait(NULL);//done

            close(ExPcPipe[0]);
            close(PcExPipe[1]);
            close(PcImPipe[1]);
        }else{//IM
            close(ExPcPipe[0]);
            close(PcExPipe[1]);
            close(PcImPipe[1]);

            char ImBuff[word+1];
            while ((nbytes = read(PcImPipe[0], ImBuff, word + 1)) > 0) {
                IM(ImBuff,ImDePipe[1]);
            }
            if (nbytes != 0)
                exit(2);

            close(PcImPipe[0]);
            close(ImDePipe[1]);
        }

    }else{//DE&EX
        close(ExPcPipe[0]);
        close(PcExPipe[1]);
        close(ImDePipe[1]);
        int DeExPipe[2];

        if (pipe(DeExPipe) < 0 )
            exit(1);

        if(fork()>0) {//DE
            close(ExPcPipe[1]);
            close(PcExPipe[0]);
            close(DeExPipe[0]);

            char DeBuff[word+1];
            while ((nbytes = read(ImDePipe[0], DeBuff, word + 1)) > 0) {
                DE(DeBuff,DeExPipe[1]);
            }
            if (nbytes != 0)
                exit(2);

            close(ImDePipe[0]);
            close(DeExPipe[1]);
        }else{//EX
            close(ImDePipe[0]);
            close(DeExPipe[1]);

            write(ExPcPipe[1],"00000000000000000000000000000000",word+1);//start

            char ExBuff[deOutBits+1];
            char pcBuff[word+1];
            while ((nbytes = read(DeExPipe[0], ExBuff, deOutBits + 1)) > 0) {
                read(PcExPipe[0],pcBuff,word+1);
                EX(ExBuff,pcBuff,ExPcPipe[1]);
            }
            if (nbytes != 0)
                exit(2);

            close(DeExPipe[0]);
            close(ExPcPipe[1]);
        }

    }

    return 0;
}