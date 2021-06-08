/* --- Copyright GetPoplog (c) 2021.  All rights reserved. ----------------
 > File:            C.all/lib/ved/term/vedxterm_256colorscreen.p
 > Author:          Stephen Leach
 > Documentation:   HELP * VEDXTERM
 > Related Files:   LIB * VEDXTERM_256COLORKEYS, * VEDXTERMKEYS
 */
compile_mode :pop11 +strict;

/*
 *  This is a synonym of xterm.
 */

section;
uses vedxtermscreen;

define lconstant vedxterminit();
    lvars row, col;
    if (vedxtermsize() ->> row) then
        -> col;
        unless vedchecksize(row, col) then
            vedresize(row, col, false);
        endunless;
    endif;
enddefine;

define vedxterm_256colorscreen();
    returnif(vedterminalname == "xterm_256term");
    vedvt100screen();
    "xterm_256term" -> vedterminalname;
    ;;; default window size
    34 -> vedscreenlength;
    80 -> vedscreenwidth;
    true -> vedscreenwrap;
    ;;; reset window size each time ved is entered
    vedxterminit -> vvedscreeninit;
    ;;; extra features over a basic vt100
    vedset screen;
    /*
        insertchar  = esc [ @
        deletechar  = esc [ P
    */
        insertline  = esc [ L
        deleteline  = esc [ M
    endvedset;
enddefine;

endsection;


/* --- Revision History ---------------------------------------------------
--- Stephen Leach, Jun 08 2021
        Basic implementation copied from vedxtermscreen
 */
