; SuccessOS Bootloader (Phase 1)

[org 0x7c00] ;BIOS loads here

start:
	mov si, message ; SI = pointer to string

print:
	lodsb ; Load next byte from [SI] -> AL
	cmp al, 0 ; End of string?
	je hang

	mov ah, 0x0e ; BIOS teletype function
	int 0x10 ; Print AL

	jmp print

hang:
	jmp $ ; Infinite loop

message db "SuccessOS Booting...", 0

; Fill remaining space to 512 bytes
times 510-($-$$) db 0

; Boot signature (required)
dw 0xaa55
