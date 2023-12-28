INCLUDE "defines.asm"

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
