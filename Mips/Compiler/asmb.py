import re
            #rd,rs,rt
rtype={"add": [0,1,2,"00000","100000"],
       "and": [0,1,2,"00000","010100"],
       "or":  [0,1,2,"00000","100101"],
       "xor": [0,1,2,"00000","100110"],
       "nor": [0,1,2,"00000","100111"],
       "slt": [0,1,2,"00000","101010"],
       "sll": [0,1,0,"","000000"],
       "srl": [0,1,0,"","000010"],
       "sra": [0,1,0,"","000011"],
       "sllv":[0,1,2,"00000","000100"],
       "srlv":[0,1,2,"00000","000110"],
       "srav":[0,1,2,"00000","000111"],
       "div": [0,1,2,"00000","011010"]}

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
    offset=0
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
        else:
            offset=offset-1
    f.close()
    print(tags)
    print(result)
    binary=[bin[1] for bin in result]
    #binary=[hex(int(bin[1], 2))[2:].zfill(4)   for bin in result]
    print(*binary, sep = "\n")
    hexa = [hex(int(bin, 2)) for bin in binary]
    print(*hexa, sep="\n")

    for index,bin in enumerate(binary):
         print(f"{{mem[{index*4+3}],mem[{index*4+2}],mem[{index*4+1}],mem[{index*4}]}}=32'b{bin}; //{hexa[index]} \t{result[index][0]}")

    for bin in binary:
        print(f"{bin[24:32]} {bin[16:24]} {bin[8:16]} {bin[0:8]}")

    for index,bin in enumerate(binary):
        print(f"\"{bin[24:32]}\",\"{bin[16:24]}\",\"{bin[8:16]}\",\"{bin[0:8]}\", //{result[index][0]}")

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
        tag = (tags[imm + ":"])-(index+offset)-1
        imm = format(tag, '016b')
        if(tag<0):
            inverted_string = ''.join('0' if bit == '1' else '1' for bit in imm)
            imm = bin(int(inverted_string, 2) + 1)[2:]

    registers=re.findall(rsrt, registers)
    rs=regtoint(registers[itype[inst][1]])
    rt=regtoint(registers[itype[inst][2]])
    return op+rs+rt+imm

def rtypeToBin(inst,registers):
    op = "000000"
    imm = ",".join(registers.split(",")[-1:])
    registers = re.findall(rsrt, registers)
    rd = regtoint(registers[rtype[inst][0]])
    rs = regtoint(registers[rtype[inst][1]])
    rt = regtoint(registers[rtype[inst][2]])
    shmat = rtype[inst][3]
    if(shmat==""):
        shmat=format(int(imm), '05b');
        rt="00000"
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