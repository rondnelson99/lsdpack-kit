INCLUDE "defines.asm"

SECTION "StatVector", ROM0[$48]
jp STATHandler

SECTION "STAT handler", ROM0
/*
 * The STAT handler reads from the LYC table at TableAddress in the following format:
   - byte 1: scanline number
   - bytes 2-3: Destination Address (ROM0)
   -- The addresses are jumped to with the scanline number in B.
   - the table should end with $FF
 */
STATHandler:
	push af
	push hl
	push bc 
	push de
	
	ld hl, wLYCTablePosition ; load LYCTablePosition into hl
	ld a, [hl+]
	ld h, [hl]
	ld l, a ; 20

	ld b, [hl] ; get the current scanline

	inc hl ; point to destination address
	ld e, [hl]
	inc hl
	ld d, [hl] ;30
	
	inc hl
	ld a, [hl] ; next scanline
	ldh [rLYC], a

	ld a, l
	ld [wLYCTablePosition], a
	ld a, h
	ld [wLYCTablePosition + 1], a

	ld h, d
	ld l, e
	jp hl ; we have no hope to do any cycle-counting since timer interrupt is also running. 

SECTION "STAT Handler RAM", WRAM0
wLYCTableAddress:: dw
wLYCTablePosition:: dw

SECTION "Init LYC", ROM0
/*
 * Initializes the LYC system with a pointer to the LYC Table
 * Param: DE: the address of the table
 */
InitLYC::
    ld hl, wLYCTableAddress
    ld a, e
    ld [hl+], a
    ld [hl], d
    ; Also copy to LYCTablePosition
    inc hl
    ld [hl+], a
    ld [hl], d


    ld a, STATF_LYC
    ldh [rSTAT], a ; enable LYC interrupt source
    ret