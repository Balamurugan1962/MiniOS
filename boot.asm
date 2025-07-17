[org 0x7c00]
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
