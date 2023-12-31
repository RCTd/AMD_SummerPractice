#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/wait.h>

#define PcCycles 1
#define ImCycles 1
#define DeCycles 1
#define ExCycles 1
#define lastInst 80
#define maxCycle 200

#define nrcontrols 6
#define bit 1
#define cycleBits 32 //<=32
#define word 32
#define byte 8
#define regBits 5
#define shmatBits 5
#define fieldBits 6
#define aluOpBits 4
#define immBits 16
#define jaddrBits 26
#define deOutBits (9*bit+3*regBits+aluOpBits+immBits+jaddrBits)

long strToInt(char* str,int base){
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
        printf("toBinaryString error");
        exit(3);
    }
    for (int i = num_bits - 1; i >= 0; i--) {
        string[i] = (n & 1) + '0';
        n >>= 1;
    }
    string[num_bits] = '\0';
    return string;
}

void PC(char* pcIn_clk,int pcOut,int pcexOut)
{
    static char pc[word+1]="00000000000000000000000000000000";
    
    //separate cycle from input
    char pcIn[word+1]="";
    char cycle[cycleBits+1]="";
    strncpy(pcIn,pcIn_clk,word);
    strncpy(cycle,pcIn_clk+word,cycleBits);
//    printf("pc1-%s\n",cycle);
    //set new pc
    if(strToInt(pcIn,2)<0)//pc=pc+4
    {
        long int pcint= strToInt(pc,2);
        strncpy(pc, toBinaryString(pcint+4),word+1);
        if(pcint==lastInst) exit(0);//Stop at last instruction
        if(strToInt(cycle,2)>maxCycle) exit(1);
    }else//jump
        strncpy(pc,pcIn,word+1);
    
    printf("PC-%ld: PCout:0x%lx / %ld\n", strToInt(cycle,2),strToInt(pc,2),strToInt(pc,2));
    
    //increment cycle
    strcpy(cycle,word-cycleBits + toBinaryString(strToInt(cycle,2)+PcCycles) );
//    printf("pc2-%s\n",cycle);

    //concat pc & cycle
    char out[word + cycleBits + 1]="";
    strncpy(out,pc,word+1);
    strcat(out,cycle);
    
    //pass bits
    write(pcOut,out,word + cycleBits + 1);
    write(pcexOut,pc,word + 1);
}

void IM(char* imIn_clk,int imOut)
{
    static char mem[124][byte + 1] = {"00000110","00000000","00010000","00100000", //addi $s0, $zero, 6
                                      "00001000","00000000","00010001","00100000", //addi $s1, $zero, 8
                                      "00000000","00000000","00010000","10101100", //sw $s0,0($zero)
                                      "00000000","00000000","00001000","10001100", //lw $t0,0($zero)
                                      "00000000","00000000","00010001","10101100", //sw $s1,0($zero)
                                      "00000100","00000000","00010001","10101100", //sw $s1,4($zero)
                                      "00000100","00000000","00001010","10001100", //lw $t2,4($zero)
                                      "00100000","10000000","00000000","00000000", //add $s0,$zero,$zero
                                      "00000001","00000000","00010001","00100010", //addi $s1,$s0,1
                                      "00100000","01001000","00100000","00000010", //add $t1,$s1,$zero
                                      "00000111","00000000","00001001","00010001", //beq $t0,$t1,DONE
                                      "00100000","10010000","00000000","00000010", //add $s2,$s0,$zero
                                      "00100000","10000000","00100000","00000010", //add $s0,$s1,$zero
                                      "00100000","10001000","00010010","00000010", //add $s1,$s0,$s2
                                      "00000000","00000000","01010001","10101101", //sw $s1,($t2)
                                      "00000100","00000000","01001010","00100001", //addi $t2,$t2,4
                                      "00000001","00000000","00101001","00100001", //addi $t1,$t1,1
                                      "00001010","00000000","00000000","00001000", //j START
                                      "00100110","10010000","01010001","00000010", //xor $s2,$s2,$s1
                                      "00100111","10010000","00110010","00000010", //nor $s2,$s1,$s2
                                      "00010100","00000000","00000000","00001000"}; //j FINISH
                                      
    //Separate cycle from input
    char imIn[word+1]="";
    char cycle[cycleBits+1]="";
    strncpy(imIn,imIn_clk,word);
    strncpy(cycle,imIn_clk+word,cycleBits);
//    printf("im1-%s\n",cycle);

    //fetch instruction
    long int nraddr= strToInt(imIn,2);
    char memOut[word+1]="";
//    printf("3:%s, 2:%s, 1:%s, 0:%s\n",mem[nraddr + 3],mem[nraddr + 2],mem[nraddr + 1],mem[nraddr]);

    sprintf(memOut, "%s%s%s%s", mem[nraddr + 3], mem[nraddr + 2], mem[nraddr + 1], mem[nraddr]);

    printf("IM-%ld: IMout:%s\n", strToInt(cycle,2),memOut);

    //increment cycle
    strcpy(cycle,word-cycleBits +toBinaryString(strToInt(cycle,2)+ImCycles));
//    printf("im2-%s\n",cycle);
    
    //concat result & cycle
    char out[word + cycleBits + 1]="";
    strncpy(out,memOut,word+1);
    strcat(out,cycle);
    
    //pass bits
    write(imOut, out, word + cycleBits + 1);
}

void DE(char* deIn_clk, int deOut)
{
    //Separate cycle from input
    char deIn[word+1]="";
    char cycle[cycleBits+1]="";
    strncpy(deIn,deIn_clk,word);
    strncpy(cycle,deIn_clk+word,cycleBits);
//    printf("de1-%s\n",cycle);
    
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
    char srcA='1',memWrite='0',regWrite='1',MemtoReg='0',RegDst='1';
    char brench='0',jump='0';
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
            strcpy(srcB,"00");
            switch (strToInt(fnct,2)) {//determine operation
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
            RegDst='0';
            strcpy(srcB,"01");
            strcpy(aluOp,"0010");//add
            break;
        case 4://beq
            regWrite='0';
            strcpy(srcB,"00");
            strcpy(aluOp,"0110");//sub
            break;
        case 2://jump
            srcA='0';
            regWrite='0';
            jump='1';
            strcpy(srcB,"11");
            strcpy(aluOp,"0010");//jump
            break;
        case 43://sw
            strcpy(srcB,"01");
            strcpy(aluOp,"0010");//add
            memWrite='1';
            regWrite='0';
            break;
        case 35://lw
            strcpy(srcB,"01");
            strcpy(aluOp,"0010");//add
            MemtoReg='1';
            RegDst='0';
            break;
        default:
            printf("Default on DE switch\n");
            exit(1);
    }

    char signals[deOutBits+1];//memWrite+RegWrite+MemtoReg+RegDst+jump+brench+srcA+srcB+rs+rt+rd+aluOp+imm+jaddr
    sprintf(signals, "%c%c%c%c%c%c%c%s%s%s%s%s%s%s",memWrite,regWrite,MemtoReg,RegDst,jump,brench,srcA,srcB, rs,rt,rd,aluOp,imm,jaddr);

    printf("DE-%ld: memWrite:%c, regWrite:%c, MemtoReg:%c, RegDst:%c, jump:%c, brench:%c, srcA:%c, srcB:%s, rs:%s, rt:%s, rd:%s\nimm:%s, jaddr:%s, DEout:%s\n", strToInt(cycle,2),
           memWrite,regWrite,MemtoReg,RegDst,jump,brench,
           srcA,srcB, rs,rt,rd,imm,jaddr,signals);

    //increment cycle
    strcpy(cycle,word-cycleBits +toBinaryString(strToInt(cycle,2)+DeCycles));
    
    //concat result & cycle
    char out[deOutBits + cycleBits + 1]="";
    strncpy(out,signals,deOutBits+1);
    strcat(out,cycle);
    
    //pass bits
    write(deOut, out, deOutBits+ cycleBits + 1);
}

void EX(char* exIn_clk,char* pc,int exOut)
{
    static char registers[32][word+1]={ "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000",
                                        "00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000","00000000000000000000000000000000"};
    static char memory[256][word+1];

    //Separate cycle from input
    char exIn[deOutBits+1]="";
    char cycle[cycleBits+1]="";
    strncpy(exIn,exIn_clk,deOutBits);
    strncpy(cycle,exIn_clk+deOutBits,cycleBits);
//    printf("ex1-%s\n",cycle);

    //get signals
    //exIn=opA+opB+aluOp
    long int opA,opB,result;
    char MemWrite=                      exIn[0];
    char regWrite=                      exIn[1];
    char MemtoReg=                      exIn[2];
    char RegDst=                        exIn[3];
    char jump=                          exIn[4];
    char brench=                        exIn[5];
    char srcA=                          exIn[nrcontrols];
    char srcB[2+1]="";                  strncpy(srcB,exIn+nrcontrols+1,2);
    char rs[regBits+1]="";              strncpy(rs,exIn+nrcontrols+3,regBits);
    char rt[regBits+1]="";              strncpy(rt,exIn+nrcontrols+3+regBits,regBits);
    char rd[regBits+1]="";              strncpy(rd,exIn+nrcontrols+3+2*regBits,regBits);
    char aluOp[aluOpBits+1]="";         strncpy(aluOp,exIn+nrcontrols+3+3*regBits,aluOpBits);
    char imm[immBits+1]="";             strncpy(imm,exIn+nrcontrols+3+3*regBits+aluOpBits,immBits);
    char jaddr[jaddrBits+1]="";         strncpy(jaddr,exIn+nrcontrols+3+3*regBits+aluOpBits+immBits,jaddrBits);

    //set operands
    opA=srcA=='0'? strToInt(pc,2): strToInt(registers[strToInt(rs,2)],2);
    opB=srcB[0]=='0'?(srcB[1]=='0'?strToInt(registers[strToInt(rt,2)],2) : strToInt(imm,2))
                :(srcB[1]=='0'? strToInt(imm,2)<<2: strToInt(jaddr,2));

    printf("opA=%ld,opB=%ld\n",opA,opB);

    //do calculation
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

    if(MemWrite=='1')
        strcpy(memory[result],registers[strToInt(rd,2)]);

    if(regWrite=='1'&&MemtoReg=='0')
        strcpy(registers[strToInt(RegDst=='1'?rd:rt,2)], toBinaryString(result));
    if(regWrite=='1'&&MemtoReg=='1')
        strcpy(registers[strToInt(RegDst=='1'?rd:rt,2)], memory[result]);

    //set result
    char strResult[word+1]="";
    if(brench=='1'){
        if(result==0)
            strcpy(strResult, toBinaryString(strToInt(pc,2)+4+(strToInt(imm,2)<<2)));
        else
            strcpy(strResult,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
    }
    if(srcA=='0') {
        printf("jump to:%ld\n",strToInt(jaddr, 2) << 2);
        strcpy(strResult, toBinaryString((strToInt(jaddr, 2) << 2)));
    }else
        strcpy(strResult,"xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");

    printf("EX-%ld: aluResult:%s / %ld\n", strToInt(cycle,2), toBinaryString(result),result);
    
    //increment cycle
    strcpy(cycle,word-cycleBits +toBinaryString(strToInt(cycle,2)+ExCycles));
    
    //concat result & cycle
    char out[word + cycleBits + 1]="";
    strncpy(out,strResult,word+1);
    strcat(out,cycle);
    
    //pass bits
    write(exOut,out,word+cycleBits+1);
}

int main()
{
    long nbytes;
    char cycle[cycleBits+1]="";
    strncpy(cycle,word-cycleBits+ toBinaryString(1),cycleBits);
//    printf("start cycle:%s.\n",cycle);
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

            char PcBuff[word+cycleBits+1];
            while ((nbytes = read(ExPcPipe[0], PcBuff, word + cycleBits + 1)) > 0) {
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

            char ImBuff[word+cycleBits+1];
            while ((nbytes = read(PcImPipe[0], ImBuff, word + cycleBits + 1)) > 0) {
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

            char DeBuff[word+cycleBits+1];
            while ((nbytes = read(ImDePipe[0], DeBuff, word + cycleBits + 1)) > 0) {
                DE(DeBuff,DeExPipe[1]);
            }
            if (nbytes != 0)
                exit(2);

            close(ImDePipe[0]);
            close(DeExPipe[1]);
        }else{//EX
            close(ImDePipe[0]);
            close(DeExPipe[1]);

            char start[word+cycleBits+1]="00000000000000000000000000000000";
            strcat(start,cycle);
            write(ExPcPipe[1],start,word+cycleBits+1);//start

            char ExBuff[deOutBits+cycleBits+1];
            char pcBuff[word+1];
            while ((nbytes = read(DeExPipe[0], ExBuff, deOutBits + cycleBits + 1)) > 0) {
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
