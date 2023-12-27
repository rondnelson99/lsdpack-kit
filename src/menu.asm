INCLUDE "defines.asm"

SECTION "Init Menu", ROM0
/*
 * Call at startup before showing menu. Inits the VWF Engine and loads the appropriate tiles for the Window 
 */
InitMenu::
    ld a, LOW(LYCTable)
    ld hl, wLYCTableAddress
    ld [hl+], a
    ld [hl], HIGH(LYCTable)

    ret


