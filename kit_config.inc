; This file gets used by RGBASM to configure your lsdpack-kit project
; There are other options used when assembling the ROM as well, these are located in kit_config.inc
; The two files are only separated for technical reasons, so I'd recommend fully reading and customzing both.

; Here, you can pick the covers for each song. Use a comma-separated list of the png cover images in src/res, but don't include the .png
; optimally, you should use a 160x144 indexed color png, but you can often get away without indexed color.
; The number of entries in the list is also used to determine how many songs should play, so make sure it has the right amount.
def SONG_COVER_LIST equs "song1, song2, song3, song4" ;This sets src/res/song1.png as the first cover, and so on.

; Here, you can pick the splash screen. Again, use the name of the png file in src/res, but without the .png
def SPLASH_IMAGE equs "splash" ;this uses src/res/splash.png as the splash screen

; This picks the image file for the menu
def MENU_IMAGE equs "menu" ;this uses src/res/menu.png as the menu
; Now, define cursor positions for each song on the menu
def MENU_SONG_X_POSITIONS equs "28, 10, 49,  16 "
def MENU_SONG_Y_POSITIONS equs "74, 98, 116, 135"

; This picks the image file for the menu cursor
; The cursor images have a few requirements:
; - Must be a multiple of 16 px tall and 8 px wide (you can hide this limitation using transparency)
; - Only use 3 colors. 
; - They need to be formatted in a way that RGBGFX likes. 
;       You can use indexed color with color 0 treated as transparent,
;       or just regular RGB color with regular transparency. RGBGFX will assign lighter colors to lower indices I think.
def CURSOR_IMAGE equs "cursor" ; this uses src/res/cursor.png as the menu cursor
; Set your chosen dimensions as well
def CURSOR_IMAGE_WIDTH = 48
def CURSOR_IMAGE_HEIGHT = 48
; Define the cursor's "target". The cursor will be positioned so that it's target is at the song position
; The target is allowed to be outside of the sprite area, and can be negative
def CURSOR_TARGET_X = 47
def CURSOR_TARGET_Y = 29

; Define your palette for color indices 1-3
; For each of the below lines, write a number from 0 (white) to 3 (black)
def SPRITE_PALETTE_INDEX_1 = 0
def SPRITE_PALETTE_INDEX_2 = 1
def SPRITE_PALETTE_INDEX_3 = 2


