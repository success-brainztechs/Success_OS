; ==============================
; SuccessOS Bootloader (Phase 3)
; ==============================

[org 0x7c00]

start:
    mov [BOOT_DRIVE], dl

    mov bp, 0x8000
    mov sp, bp

    ; -------------------------
    ; Load kernel (still happens)
    ; -------------------------
    mov ah, 0x02
    mov al, 1
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, [BOOT_DRIVE]

    mov bx, 0x1000
    int 0x13

    jc disk_error

    ; -------------------------
    ; ENTER PROTECTED MODE
    ; -------------------------
    cli                     ; Disable interrupts

    lgdt [gdt_descriptor]   ; Load GDT

    mov eax, cr0
    or eax, 1               ; Set PE bit
    mov cr0, eax

    ; Far jump to flush pipeline
    jmp 0x08:protected_mode_start


; ==============================
; 32-bit CODE
; ==============================
[bits 32]

protected_mode_start:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov esp, 0x90000

    ; Write "OK" to screen (VGA memory)
    mov edi, 0xb8000
    mov eax, 0x2f4b2f4f   ; 'O' 'K'
    mov [edi], eax

hang:
    jmp hang


; ==============================
; ERROR HANDLING (still 16-bit)
; ==============================
[bits 16]

disk_error:
    mov si, error_msg
    call print_string
    jmp $

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


; ==============================
; GDT (Global Descriptor Table)
; ==============================

gdt_start:

gdt_null:
    dd 0x0
    dd 0x0

gdt_code:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

gdt_data:
    dw 0xffff
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start


; ==============================
; DATA
; ==============================
BOOT_DRIVE db 0


; ==============================
; BOOT SIGNATURE
; ==============================
times 510-($-$$) db 0
dw 0xaa55