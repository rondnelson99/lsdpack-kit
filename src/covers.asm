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
    REPT _NARG
        CoverImage \1 ;add a coverImage entry for each argument
        SHIFT
    ENDR
ENDM

MACRO CountSongs
    def NUMBER_OF_SONGS equ _NARG
    EXPORT NUMBER_OF_SONGS
ENDM

    CountSongs {SONG_COVER_LIST}

SECTION FRAGMENT "Image Table", ROM0, ALIGN[8] ;for each song, contains a pointer to the cover's tile data, followed by the tilemap.
ImageTable::
    CoverImageTable {SONG_COVER_LIST} ;call the macro below using the song list provided in kit_config.inc
    
    CoverImage {MENU_IMAGE}
    def MENU_IMAGE_INDEX = NUMBER_OF_SONGS
    EXPORT MENU_IMAGE_INDEX
    
    CoverImage {SPLASH_IMAGE}
    def SPLASH_IMAGE_INDEX = NUMBER_OF_SONGS + 1
    EXPORT SPLASH_IMAGE_INDEX


