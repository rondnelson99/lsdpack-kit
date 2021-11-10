# lsdpack-kit

An easy-to-use template for taking your songs made with [LSDJ](https://www.littlesounddj.com/lsd/index.php), and combining them with images you supply for each song. Additionally, you can have a splash screen that appears when the ROM is started.

## How does it work?
This project combines ISSOtm's excellent [gb-starter-kit](https://github.com/ISSOtm/gb-starter-kit) with jkotlinski's [lsdpack](https://github.com/jkotlinski/lsdpack). lsdpack converts LSDJ songs into a raw format that can be easily played back, and gb-starter-kit provides an automatic build system that can handle all the asset conversion.

## Downloading

Downloading this repository requires some extra care, due to it using submodules. (If you know how to handle them, nothing more is needed.)

### Use as a template

You can [make a new repository using this one as a template](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template) or click the green "Use this template" button near the top-right of this page.

### Cloning

If cloning this repo from scratch, make sure to pass the `--recursive` flag to `git clone`; if you have already cloned it, you can use `git submodule update --init` within the cloned repo.

If the project fails to build, and either `src/include/hardware.inc/` or `src/include/rgbds-structs/` are empty, try running `git submodule update --init`.

### Download ZIP

You can download a ZIP of this project by clicking the "Code" button next to the aforementioned green "Use this template" one. The resulting ZIP will however not contain the submodules, the files of which you will have to download manually.

## Setting up

This project requires a unix-like enviornment to run. I use Debian 11 on WSL, but I know that others have had success on linux. MacOS and other unix-like windows enviornments like Cygwin are untested. Additionally, you need RGBDS 0.5.1 or newer, make, and python. Put your LSDJ rom in src/res. When you build for the first time, it will compile lsdpack as well. This requires a C++ compiler and a relatively new version of CMake. I'm not sure of the exact minimum, but I use CMake 3.18.4.

## Customizing
In the project's root you'll see two config files: `kit_config.inc` and `kit_config.mk`. These contain a bunch of settings, and many comments explaining how to use them. The reason you have to deal with two separate files that use different syntaxes is because one is processed by `make` and the other by `rgbasm`. The basic idea is just to read through the two files and cutomize everything to your liking. I may add more options in the future. Let me know what you want to see! I won't make any promises but I'm open to ideas. 

## Compiling

Simply open you favorite command prompt / terminal, place yourself in this directory (the one the Makefile is located in), and run the command `make`. This should create a bunch of things, including the output in the `bin` folder.

If you get errors that you don't understand, try running `make clean`. If that gives the same error, try deleting the `deps` folder. If that still doesn't work, try deleting the `bin` and `obj` folders as well. If that still doesn't work, get in touch with me. I can usually be found on the gbdev discord, or just open an issue here.


