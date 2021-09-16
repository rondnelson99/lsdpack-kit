INCLUDE "defines.asm"

SECTION "Intro", ROM0

Intro::
	rst WaitVBlank
	xor a
	ldh [hCurrentSong], a
	ldh [hSongDone], a

SPLASH_TIMEOUT equ 5 * 60
SplashScreen: ;loop at the splash screen until either a button is pressed or a number of frames pass
	ld bc, SPLASH_TIMEOUT
.loop

	push bc
	rst WaitVBlank
	pop bc

	ldh a, [hPressedKeys]
	bit PADB_START, a ;was start pressed?
	jr nz, .done ;if so, we're done
	dec bc ;otherwise, loop intil the counter has run out
	ld a, b
	or c
	jr nz, .loop
.done

	call ChangeSong




	; setup timer
	ld  a,256-183
	ldh [6],a   ; TMA
	ld  a,6
	ldh [7],a   ; TAC
	ld  a, IEF_TIMER | IEF_VBLANK
	ldh [$ff],a ; IE



MainLoop:
	ldh a, [hPressedKeys]
	and a
;if they pressed a button, start playing the next song
	
	call nz, NextSong

	;if hSongDone is 1, switch to the next song and zero it

	ldh a, [hSongDone]
	dec a
	jr nz, .done

	call NextSong
	xor a
	ldh [hSongDone], a


.done
	rst WaitVBlank
	jr MainLoop

SECTION "Change Song", ROM0
NextSong:: ; advance to the next song, wrapping around to the first if nescessary
	ldh a, [hCurrentSong]
	inc a
	cp NUMBER_OF_SONGS  ;did we just pass the last song?
	jr c, .noWrap
	;if so, go back to the start
	xor a
.noWrap
	ldh [hCurrentSong], a
	; fall through to get the new song playing!

ChangeSong::
	call FadeOut
	;get the pointer into the image table
	ldh a, [hCurrentSong]
	;the entries are 6 bytes long, so multiply by 6
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


	ld hl, $8000

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
	
	call FadeIn

	; play the song
	ldh a, [hCurrentSong]
	di
	call LsdjPlaySong
	reti ;ei/ret















SECTION "fade out", ROM0

FADE_SPEED equ 20 ;number of frames to fade for
FadeOut:: ;fade BGP out to black
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

FadeIn:: ;fade BGP in from black
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



SECTION "Current Song", HRAM
hCurrentSong::
	db
hSongDone::
	db ;set to 1 when the song finishes

SECTION "load splash screen", ROM0 ;this is called by the header when the screen is off
LoadSplashScreen::
.loadTiles
	ld hl, $8000
	ld de, SplashTiles
	ld bc, SIZEOF("Splash Tiles")
	call Memcpy

.loadTilemap
	ld hl, $9800
	ld de, SplashTilemap
	ld c, SCRN_Y_B
.row
	ld b, SCRN_X_B
.byte
	ld a, [de]
	inc de
	ld [hl+], a
	dec b
	jr nz, .byte
	;move to the next row
	ld a, l
	add SCRN_VX_B - SCRN_X_B
	ld l, a
	adc h
	sub l
	ld h, a
	dec c
	jr nz, .row
	ret



SECTION "Splash Tiles", ROM0
SplashTiles:
INCBIN "res/splash.image"

SECTION "splash tilemap", ROM0
SplashTilemap:
INCBIN "res/splash.imagemap"

;include all the song data
INCLUDE "res/lsdj.song"
