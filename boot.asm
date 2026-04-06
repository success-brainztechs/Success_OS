
[org 0x7c00] ;BIOS loads here


start:
	mov [BOOT_DRIVE], dl ; Save boot drive

	mov bp, 0x8000
	mov sp, bp ; Setup stack

	; Load kernel (sector 2 -> memory 0x1000)
	mov ah, 0x02 ; BIOS read sector
	mov al, 1 ; Number of sectors to read
	mov ch, 0 ; Cylinder
	mov cl, 2 ; Sector (starts at 1, so 2 = next)
	mov dh, 0 ; Head
	mov dl, [BOOT_DRIVE] ; Drive

	mov bx, 0x1000 ; Load address
	int 0x13 ; Disk read

	jc disk_error ; If carry flag set -> error

	jmp 0x0000:0x1000 ; Jump to kernel

disk_error:
	mov si, error_msg
	call print_string
	jmp $

; ---------------------------

print_string:
	mov ah, 0x0e
.loop:
	lodsb
	cmp al, 0
	je .done
	int 0x10
	jmp .loop
.done:
	ret

error_msg db "Disk read error!", 0

BOOT_DRIVE db 0

times 510-($-$$) db 0
dw 0xaa55

dw 0xaa55
