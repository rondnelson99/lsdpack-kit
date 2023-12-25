INCLUDE "defines.asm"

MACRO CoverImage
SECTION "Cover Image Data \@", ROMX
CoverImageData\@:
INCBIN "res/\1.image"
CoverImageDataEnd\@:
CoverImageTilemap\@:
INCBIN "res/\1.imagemap"
SECTION FRAGMENT "Image Table", ROM0
    dw CoverImageData\@
    dw BANK("Cover Image Data \@")
    dw CoverImageDataEnd\@ - CoverImageData\@ ;size of tile data
ENDM



MACRO CoverImageTable
def NUMBER_OF_SONGS equ _NARG
    EXPORT NUMBER_OF_SONGS
    REPT _NARG
        CoverImage \1 ;add a coverImage entry for each argument
        SHIFT
    ENDR
ENDM


SECTION FRAGMENT "Image Table", ROM0, ALIGN[8] ;for each song, contains a pointer to the cover's tile data, followed by the tilemap.
ImageTable::
    CoverImageTable {SONG_COVER_LIST} ;call the macro below using the song list provided in kit_config.inc

