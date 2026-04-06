[org 0x1000]

mov ah, 0x0e
mov si, message

print:
	lodsb
	cmp al, 0
	je hang
	int 0x10
	jmp print

hang:
	jmp $

message db "Hello from Kernel!", 0
