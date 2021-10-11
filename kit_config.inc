; This file gets used by RGBASM to configure your lsdpack-kit project
; There are other options used when assembling the ROM as well, these are located in kit_config.inc
; The two files are only separated for technical reasons, so I'd recommend fully reading and customzing both.

; Here, you can pick the covers for each song. Use a comma-separated list of the png cover images in src/res, but don't include the .png
; optimally, you should use a 160x144 indexed color png, but you can often get away without indexed color.
; The number of entries in the list is also used to determine how many songs should play, so make sure it has the right amount.
SONG_COVER_LIST equs "song1, song2, song3, song4" ;This sets src/res/song1.png as the first cover, and so on.

; Here, you can pick the splash screen. Again, use the name of the png file in src/res, but without the .png
SPLASH_IMAGE equs "splash" ;this uses src/res/splash.png as the splash screen