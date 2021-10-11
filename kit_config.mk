# this file contains various setting used when building the lsdpack-kit ROM. 
# There are other options used when assembling the ROM as well, these are located in kit_config.inc
# The two files are only separated for technical reasons, so I'd recommend fully reading and customzing both.

# Game title, up to 11 ASCII chars
# This is often used by emulators to show a title for your ROM. For instance, bgb puts it in the window title.
TITLE := LSDPACK

# ROM file name
# format will be ROMNAME.ROMEXT
ROMNAME := lsdpack
ROMEXT  := gb

# LSDJ roms
# here you should put a space-separated list of all your LSDJ roms
LSDJ_ROMS := src/res/lsdj.gb
