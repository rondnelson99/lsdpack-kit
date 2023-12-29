INCLUDE "defines.asm"

SECTION "fade out", ROM0

def FADE_SPEED equ 20 ;number of frames to fade for
FadeOut:: ;fade BGP out to black - blocking
	ld c, 4 ;loop through the 4 colors in the palette
.nextColor
	;do the fade
	ldh a, [hBGP]
	scf 
	rla 
	scf 
	rla 
	ldh [hBGP], a
	ld b, FADE_SPEED / 4
.wait
	push bc
	rst WaitVBlank
	pop bc
	dec b
	jr nz, .wait
	dec c
	jr nz, .nextColor
	ret

SECTION "fade in", ROM0

FadeIn:: ;fade BGP in from black - Blocking
	ld c, 4 ;loop through the 4 colors in the palette
	ld e, MAIN_BGP ;this gets rotated right into BGP
.nextColor
	;do the fade
	ldh a, [hBGP]
	rr e
	rra 
	rr e
	rra 
	ldh [hBGP], a
	ld b, FADE_SPEED / 4
.wait
	push de
	push bc
	rst WaitVBlank
	pop bc
	pop de

	dec b
	jr nz, .wait
	dec c
	jr nz, .nextColor
	ret

SECTION "Load Image", ROM0

; Loads an image + tilemap
; VRAM-safe
; Param: A: Entry number in ImageTable to load
;the entries are 6 bytes long, so multiply by 6
LoadImage::
	add a, a
	ld l, a
	add a, a
	add a, l
	ld l, a
	
	ld h, HIGH(ImageTable)

	;first comes the pointer to the image data
	ld a, [hl+]
	ld e, a
	ld a, [hl+]
	ld d, a

	;then it's bank
	ld a, [hl+]
	ldh [hCurROMBank], a
	ld [rROMB0], a
	ld a, [hl+]
	ldh [hCurROMBank + 1], a
	ld [rROMB1], a
	

	;then the size of the image data
	ld a, [hl+]
	ld c, a
	ld b, [hl]


	ld hl, $8800

	call LCDMemcpy ;copy the new tiles into VRAM


	;and load the tilemap
.loadTilemap
	ld hl, $9800
	ld b, SCRN_Y_B
.row
	ld c, SCRN_X_B
	call LCDMemcpySmall
	;move to the next row
	ld a, l
	add SCRN_VX_B - SCRN_X_B
	ld l, a
	adc h
	sub l
	ld h, a
	dec b
	jr nz, .row
    ret


