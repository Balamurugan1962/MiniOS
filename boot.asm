[org 0x7c00]

mov [BOOT_DISK],dl

CODE_SEG equ Code_Descriptor - GDT_start
DATA_SEG equ Data_Descriptor - GDT_start

cli
lgdt [GDT_Descriptor]
mov eax,cr0
or eax,1
mov cr0,eax
jmp CODE_SEG:start_protected_mode

jmp $

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

GDT_Descriptor:
    dw GDT_end - GDT_start - 1
    dd GDT_start




[bits 32]
start_protected_mode:
    call clear_screen
    mov ax, 0x02

    mov esi, hello_world
    mov edi, 0xb8000
    mov ah,0x02

    loop:
        lodsb
        cmp al,0
        je exit
        stosw
        jmp loop



exit:
    cli
    jmp $

clear_screen:
    mov edi, 0xb8000
    mov al, ' '
    mov ax, 0x00
    mov ecx, 80 * 25
    rep stosw
    ret



hello_world:
    db "Hello World From Protected Mode!!",0


BOOT_DISK: db 0
times 510 - ($ - $$) db 0
db 0x55
db 0xAA
