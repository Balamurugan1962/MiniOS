# Creating A OS from Scratch
Creating a OS from Scratch in the sence everything from bootloader, kernal, GUI Manager, every single system call functions from scratch.

this is very hard and tedious task, it may take months to make a proper working basic kernal, and years to make a GUI like Linux from scratch

The main aim of this project is to build a basic micro kernal based CLI OS. It may not have fancy GUI nor fancy applications but it will have all basic essential tools and functions

Lets start from the basic..

## What happens when computer is ON:
This is mainly for x86 architechure and mainly for legacy system(old proccessor)

when the computer power is switched on:
### 1. CPU is powered on:
It starts in REAL MODE (use Physical Addressing)
It resets all register values to default set values (mainly sets CS = 0xF000 & IP = 0xFFF0) (CS - Code segment, IP - Instruction Pointer)

### 2. BIOS is Loaded:
BIOS-Basic Input/Output System
it is a a special kind of low-level software embedded on a chip on your motherboard.
BIOS is kept in ROM at location 0xFFF0

#### what does BIOS do:
- BIOS checks for weather all hardware works properly (POST)
- Has Boot Order (Boot order is the sequence of devices your computer checks to find a bootable operating system)
- Initialize Devices (Prepares system devices like hard drives, display, USB ports)
- Has Basic I/O and other Function Intrupts whcih is accessible in REAL MODE

Since  CS = 0xF0000 & IP = 0xFFFF0, CPU points to 0xFFFF0(CS * 16 + IP)
Now CPU loads program(BIOS) from 0xFFF0

#### BIOS runs POST:
BIOS runs POST (Power On Self Test)
POST checks if the computer’s critical components work:
- RAM is available
- Keyboard is connected
- Video card works
If something is wrong, BIOS gives beep codes or error messages.

Once POST ends once again BIOS takes over and Initializes drivers

#### BIOS Initializes Hardware:
BIOS sets up,CPU settings,RAM timing,Disk controllers,USB, video, etc.

### 3. Boot Drive Selection:
BIOS has a BOOT Order which is the sequence of devices your computer checks to find a bootable operating system.
BIOS loads first device from BOOT Order and checks if it is bootable. If not, it moves to next device in BOOT Order.

### 4. MBR is accessed:
MBR: master boot record which is the first sector of the bootable device.
MBR is of size 512 Bytes

#### Why 512 Bytes:
- Legacy BIOS was simple and limited.
- It didn’t understand file systems or large memory access at that stage.
- It just loaded the first 512 bytes and jumped to it.

#### Structure of MBR:
- 0 - 445 : Boot loader Code
- 446 - 509 : Partition
- 510 - 511 : boot signature

##### Boot loader Code:
Boot loader is a software that loads the kernal into the main memory

##### Partition:
It contains all the information about the disk Partition details

##### Boot Signature:
this is a signature that signifies the end of the MBR
Just like a string ends by '\0' the boot signature ends by 0xAA55 (2byte)

### Boot Loader is Loaded:
intitially boot loader is of size 446Bytes so this is only used to load a Boot Manager
But in legacy CPU, bootloader were small sized and loaded the first 512 bytes and jumped to it.

#### Boot Manager
A Boot Manager is a software program that is responsible for the management of the booting process of the computer. It is primarily responsible for selecting the Operating System to be loaded from multiple available options.

eg: GRUB

then it loads the kernal of selected OS into memory

### Kernel is loaded:
It initializes the system, including memory management, process management, and device drivers.
The kernel becomes the central component, managing all other software and hardware interactions.
Now the system will be in PROTECTED MODE

then it tries to load the GUI by calling GUI Manager

### GUI is loaded:
now user can see the loading screen and in background the kernal is Initializing the system
then everything is Initialized without ansy errors Window Manager is called

### Lock Screen appiers:
after calling window manger lock screen appiers


**Note:** 0x is a convection used to specify that it is a HEXADECIMAL number


Reference:

1) https://en.wikipedia.org/wiki/Master_boot_record
2) https://en.wikipedia.org/wiki/Boot_sector
