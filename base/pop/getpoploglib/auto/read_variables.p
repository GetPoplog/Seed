compile_mode :pop11 +strict;

section;

;;; reads a (optionally comma separated) list of ordinary variables from
;;; the input stream.
define read_variables();
    [%
        repeat
            quitif( proglist.null );
            lvars item = proglist.hd;
            quitunless( item.isword );
            if item == "," then
                readitem().erase;
                nextloop;
            endif;
            lvars id = identprops( item );
            quitunless(
                id.isnumber or
                id == "undef" or
                id == "procedure" or
                id == "macro"
            );
            readitem();
        endrepeat
    %]
enddefine;

endsection;
