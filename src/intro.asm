
SECTION "Intro", ROM0

Intro::


	; setup timer
	ld  a,256-183
	ldh [6],a   ; TMA
	ld  a,6
	ldh [7],a   ; TAC
	ld  a,4
	ldh [$ff],a ; IE

	; play song 0
	xor a
	ld  e,a ; e = song
	call LsdjPlaySong
	ei

	jr @





	INCLUDE "res/lsdj.song"