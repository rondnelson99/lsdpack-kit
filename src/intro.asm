INCLUDE "defines.asm"

SECTION "Current Song", HRAM
hCurrentSong::
	db
hSongDone::
	db ;set to 1 when the song finishes
hCurrentState::
DEF CURRENT_STATE_BIT_PAUSE = 0
DEF CURRENT_STATE_BIT_MENU = 1
	db

SECTION "Intro", ROM0

Intro::
	xor a
	ldh [hCurrentSong], a

	call InitMenu
    call InitPlayerLYC

def SPLASH_TIMEOUT equ 5 * 60
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

	xor a
	ldh [hCurrentState], a
	
	call ShowSongImage
	call ChangeSong


MainLoop:
	call ClearSprites

	ldh a, [hCurrentState]
	bit CURRENT_STATE_BIT_MENU, a
	call nz, UpdateMenu


	; Controls: A - Pause (off-menu) / Exit menu (on-menu)
	; Right/down - Next Song
	; left/up - Previous Song
	; Controls: B - toggle menu
	ldh a, [hPressedKeys]
	and PADF_RIGHT | PADF_DOWN
	call nz, NextSong

	ldh a, [hPressedKeys]
	and PADF_LEFT | PADF_UP
	call nz, PreviousSong

	ldh a, [hPressedKeys]
	bit PADB_B, a
	call nz, ToggleMenu

	ldh a, [hPressedKeys]
	bit PADB_A, a
	jr z, .noAPress

	ldh a, [hCurrentState]
	bit CURRENT_STATE_BIT_MENU, a
	call nz, ToggleMenu
	jr .noAPress
	call TogglePause

.noAPress
	;if hSongDone is 1, switch to the next song and zero it

	ldh a, [hSongDone]
	dec a
	jr nz, .done

	call NextSong
	xor a
	ldh [hSongDone], a


.done
	ld a, HIGH(wShadowOAM)
	ldh [hOAMHigh], a

	rst WaitVBlank
	jr MainLoop

SECTION "Toggle Pause", ROM0
TogglePause:
	ldh a, [hCurrentState]
	xor $01 ; toggle the pause bit
	ldh [hCurrentState], a
	bit 0, a
	jp nz, PauseSong ; tail calls
	jp ResumeSong

SECTION "Toggle Menu", ROM0
ToggleMenu:
	ldh a, [hCurrentState]
	xor %10 ; toggle the menu bit
	ldh [hCurrentState], a
	bit CURRENT_STATE_BIT_MENU, a
	jp nz, ShowMenu ; tail calls
	jp ShowSongImage

SECTION "Change Song", ROM0
PreviousSong::
	; return to the previous song, wrappign around to the first if nescessary
	ldh a, [hCurrentSong]
	and a ; Are we playing song zero?
	jr nz, .noWrap
	; if so, go to the last song
	ld a, NUMBER_OF_SONGS
.noWrap
	dec a
	ldh [hCurrentSong], a
	jr ChangeSong


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

/*
 * loads up the next song. Non-blocking
*/ 
ChangeSong::
	; play the song
	ldh a, [hCurrentSong]
	di
	call LsdjPlaySong
	reti ;ei/ret

SECTION "Show Song Image", ROM0
ShowSongImage:: ; Shows the image for the current song. Blocking
	call FadeOut
	;get the pointer into the image table
	ldh a, [hCurrentSong]
	call LoadImage
	
	call FadeIn
	ret



SECTION "load splash screen", ROM0 ;this is called by the header when the screen is off
LoadSplashScreen::
	ld a, SPLASH_IMAGE_INDEX
	call LoadImage
	ret

;include all the song data
INCLUDE "res/lsdj.song"
