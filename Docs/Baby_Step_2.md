# Baby Step 2

So in this step we will try to read data from disk, before that first we try to learn what is stack and how we can implement function calls

## Stack:
there are two main special perpuse register for stack `bp` - base pointer & `sp` - stack pointer

`base pointer` : it acts as a rear pointer in a stack
`stack pointer` : it acts as a top pointer in a stack

so first we need to assign a address to these two pointers like
```asm
mov sp,0x8000
mov bp,sp
```

now our stack is initialised in 0x8000 memory location, if we want to push any value we can use `push reg`

```asm
mov bl,10
push bx
```

when the above operation takes place `sp` moves from 0x8000 to 0x7FFE and in 0x7FFE we will be having value 10

now if we use `pop reg` to pop the element in sp and point it to reg

```asm
pop bx
```

now bx will be having the value 10 which was pushed before

### what happens when a function is called:
when a function is called, first it will push all its current register values into stack
then enters the function, after completeing the funciton code it will pop back the state and push the return values into the stack

and to push and pop the all register at ones we can is `pusha` `popa`
it stores `ax,bx,cx,dxsp,bp,si,di` into stack

eg:
```asm
main:
  (-- some asm codes--)
  pusha

  jmp func1

  after_func1:
    popa
    (-- some asm codes --)

func1:
  (-- some asm codes --)
  jmp after_func1
```

doing this everytime is tedious so for that we can use `call` to call a label/function and `ret` to return to previous label/function

```asm
main:
  (-- some asm codes --)

  call func1
    popa
    (-- some asm codes)

func1:
  (-- some asm codes --)
  ret
```
**note:** to use `ret` you should have used `call` to call the function

thats all about stack and fucntion call, now we see about segmentation

## Segmentation:
Memory segmentation is an operating system memory management technique of dividing a computer's primary memory into segments or sections.

for now lets speak about Segmentation in REAL MODE

### Why Segmentation:
In REAL mode we have 16 bit addressing which means we can access $2^16$bits of unique memory location which is 64K Byte, that is very small, we cant even fit a mp3 song

so to increcse this we use segmentation, it splits pur mempry into segmantes and each segment can at max be 64KiB, so that we can reference whole segment

there are three main segments in REAL mode, and for each segment we have a segment register
- 1) Data Segment: `ds` contains data
- 2) Code Segment: `cs` contains code
- 3) Stack Segment: `ss` contains stack
- 4) Extra Segment: `es` for extra storage

[Segmentation](Assets/Segmentation.png)

to access a memory for example a data we can do it by `ds * 16 + offset` offest is the line we are trying to access, ds is the data segement, this is also represented as ds:offset

so when we need to access some data
for example in bootloader if we try to access a data from 200th line it leads to error beacuse we didnt set the ds, which means default ds is 0 => address = ds * 16 + offset => 0 * 16 + 200 so its trying to just access 200th pysical memory location, but in real our program is loaded in 0x7c00 location, this leads to accessing junck values (segmentation error)

so mov ds,0x7c00 stops this segmentation errors

fun fact:
- [org 0x7c00] sets the ds reg default
- when we tried to mov bp, 0x8000 it was actually ss : 0x8000

so this was all about intro segmentation, we see futhure about it later
there are many diff memory models in which they use diff ways to handle this segment registers

for now we will try to work with tiny model in which ss=ds=cs=0
that is the program's code, data, and stack are all contained within a single 64 KB segment.


## Lets read from Disk:

so wk we take first 512 bits of program from disk to main memory, but how to access data which are not in first 512bits, we will see that now, at the end we will try to read 'Hello World From Disk' whcih is stored in Disk

a disk can be wither a floppy Disk, Hard Disk, SSD or etc typical BIOS has intrupt services to read from the disk
for now we will try to read from a Hard Disk

for reading it from hard disk we need to know what is hard disk and how it accesses data

Hard is composed of three main structure, Cylinder, Sector, Head, Cylinder or Disk is the place were we store our data
it is stored as a magnetic orientation, this disk is splited into several sector, each sector is of 512 KB
to access data from disk we use Head

hard disk is a collection os Disks

so to access a data from DISK we need the which cylinder,which sector, and  which head

`0x13` is the intrupt to read from disk, it requires the folowing details (eg: consider we read a data from sector next to bootloader)
- What disk do we want to read: if the disk is same disk from which bootloader is loaded then disk number is stored in dl
- CHS(Cylinder,Head,Sector) address: C = 0, H = 0, S = 2, right after bootloader
- How many Sectors to read? 1
- Where do we load them? (we can store right after our bootloader in main memory that is 0x7c00 + (512) = 0x7e00

we use :
ah : subroutine (typically 0x02 to read from a sectore)
al : number of sectors to read
ch : cylinder number
cl : sector number
dh : is head number
dl : is disk number
bx : to specify where to load
es : segment to load

for example if we want C = 0, H = 0, S = 2 of same disk we can assign
ah = 0x02
al = 1
ch = 0
cl = 2
dh = 0
dl = [diskNum] (shuld be stored in first line itself from dl)
es = 0
bx = 0x7e00

how to know which cylinder, head and sectore:
Each Sector has 512bytes
Each tracks has 18 Sectors
Each tracks had 2 heads
Each Cylinder has 80 Tracks

or can use bellow formula
```
C = LBA / (H × S)
H = (LBA / S) % H
S = (LBA % S) + 1     ← add 1 because sector numbers start at 1
```
where:
LBA = logical sector number (starting from 0) = (PhysicalAddress)/512
Sectors per track = S
Number of heads = H

for more deatils [check this](https://en.wikipedia.org/wiki/BIOS_interrupt_call)

lets take a example
```asm
[org 0x7c00]

halt:
  jmp $

times 510 - ($ - $$) db 0
db 0x55
db 0xAA
db "Hello World From Hard Disk!"
```
wk db 0xAA is stored in 512th bit of the memory in disk, because till now we are comverting a asm to bin which is binary and represent it as a memory

now the string "Hello World From Hard Disk!" will be stored in next 512bits or second sectore in hard disk (QEMU emulated bin file as a hard disk)

so to access the 2nd sector of 0th cylinder via 0th head
```asm
mov ah,0x02
mov al,1
mov ch,0
mov cl,2
mov dh,0
mov bx,0x7E00
int 0x13
```

so the above code will load 2nd sector in 0x7e00th posistion in main memory
and bx has 0x7E00
and in 0x7E00 we have 'H',in 0x7E01 we have 'e' and so on

its like we use label in last step for hello world the code is
```asm
mov ah,0x0e

loop:
    mov al,[bx]
    cmp al,0
    je exit

    int 0x10

    inc bx
    jmp loop
```

this code will print a string stored in bx location

so we can combine both to print the string

which is

```asm
[org 0x7c00]

mov ah,0x02
mov al,1
mov ch,0
mov cl,2
mov dh,0
mov bx,0x7E00
int 0x13

mov ah,0x0e

loop:
	mov al,[bx]
	cmp al,0
	je exit

	int 0x10
	inc bx
	jmp loop

exit:
	jmp $

times 510 - ($ - $$) db 0
db 0x55
db 0xAA
db "Hello World From Hard Disk",0
```

now this runs correct, infuture we will try to handle the error properly
