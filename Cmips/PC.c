//
// Created by rafa on 7/10/23.
//

#include "dataPath.h"

void PC(char*clk,char*pcIn,int pcOut){
    static char pc[hexWord+1]="00000000";
    if(strcmp(clk,"1")!=0){
        printf("PC-clk!=1\n");
        return;
    }
    strncpy(pc,pcIn,hexWord);
//    printf("PC:%s\n",pc);
    write(pcOut,pc,hexWord + 1);
}