;;; -*- mode: nasm -*-
[org 0x7c00]
[bits 16]

;;; Both of these are blank as they are out of sector
section .data
	;; Constants
section .bss
	;; Mutable Variables

section .text
	global init

init:
	;; Setup Environment
	cli 			; Disable interupts
	jmp 0x0000:ZeroSeg 	; Clear Segment
        ZeroSeg:
	xor ax, ax		; Clear Segment Registers
	mov ss, ax
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov sp, init		; Set the stack pointer
	cld			; Read string ltr (usualy default)
	sti			; Renable interupts
	int 0x13		; Reset disk heads

	;; Fancier System Setup
	call fixA20
	call assert_longmode

	;; Load the second sector
	mov al, 0x01		; Read one sector
	mov cl, 0x02		; Starting after boot loader
	call load_disk

	mov si, STR_HELLO
	call printf

	jmp $

STR_HELLO:	db "Hello, world!",0x0a,0x0d,0

%include "load_disk.asm"
%include "printf.asm"
%include "printh.asm"
%include "fixA20.asm"
%include "longmode.asm"

;;; Pad to 510 with 2 bytes of bootsector magic
	times 510-($-$$) db 0
	dw 0xaa55


;;; Now in second sector
;;; fill out the sector
	;; Ignore the jank
	times 512-($-$$-512) db 0
