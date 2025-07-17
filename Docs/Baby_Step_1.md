# Baby Step 1

So in this step we will try to create the enviroment and try to print hellow world in bootloader.

# Required Package:
First we need to install a veritualiser, for MAC and Linux use [QEMU](https://www.qemu.org/docs/master/) and for Windows try to use WSL and then install QEMU

We need to write our bootloader using assembly, for that we need to use a assember

we will use NASM assembler for our bootloader

for MAC use homebrew to install QEMU and NASM

```zsh
brew install QEMU
brew install NASM
```

create a folder for OS

```zsh
mkdir miniOS
cd miniOS
```
then create a `boot.asm` file

```zsh
touch boot.asm
code .
```

now lets understand the concept of bootloader,

### 1) Boot loader is always loaded on `0x7c00` in Main Memory
why is that, it all started from `IBM PC 5150` which used 8088 processor first loaded its bootloader in 0x7c00
why did `IBM PC 5150` stored there? it was because that Computer used a memory layout like shown bellow

```
+--------------------- 0x0
| Interrupts vectors
+--------------------- 0x400
| BIOS data area
+--------------------- 0x5??
| OS load area
+--------------------- 0x7C00
| Boot sector
+--------------------- 0x7E00
| Boot data/stack
+--------------------- 0x7FFF
| (not used)
+--------------------- (...)
```

so they wanted to leave as much as space for the OS so they chose last few bytes to run bootloader, so that i didnt over write anyother important processes

then after completing the bootloading OS will be loaded in memeory and will take out the space of bootloader

and this type is continued still now to ensure backwards compatability

### 2) Our bootloader should be 512 Bytes long
why we need so, as we so in introduction BIOS checks for MBR in DISK, to check for any bootabe device
this MBR is typically 512 bytes long and why 512 byte, same story goes here `IBM PC 5150` was only capable of retriving 512 Bytes.

So again for backwards compatability they continued this processes

### 3) our Bootloader code will act as a MBR:
so as we saw the structure of MBR in intriduction
first 446 bytes is only for bootloader, after that 64 bytes is for partition table imfromation then last two bytes for boot signature

**Note:** As we are emulating with QEMU we are not going to access real hardware so we dont need to write partition information for now

### 4) Last two byte should be 0x55 and 0xaa
again why 0x55AA as boot signature
If the final signature is 0x55AA or 0xAA55 (Based on big endian or little endian repectively ) of MBR at 511th and 512th bytes respectively BIOS transfers control to the MBR to boot the OS. If the final signature does not match, the BIOS looks for additional bootable devices. If no devices are found, the OS does not boot, and the user receives an error message.

The value 0x55AA was chosen early in IBM PC design as a simple, recognizable two-byte magic number placed at the last two bytes of the 512-byte boot sector (bytes 510 and 511).

once again due to backwards compatability they kept this convection

## lets code now

first lets specify our assember from where does the code starts

this can be done by `org` directive which infroms assembler, so assembler can convert address accordingly

```asm
[org 0x7c00]
```

then we can normally use our assembly code here

for now ill try to print 'Hello World'

for printing BIOS as inbuilt output intrupt
there are many intrupts [check here](https://en.wikipedia.org/wiki/BIOS_interrupt_call)

to call intrupts we can use `int` in assembly

and `int 0x10` is intrupt for 'Video Services' in which varius video related intrupts are provided

to acces those intrupts we need to specify as code in `AH` and value to display in `AL`
`AH = 0x0x0E` is for 'Write Character in TTY Mode' which is used to write ASCII Character to the screen

ASCII charecter should be stored in `AL`
then subintrupt value should be stored in `AH`
and then `int 0x10` should be called

like shown bellow

```asm
mov AH,0x0x0E
mov AL,'H'
int 0x10
```

so a simple 'Hello World' would take
```asm
mov AH,0x0x0E
mov AL,'H'
int 0x10

mov AL,'E'
int 0x10

mov AL,'L'
int 0x10

mov AL,'L'
int 0x10

mov AL,'O'
int 0x10

mov AL,' '
int 0x10

mov AL,'W'
int 0x10

mov AL,'O'
int 0x10

mov AL,'R'
int 0x10

mov AL,'L'
int 0x10

mov AL,'D'
int 0x10
```

thats a very big repetaive thing to do

so here we can use a String and loops to reduse the lines

first lets see how to assign a value to a variable

in assembly we can assign as value by using `db` which can store 1 byte
```asm
db 01
```
then if db was in 1000th line in main memory after executing 1000th line will it will have have value of 01

we can even store multiple values sequantially like
```asm
db 'H','e','m','l','l','o'
```
this will store H in 1000th then e in 1001th line and m in 1002th line and so on

we can write above series of character as a string like shown below
```asm
db 'Hello World'
```

will assign next 11 bytes of main memory to 'Hello World' respectively

and keeping it in a lable like

```asm
lable:
  db "Hello World"
```


we can use the value whenever we want just by moving the memory of label to register, label will have adress of 'H' ya first instruction in that place, like we jmp to a line in 8086

we can assign this adress to a register and if we increment we can go to next character

**how to know when to stop?**
for that we can use 0 as a string terminator, which means in ASCII 0 means NULL, so this acts as a end of string

now lets try to loop

```asm
mov ah,0x0E
mov bx,helloworld

loop:
  mov al,[bx]
  cmp al,0
  je exit

  int 0x10
  inc bx
  jmp loop

exit:

helloworld:
  db "Hello World",
```
cmp - subtracts both values and triggers respective flags
je - compares zero flag if it is set then jumps


then once we wrote all our code we should fill remaing bytes till 512th line to 0
why to do so as i said 512Bytes will be loaded to main memory and it runs everything in that 512 to avoid junk values
and our boot signature should be in 511th and 512th line

to fill those rest of lines to 0 we can use a loop
in assemble `$` stands for current address `jmp $` means itll just loop that single line
and `$$` stands for starting address of current program

so `$ - $$` gives total length of the code / used lines

and we need to enter 0x55 and 0xAA in 510th and 511th place (little endian notaion)

so to check for remaing we can use `510 - ($-$$)` or unusedLines = `totalLine - usedLines`

in assembly `times` is a directive, that instructs the assembler to repeat a given instruction or pseudo-instruction a specified number of times

so we will assign 0 `510 - ($ - $$)` times

```asm
times 510 - ($ - $$) db 0
```

then after reaching 510 line we will assign 0x55 and 0xAA

```asm
db 0x55
db 0xAA
```



## Finally our Hello world code is:

```asm
org [0x7c00]
mov ah,0x0E
mov bx,helloworld

loop:
  mov al,[bx]
  cmp al,0
  je exit

  int 0x10

  inc bx
  jmp loop

exit:
  jmp $


helloworld:
  db "Hello World",0

times 510 - ($ - $$) db 0
db 0x55
db 0xAA
```


now save the file, and compile it to binary formate

```zsh
nasm -f bin boot.asm -o boot.bin
```

now emulate a x86 64bit cpu with qemu

```zsh
qemu-system-x86_64 boot.bin
```

**Note:**
- we can specify that its 16 bits by using `bits 16` directive(for backward compatability)

Refernces:
1) https://www.glamenv-septzen.net/en/view/6
2) https://www.techtarget.com/whatis/definition/Master-Boot-Record-MBR
3) https://wiki.osdev.org/BIOS
4) https://wiki.osdev.org/Bootloader
