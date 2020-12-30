
 TTF -> PGF font renderer
 ========================
 skylark@mips.for.ever

 INSTALLATION
 ~~~~~~~~~~~~
To build this tool you will need the FreeType2 TTF font rendering library.
Adjust the freetype.h header location (if necessary) in `build' and execute
the script. The required version is 2.1.10 (last stable at the time of
writing this file - required for bold/italic typeface synthesis).

It is very likely that this tool will NOT brick your PSP. There is no known
way of bricking the PSP by merely changing font images; even the few possible
buffer overflows in the font parser would be limited to userspace.

 USAGE
 ~~~~~
 ttf2pgf <source.ttf> <dest.pgf> [<face-options> [<shadow-options>]]

 * source.ttf is the source font file
 * dest.pgf is the result file (the one that will be created)
 * face-options is a string created from the following components:
   - <integer> : font size (height) in pixels
   - h<float>  : horizontal scaling factor
   - a<float>  : font advance scaling factor
   - b         : embolden
   - i         : italicize
 * shadow-options is a string created from the following components:
   - n         : no shadow (do not emit shadow records)
   - b<float>  : Gaussian blur filter radius
   - i<float>  : shadow intensity

 MKFONTSET
 ~~~~~~~~~
 * run ./mkfontset <sans.ttf> <serif.ttf>
 * a subdirectory, "fontmod", will be created, containing 16 PGF files with
   correct attributes (bold/italic/size/typeface) derived from the two TTF
   files

 KNOWN BUGS
 ~~~~~~~~~~
The tool is currently in alpha stage and wouldn't have been released if many
people wouldn't have asked for it. Therefore it still has bugs:
 * advance widths can't exceed 35 units (rougly 17 pixels)
 * sometimes the PSP crashes (without long-term effects), especially if the
   generated fonts are small; it appears that PSP has problems rendering
   very small font bitmaps; if this is true, a workaround is expected
