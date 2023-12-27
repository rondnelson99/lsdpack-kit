INCLUDE "defines.asm"

SECTION "Init Menu", ROM0
/*
 * Call at startup before showing menu. Inits the VWF Engine and loads the appropriate tiles for the Window 
 */
InitMenu::
    ld a, LOW(LYCTable)
    ld b, HIGH(LYCTable)
    ld hl, wLYCTableAddress
    ld [hl+], a
    ld [hl], b
    ; Also copy to LYCTablePosition
    inc hl
    ld [hl+], a
    ld [hl], b


    ld a, STATF_LYC
    ldh [rSTAT], a ; enable LYC interrupt source

    xor a
    ldh [rIF], a ; clear any pending STAT interrupt

    ldh a, [rIE]
    or IEF_STAT
    ldh [rIE], a ; enable STAT interrupt

    ret

SECTION "LYC Table", ROM0
LYCTable::
    db 120
    dw ShowMenuTiles
    db $FF

SECTION "Show Menu Tiles", ROM0
ShowMenuTiles::

	ld a, $80 ;LCD on, everything disabled

	ld   hl, rSTAT
    ; Wait until Mode is -NOT- 0 or 1
.waitNotBlank
    bit  1, [hl]
    jr   z, .waitNotBlank
    ; Wait until Mode 0 or 1 -BEGINS- (but we know that Mode 0 is what will begin)
.waitBlank
    bit  1, [hl]
    jr   nz, .waitBlank

	ldh [rLCDC], a

    pop de
    pop bc
	pop hl
	pop af
	reti