[org 0x7c00]

mov [BOOT_DISK],dl

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

lgdt [GDT_Descriptor]
mov eax,cr0
or eax,1
mov cr0,eax

BOOT_DISK: db 0


times 510 - ($ - $$)
db 0x55
db 0xAA
