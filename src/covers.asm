
NUMBER_OF_SONGS equ 6 ;MAKE SURE THIS IS SET PROPERLY
export NUMBER_OF_SONGS

MACRO CoverImage
SECTION "Cover Image Data \@", ROM0
CoverImageData\@:
INCBIN "res/\1.image"

SECTION "Cover Image Tilemap \@", ROM0
CoverImageTilemap\@:
INCBIN "res/\1.imagemap"

SECTION FRAGMENT "Image Table", ROM0
    dw CoverImageData\@
    dw SIZEOF("Cover Image Data \@")
    dw CoverImageTilemap\@
ENDM

INCLUDE "defines.asm"
SECTION FRAGMENT "Image Table", ROM0, ALIGN[8] ;for each song, contains a pointer to the cover's tile data, followed by the tilemap.

;Define Cover Images Here, in order of song numbers. As an argument, supply the name of the .png file in 
ImageTable::
    CoverImage song1 ;this sets src/res/song1.png as the cover for the first song
    CoverImage song2
    CoverImage song3
    CoverImage song4
    CoverImage song5
    CoverImage song6