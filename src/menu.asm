INCLUDE "defines.asm"

SECTION "Init Menu", ROM0
/*
Preps the menu for future loading
*/
InitMenu::
    ld hl, $8000 ; load the cursor tiles
	ld de, CursorTiles
	ld bc, CursorTilesEnd - CursorTiles
	call LCDMemcpy

    ld a, SPRITE_PALETTE_INDEX_3 << 6 | SPRITE_PALETTE_INDEX_2 << 4 | SPRITE_PALETTE_INDEX_1 << 2
    ldh [hOBP0], a ; Set the user-defined palette
    ret

SECTION "Show Menu", ROM0
/*
 * Performs a fade-to-black and loads up the menu
*/ 
ShowMenu::
    call FadeOut
    ld a, MENU_IMAGE_INDEX
    call LoadImage
    call FadeIn
    ret

SECTION "Update Menu", ROM0
/*
Updates the menu. Call every frame when menu is showing
*/
UpdateMenu::
    ; render the cursor
    ;get the YX position into BC
    ldh a, [hCurrentSong]
    ld hl, CursorPositionXTable
    add l
    ld l, a
    adc h
    sub l
    ld h, a
    ld a, [hl] ; get the X position
    sub CURSOR_TARGET_X
    ld c, a

    ldh a, [hCurrentSong]
    ld hl, CursorPositionYTable
    add l
    ld l, a
    adc h
    sub l
    ld h, a
    ld a, [hl] ; get the Y position
    sub CURSOR_TARGET_Y
    ld b, a

	lb de, 6, 3 ; width/height
	lb hl, 0, 0 ; tile number / flags
	call RenderMetasprite
    ret



SECTION "Cursor position Tables", ROM0
CursorPositionXTable:
db MENU_SONG_X_POSITIONS
CursorPositionYTable:
db MENU_SONG_Y_POSITIONS

SECTION "Cursor tiles", ROM0
CursorTiles:
    INCBIN "res/cursor.spritetiles"
CursorTilesEnd: