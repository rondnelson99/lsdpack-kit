; lsdpack - standalone LSDj (Little Sound Dj) recorder + player {{{
; Copyright (C) 2018  Johan Kotlinski - Modified by Ron Nelson
; https://www.littlesounddj.com
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License along
; with this program; if not, write to the Free Software Foundation, Inc.,
; 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA. }}}

INCLUDE "defines.asm"

SECTION "Init Player LYC", ROM0
; Initialized the player/LYC system. Call this before LSDJPlaySong
InitPlayerLYC::
    ld de, PlayerLYCTable
    jp InitLYC ; tail call


SECTION "Player LYC Table", ROM0
PlayerLYCTable:: ; calls SoundTick 6 times per frame, evenly spaced out across scanlines
    db 1
    dw LYCSongTick
    db 23
    dw LYCSongTick
    db 52
    dw LYCSongTick
    db 78
    dw LYCSongTick
    db 104
    dw LYCSongTick
    db 129
    dw LYCSongTick
    db $FF

SECTION "LYCSongTick", ROM0
; LYC interrupt to perform song tick. handles register preservation with LYC system
LYCSongTick::
    ldh a, [hSongDone]
	dec a
	jr z, .skipTick ;if the song is done, stop playing it

    call LsdjTick

	;restore the ROM bank
	ldh a, [hCurROMBank]
	ld [rROMB0], a
	ldh a, [hCurROMBank + 1]
	ld [rROMB1], a

.skipTick
	ld   hl, rSTAT
    ; Wait until Mode is -NOT- 0 or 1
.waitNotBlank
    bit  1, [hl]
    jr   z, .waitNotBlank
    ; Wait until Mode 0 or 1 -BEGINS- (but we know that Mode 0 is what will begin)
.waitBlank
    bit  1, [hl]
    jr   nz, .waitBlank

    pop de
    pop bc
	pop hl
	pop af
	reti


SECTION "player", ROM0


; Starts playing a song. If a song is already playing,
; make sure interrupts are disabled when calling this.
;
; IN: a = song number
;
LsdjPlaySong::
    ld  [Song],a

    ld  hl,SongLocations
    add a,a
    add a,a
    add a,l
    ld  l,a

    ld  de,CurrentBank
    ld  a,[hl+]
    ld  [de],a  ; CurrentBank
    inc de
    ld  a,[hl+]
    ld  [de],a  ; CurrentBank + 1
    inc de
    ld  a,[hl+]
    ld  [de],a  ; CurrentPtr
    inc de
    ld  a,[hl+]
    ld  [de],a  ; CurrentPtr + 1

    xor a
    ldh [hSongDone], a ; song is not done
    ldh [$26],a ; stop sound
    ld  [RepeatCmdCounter],a

    
    xor a
    ldh [rIF], a ; clear any pending STAT interrupt

    ldh a, [rIE]
    or IEF_STAT
    ldh [rIE], a ; enable STAT interrupt

    ret

def CMD_END_TICK        = 0
def CMD_SAMPLE_START    = 1
def CMD_SONG_STOP       = 2
def CMD_NEXT_BANK       = 3
def CMD_AMP_DEC_PU0     = 4
def CMD_AMP_DEC_PU1     = 5
def CMD_AMP_DEC_NOI     = 6
def CMD_PITCH_PU0       = 7
def CMD_PITCH_PU1       = 8
def CMD_PITCH_WAV       = 9
def CMD_SAMPLE_NEXT     = 10

; Call this six times per screen update,
; evenly spread out over the screen.
;
LsdjTick::

.tick
    ld  a,[CurrentBank+1]
    ld  [$3000],a
    ld  a,[CurrentBank]
    ld  [$2000],a
    ld  a,[CurrentPtr+1] ; hl = ptr
    ld  h,a
    ld  a,[CurrentPtr]
    ld  l,a

    xor a
    ld  b,a ; b = last read command byte

.loop
    bit 7,b
    jr  nz,.lyc_done

    ; load repeated cmd
    ld  a,[RepeatCmdCounter]
    or  a
    jr  z,.load_new_cmd_from_stream
    dec a
    ld  [RepeatCmdCounter],a
    ld  a,[RepeatCmd]
    jr  .apply_cmd

.load_new_cmd_from_stream
    ld  a,[hl+]
    bit 6,a
    jr  z,.apply_cmd

    ; save repeated cmd
    and ~$40
    ld  [RepeatCmd],a
    ld  b,a
    ld  a,[hl+]
    ld  [RepeatCmdCounter],a
    ld  a,b

.apply_cmd
    ld  b,a
    and $3f
    jr  z,.lyc_done
    cp  10
    jp  z,.sample_next
    jr  c,.is_command

    ; write sound register
    ld  c,a
    ld  a,[hl+]
    ldh [c],a
    jr  .loop

.is_command
    cp  CMD_SAMPLE_START
    jp  z,.sample_start
    cp  CMD_AMP_DEC_PU0
    jr  z,.amp_dec_pu0
    cp  CMD_AMP_DEC_PU1
    jr  z,.amp_dec_pu1
    cp  CMD_AMP_DEC_NOI
    jr  z,.amp_dec_noi
    cp  CMD_PITCH_PU0
    jr  z,.pitch_pu0
    cp  CMD_PITCH_PU1
    jr  z,.pitch_pu1
    cp  CMD_PITCH_WAV
    jr  z,.pitch_wav
    cp  CMD_NEXT_BANK
    jr  z,.next_bank
    cp  CMD_SONG_STOP
    jr  z,.handle_song_stop

.lyc_done
    ld  a,l
    ld  [CurrentPtr],a
    ld  a,h
    ld  [CurrentPtr+1],a
    ret

.handle_song_stop:
    ld a, 1
    ldh [hSongDone], a ;signal to the main context that it's time to switch songs

    jr  .lyc_done

.amp_dec_pu0:
    ld  a,9
    ldh [$12],a
    ld  a,$11
    ldh [$12],a
    ld  a,$18
    ldh [$12],a
    jp  .loop

.amp_dec_pu1:
    ld  a,9
    ldh [$17],a
    ld  a,$11
    ldh [$17],a
    ld  a,$18
    ldh [$17],a
    jp  .loop

.amp_dec_noi:
    ld  a,9
    ldh [$21],a
    ld  a,$11
    ldh [$21],a
    ld  a,$18
    ldh [$21],a
    jp  .loop

.pitch_pu0:
    ld  a,[hl+]
    ldh [$13],a
    ld  a,[hl+]
    ldh [$14],a
    jp  .loop

.pitch_pu1:
    ld  a,[hl+]
    ldh [$18],a
    ld  a,[hl+]
    ldh [$19],a
    jp  .loop

.pitch_wav:
    ld  a,[hl+]
    ldh [$1d],a
    ld  a,[hl+]
    ldh [$1e],a
    jp  .loop

.next_bank:
    ld  a,$40
    ld  h,a
    xor a
    ld  l,a

    ld  a,[CurrentBank]
    inc a
    ld  [CurrentBank],a
    ld  [$2000],a
    jp  nz,.loop
    ld  a,[CurrentBank+1]
    inc a
    ld  [CurrentBank+1],a
    ld  [$3000],a
    ; Reapply LSB in case of non-MBC5 cartridge.
    ld  [CurrentBank],a
    ld  [$2000],a
    jp  .loop

.sample_start:
    push    de
    ld  a,[hl+]
    ld  c,a     ; c = sample bank
    ld  [SampleBank],a
    ld  a,[hl+]
    ld  e,a
    ld  a,[hl+]
    ld  d,a     ; de = sample ptr

    push    hl
    ; switch bank
    xor a
    ld  [$3000],a
    ld  a,c
    ld  [$2000],a

    ld  h,d
    ld  l,e

    ; disable wave channel output
    ldh a,[$25]
    ld  e,a
    and a,~$44
    ldh [$25],a

    xor a
    ldh [$1a],a ; mute channel

    ld  a,[hl+]
    ldh [$30],a
    ld  a,[hl+]
    ldh [$31],a
    ld  a,[hl+]
    ldh [$32],a
    ld  a,[hl+]
    ldh [$33],a
    ld  a,[hl+]
    ldh [$34],a
    ld  a,[hl+]
    ldh [$35],a
    ld  a,[hl+]
    ldh [$36],a
    ld  a,[hl+]
    ldh [$37],a
    ld  a,[hl+]
    ldh [$38],a
    ld  a,[hl+]
    ldh [$39],a
    ld  a,[hl+]
    ldh [$3a],a
    ld  a,[hl+]
    ldh [$3b],a
    ld  a,[hl+]
    ldh [$3c],a
    ld  a,[hl+]
    ldh [$3d],a
    ld  a,[hl+]
    ldh [$3e],a
    ld  a,[hl+]
    ldh [$3f],a

    ld  a,l
    ld  [SampleAddress],a
    ld  a,h
    ld  [SampleAddress+1],a

    ld  a,$80 ; unmute
    ldh [$1a],a

    pop     hl

    ld  a,[CurrentBank+1]
    ld  [$3000],a
    ld  a,[CurrentBank]
    ld  [$2000],a

    ld  a,[hl+]
    ldh [$1e],a
    ld  [SamplePitchMsb],a
    ld  a,[hl+]
    ldh [$1d],a

    ld  a,e
    ldh [$25],a

    pop de
    jp  .loop

.sample_next:
    push    de
    ld  a,[SampleBank]
    ld  c,a     ; c = sample bank
    ld  a,[SampleAddress]
    ld  e,a
    ld  a,[SampleAddress+1]
    ld  d,a     ; de = sample ptr

    push    hl
    ; switch bank
    xor a
    ld  [$3000],a
    ld  a,c
    ld  [$2000],a

    ld  h,d
    ld  l,e

    ; disable wave channel output
    ldh a,[$25]
    ld  e,a
    and a,~$44
    ldh [$25],a

    xor a
    ldh [$1a],a ; mute channel

    ld  a,[hl+]
    ldh [$30],a
    ld  a,[hl+]
    ldh [$31],a
    ld  a,[hl+]
    ldh [$32],a
    ld  a,[hl+]
    ldh [$33],a
    ld  a,[hl+]
    ldh [$34],a
    ld  a,[hl+]
    ldh [$35],a
    ld  a,[hl+]
    ldh [$36],a
    ld  a,[hl+]
    ldh [$37],a
    ld  a,[hl+]
    ldh [$38],a
    ld  a,[hl+]
    ldh [$39],a
    ld  a,[hl+]
    ldh [$3a],a
    ld  a,[hl+]
    ldh [$3b],a
    ld  a,[hl+]
    ldh [$3c],a
    ld  a,[hl+]
    ldh [$3d],a
    ld  a,[hl+]
    ldh [$3e],a
    ld  a,[hl+]
    ldh [$3f],a

    ld  a,$80 ; unmute
    ldh [$1a],a

    ld  a,[SamplePitchMsb]
    ldh [$1e],a

    ld  a,e
    ldh [$25],a

    ld  a,[CurrentBank+1]
    ld  [$3000],a
    ld  a,[CurrentBank]
    ld  [$2000],a

    ld  a,l
    ld  [SampleAddress],a
    ld  a,h
    ld  [SampleAddress+1],a

    pop hl
    pop de
    jp  .loop


SECTION "player_ram",WRAM0

Song:
    ds  1
CurrentBank:
    ds  2
CurrentPtr:
    ds  2
SampleBank:
    ds  1
SampleAddress:
    ds  2
SamplePitchMsb:
    ds  1
RepeatCmd:
    ds  1
RepeatCmdCounter:
    ds  1
