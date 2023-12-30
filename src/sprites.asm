INCLUDE "defines.asm"

SECTION "Shadow OAM", WRAM0, ALIGN[8]
wShadowOAM::
    ds 4 * NB_SPRITES

SECTION "Sprite HRAM", HRAM
hSpriteIndex:
    db ; Holds the index of the next sprite slot to use, 0-39

SECTION "ClearSprites", ROM0
ClearSprites:: ; Clear all sprites to start the next frame

    xor a
    ld b, NB_SPRITES
    ld hl, wShadowOAM
.loop
    ld [hl+], a ; zero the Y coordiante
    inc l
    inc l
    inc l
    dec b
    jr nz, .loop

    ldh [hSpriteIndex], a
    ret

SECTION UNION "Scratchpad", HRAM
tileNumber: db
OAMFlags: db
height: db


SECTION "Render Metasprite", ROM0
; Renders a sprite relative to the screen
; Params: 
;         B: Y Position
;         C: X Position
;         D: Width (in 8x16 tiles)
;         E: Height (in 8x16 tiles)
;         H: Upper-left Tile Number (tiles are arranged column-major)
;         L: OAM Flags (for each sprite)
RenderMetasprite::
    push de ; save dimensions to adjust tile number later
        ld a, h
        ldh [tileNumber], a
        ld a, l
        ldh [OAMFlags], a ; free up some registers

        ld a, e
        ldh [height], a ; save for looping

        ldh a, [hSpriteIndex]
        add a
        add a
        ld l, a
        ld h, HIGH(wShadowOAM) ; Get Shadow OAM pointer

        ld a, b ; Adjust positions with offsets
        add OAM_Y_OFS
        ld b, a

        ld a, c
        add OAM_X_OFS
        ld c, a
.columnLoop
        push bc ; save starting positions for new line

.tileLoop
            ld a, b
            ld [hl+], a ; Y
            add 16 ; sprite height
            ld b, a
            
            ld a, c
            ld [hl+], a ; X

            ldh a, [tileNumber]
            ld [hl+], a ; Tile
            add 2 ; double increment since this is 8x16 mode
            ldh [tileNumber], a

            ld a, e
            ld [hl+], a ; Flags

            dec e ;column
            jr nz, .tileLoop

            ld a, c
            add 8 ; sprite width
        pop bc ; restore Y
        ld c, a ; but not X
        ldh a, [height]
        ld e, a

        dec d
        jr nz, .columnLoop
    ; Now just adjust the sprite index for furture sprites
    pop bc
    ldh a, [hSpriteIndex]
    ; add b*c to a. C (height) is probably smaller
.indexLoop
    add b
    dec c
    jr nz, .indexLoop

    ldh [hSpriteIndex], a

    ret


    



        
            













        

        




