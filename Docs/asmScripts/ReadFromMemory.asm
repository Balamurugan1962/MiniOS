[org 0x7c00]

mov [BOOT_DISK],dl

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


BOOT_DISK: db 0

times 510 - ($ - $$) db 0
db 0x55
db 0xAA
db "Hello World From Hard Disk",0
