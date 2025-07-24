[ORG 0x7C00]

push 0
push 'o'
push 'l'
push 'l'
push 'e'
push 'H'

pop ax
mov ah,0x0e
int 0x10

pop ax
mov ah,0x0e
int 0x10

jmp $

times 510 - ($ - $$) db 0
db 0x55, 0xAA

