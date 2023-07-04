import re


rtype={"add": [1,2,0,"00000","100000"],
       "and": [2,0,1,"00000","010100"],
       "or":  [1,2,0,"00000","100101"],
       "xor": [1,2,0,"00000","100110"],
       "nor": [1,2,0,"00000","100111"],
       "slt": [1,2,0,"00000","101010"]}

itype={"addi":["001000",1,0],
       "beq" :["000100",0,1],
       "bne" :["000101",0,1],
       "lw"  :["100011",1,0],
       "sw"  :["101011",1,0]}
jtype={"j":"000010"}

dictionar={"$zero":0,"$v":2,"$a":4,"$t":8,"$s":16}


#inst={"add": r"add *"+rd+"( *, *"+rsrt+"){2}"}
instructions=[rtype,itype,jtype]
rsrt="\$?[a-z]{1,4}[0-9]?"
tags={":":0}
result=[]
offset=0

def main():
    #Get tags
    global offset
    f = open("main.s", "r")
    for index, line in enumerate(f):
        line = line.replace("\n", "")
        if (":" in line):
            tags.update({line: index+offset})
            offset=offset-1
    f.close()
    f = open("main.s", "r")
    for index,line in enumerate(f):
        #print(line)
        line=line.replace("\n","")
        split=line.split(" ")
        inst=split[0]
        registers=(''.join(split[1:]))
        if(":" not in inst):
            if(inst in rtype):
                bin=rtypeToBin(inst,registers)
                result.append([line,bin])
            elif(inst in itype):
                bin=itypeToBin(inst,registers,index)
                result.append([line,bin])
            elif(inst in jtype):
                bin=jtypeToBin(inst,registers)
                result.append([line,bin])
    f.close()
    print(tags)
    print(result)
    binary=[bin[1] for bin in result]
    #binary=[hex(int(bin[1], 2))[2:].zfill(4)   for bin in result]
    print(*binary, sep = "\n")

def jtypeToBin(inst,registers):
    op=jtype[inst]
    tag=tags[registers+":"]
    return op+format(tag, '026b')

def itypeToBin(inst,registers,index):
    op=itype[inst][0]
    imm = ",".join(registers.split(",")[-1:])
    if (re.findall("\d*\(\$?[a-z]{1,4}\d*\)", imm)):#lw, sw
        imm = imm.split("(", 1)[0]

    try:
        imm='0000000000000000' if imm=="" else format(int(imm), '016b')
        if(imm[0]=='-'):
            inverted_string = ''.join('0' if bit == '1' else '1' for bit in imm)
            imm = bin(int(inverted_string, 2) + 1)[2:]
    except:#beq
        tag = (tags[imm + ":"])-index
        imm=format(tag, '016b')
    registers=re.findall(rsrt, registers)
    rs=regtoint(registers[itype[inst][1]])
    rt=regtoint(registers[itype[inst][2]])
    return op+rs+rt+imm

def rtypeToBin(inst,registers):
    op = "000000"
    registers = re.findall(rsrt, registers)
    rs = regtoint(registers[rtype[inst][0]])
    rt = regtoint(registers[rtype[inst][1]])
    rd = regtoint(registers[rtype[inst][2]])
    shmat = rtype[inst][3]
    fnct = rtype[inst][4]
    return op + rs + rt + rd + shmat + fnct

def regtoint(reg):
    matches = re.findall(r'(\$?[a-zA-Z]+)(\d*)', reg)
    letters = [match[0] for match in matches]
    numbers = [match[1] for match in matches]
    regvalue = int(dictionar[letters[0]])
    if(numbers[0]!=""):
        regvalue+=int(numbers[0])
    return bin(regvalue)[2:].zfill(5)

if __name__ == "__main__":
    main()