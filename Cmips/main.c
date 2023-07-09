#include "dataPath.h"
#include "controlPath.h"
#include <sys/wait.h>

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