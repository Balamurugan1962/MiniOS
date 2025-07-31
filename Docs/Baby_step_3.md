# Baby Step 3:

In this step we will try to enter 32 bit protected mode and try to print "Hello World From Protected Mode"

So lets start with the theory

## Why is Protected mode:

So we saw REAL MODE, i mean our computer starts in REAL MODE in which memory is directly addressed and accessed by any programs

but this leads to a problem like think of you trying to play a song via spotify and spotify can access any sort of memory and do read or write, so there was some error in spotify that lead to write operation of memory which stored OS

that sounds so scary but the fact is this was the case when 8086 was launched, programs had full accessabilty do read amd write any memory

when intel bought 8086 processor it was the time when Personal Computers were booming and may software like lotus124 (Excel sheet types) and all were used by regular and business people, and this problem of giving full access was chaotic

So intel launched 80286 chip which was 32bits and was first chip to have protected mode, but it had verious backfires, like it only support 32bits protected mode so the softwares writen for 8086 and all were counldnt be used here and may problems in implemantation of protected mode itself, this chip failed misrably

from that intel started to provide backwards compatabilty, intel launched 80386 first processor to have 32bits protected mode which we still now use, and in this processor it intially starts with REAL MODE and then tries to switch to PROTECTED MODE

## What is PROTECTED MODE:

In short each memory has a privilage number which specifies which program can access that memormy and which cannot, it provide a abbstraction to physical memory by providing logical memory

it uses SEGMENTATION to abstract access of the physical memory, unlike REAL MODE, in PROTECTED MODE we need to have a table about the imformation about the segments and its property

## Segmentation is PROTECTED MODE:

In REAL MODE we only had 20 bits addressing like which can access upto $2^20$ addresses, 32bit PROTECTED MODE will have 32 addressing lines which can access upto $2^32$ addresses which is 4GiB,

here our main goal is to protect the memory and when 80386 first came out 4GiB space was like todays 1PiB which was very very large, so they didnt had memory space issue like in 8086, they used special kinda segmentation which has verious discription about the segmentation like who can access it,size of the segment, is it readable/writable, privilage to access and so, this information is stored in a table called **Globle Descriptor Table**.

## Globle Discriptor Table:

GDT is a specle data structure used by OS to keep imformation about the segments, this details is accessed by **Segment Selectors**
this table stores **Segment Descriptors** each segment discriptor is of 64bits
[GDT Table in Memory](Assets/GlobalDescriptorTable.png)

**Note:** Usually GDT should have a NULL Descriptor, it will be explained below

## Segment Descriptors:

segment discriptor is of 64bits and its stucture goes like shown below:
[Segment Descriptor In Memory](Assets/SegmentDescriptor.png)

Base: Start address of the segemnt

Limit: Size of the segemnt

Acess Byte:
[AccessByte in Memory](Assets/AccessByte.png)
P - Present Byte: (1) - it has real value and allows entry to refer, (0) - does not allows entry to refer

DPL - Descripter Privilage(2bits): so there are mainly 4 values:

- (00) only kernal has this privilage
- (01 and 10) device drivers in old proccecors
- (11) user applicaltion privialge

S - Descriptor Type: (1) System Segement(for TSS,interupts and system related segments), (0) - Data or Code segment

E - Executable Bit: (0) - Data Segment(Not executable), (1) - Code segment

DC - direction /Confirming Bit:

- if Code Segment:(0) - can only be executed by same DPL, (1) - can be executed to equal or smaller DPL value
- if Data Segment:(0) - grows up (moves towards larger memory value), (1) - grows down (moves towards smaller memory value)

RW - Readable / Writable Bit :

- if Code Segment:(0) - read not allowed, (1) - read is allowed (by default write is not allowed)
- if Data Segment:(0) - write not allowed, (1) - write is allowed (by default write is allowed)

A - Accessed Bit: (1) CPU has accessed the segement, (0) CPU has not accessed the segment,(Mainly for paging).

Flags:
[Flags](Assets/Flags.png)
G - Granularity Flag: indicates the size of limit value:

- (0) - 1 Byte
- (1) - 4KiB
  DB - Size Flag: (0) - 16bit mode, (1) - 32bits mode
  L - Long Flag: (0) - not in long mode(64 bit), (1) - in long mode
  Reserve : 0 by default

## How to switch to protected:

To switch to PROTECTED MODE we should first define GDT and give segment info for CODE and DATA segemts, for now we will try to go with **Linear Memory Managemnt** Model, which is same like tiny model we used in REAL MODE where entirte memory is treated as contigious memory space

So to switch from REAL MODE to PROTECTED MODE, first we should point our GDT to `GDTR` a special register for storing location of GDT, and there is control register, A control register is a processor register that changes or controls the general behavior of a CPU or other digital device.

mainly `cr0` or 0th control register, we should change its 1st bit from 0 to 1 and in this process we shouldnt change anyother value of cr0

which 1st bit is changed to 1 in cr0, CPU used GDT from GDTR to access the segments and work accordingly

## GDTR:

GDTR is a special purpose register which is used to store details about the GDT its sturcture is shown below
[GDTR](Assets/GDTR.png)

Size: Size of the GDT table

- Here size should always be btw 0,65535 but GDT can be upto 65536 so to componsate it we subtract total size by 1, beacuse of this size of GDT should never be 0 so there always will be a NULL_Descriptor

Offset: Starting Address of the segment

## Lets implement it:

first lets create tha GDT table
before that wk `db` is used to store 1 byte similary we have `dw`,`dd` to store 2 and 4 bytes respectivly

```asm
GDT_start:
    NULL_Descriptor:
        dd 0
        dd 0

    Code_Descriptor:
        dw 0xffff       ;limit
        dw 0            ;base
        db 0            ;base
        db 0b10011010   ;access
        db 0b11001111   ;flags + limit
        db 0            ;base

    Data_Descriptor:
        dw 0xffff
        dw 0
        db 0
        db 0b10010010
        db 0b11001111
        db 0
GDT_end:
```

Now lets define GDTR

```asm
GDT_Descriptor:
    dw GDT_end - GDT_start - 1      ; Size
    dd GDT_start                    ; Offset (Starting postion)
```

so now lets point the GDTR to GDT_Descriptor, for this we can use a directive `lgdt` it loads GDT to GDTR

```asm
lgdt [GDT_Descriptor]
```

now lets set 1st bit of cr0 to 1:

```asm
mov eax,cr0
or eax,1
mov cr0,eax
```

**Note:** eax is 32 bit version of ax

## Important things:

One main problem with PROTECTED MODE is, we cannot access BIOS from protected mode, which mean now we cannot use BIOS Intrupts to do functions liks print and all, and main solution is to create our own code for each drivers but that too hectic, so we try to store as much as imformation about hardware when we are in REAL MODE and try to switch to PROTECTED MODE

for now BOOT DISK Number is the important number which only optained in `dl` when bootloader is loaded

so we save it in memory before code even starts

now we need to save Segment Index of CODE and DATA that can be done by

```asm
CODE_SEG equ GDT_start - Code_Descriptor
DATA_SEG equ GDT_start - Data_Descriptor
```

`equ` is a dirative to store constant value,unlike `db`

overall code:

```asm
[org 0x7c00]

mov [BOOT_DISK],dl

lgdt [GDT_Descriptor]
mov eax,cr0
or eax,1
mov cr0,eax

hlt

GDT_start:          ;always should be last (when 16bit area ends)
    NULL_Descriptor:
        dd 0
        dd 0

    Code_Descriptor:
        dw 0xffff       ;limit
        dw 0            ;base
        db 0            ;base
        db 0b10011010   ;access
        db 0b11001111   ;flags + limit
        db 0            ;base

    Data_Descriptor:
        dw 0xffff
        dw 0
        db 0
        db 0b10010010
        db 0b11001111
        db 0
GDT_end:

GDT_Descriptor:
    dw GDT_end - GDT_start - 1
    dd GDT_start

CODE_SEG equ GDT_start - Code_Descriptor
DATA_SEG equ GDT_start - Data_Descriptor

BOOT_DISK: db 0


times 510 - ($ - $$)
db 0x55
db 0xAA
```

now we succesfully came into protected mode, so now lets try to print hellow world
so lets create a code in CODE_SEGMENT

```asm
[32 bits] ;to specilfy assembler that its 32 bits
start_of_protected_mode:
    db 0
    jmp $
```

in this segment lets try to print "Hello World From Protected Mode!"

We saw that in PROTECTED MODE we cannot use BIOS, so now we try to manually access the Device Driver thats responsible for text printing and print

So for now we consider to have a `IBM PS/2` which had first 80386 chip in it, and this system used Video Graphics Array (VGA) a video display controller and accompanying de facto graphics standard, has backwards compatabily for morden chips too

this VGA controller has VGA Text Mode which is used to display text with foreground and background color, VGA (Video Graphics Array) memory is typically located in the PC's address space within the range of 0xA0000 to 0xBFFFF

VGA Text Mode starts from 0xB8000, and each cel consist of 2bytes one for asii carechter other byte had frist 2 for forground color and next 2 for background color

```asm
mov al,'A'
mov ah,0x0f
mov [0xB8000],ax
```

the above code will print the A in top right corner, and while disply is treated as a matrix(80 x 25) and in memory it is treated as 1D array

so lets try to assign all that 80 x 25 blocks to ' ' and 0x00

```asm
clear_screen:
    mov edi,0xB8000
    mov ecx,80*25
    mov al,' '
    mov ah,0x00
    rep stosw
    ret
```

`rep` is a directive which will repeat untill ecx times
`stosw` stored ax to edi and adds 2 bytes to edi
`lodsb` loads sdi into ax and adds 1 byte to esi

now with `lodsb` and `stosw` lets try to print

```asm
start_of_protected_mode:
    call clear_screen

    mov edi ,0xb8000
    mov esi,hello_world

    mov ah,0x02 ;for green text color and black background

    loop:
        lodsb ;load esi into ax and add 1 byte

        cmp al,0
        je exit

        stosw ;store ax into esi and add 2 bytes

        jmp loop




hello_wrold db "Hello World From Protected Mode!!",0
```

SO thats how we switch to PROTECTED MODE, but there are many more things to look at PROTECTED MODE mainly defining Device Conrollers like GDT and so on, we will try to do it in future.

Next we will try to work with GCC

Refernces:
[1] https://en.wikipedia.org/wiki/Control_register
[2] https://en.wikipedia.org/wiki/Segment_descriptor
[3] https://en.wikipedia.org/wiki/VGA_text_mode
[4] https://huichen-cs.github.io/course/CISC3320/19FA/lecture/modeswitch.html
[5] https://wiki.osdev.org/Global_Descriptor_Table
