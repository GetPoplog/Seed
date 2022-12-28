;;; Summary: character repeater to line repeater

/**************************************************************************\
Contributor                 Steve Knight
Date                        20 Oct 91
Description
    Convert a character repeater to a line repeater.
\**************************************************************************/

compile_mode :pop11 +strict;

section;

define incharline( procedure r );
    lconstant terminator = identfn(% termin %);
    procedure();
        lvars count = 0;
        repeat
            lvars c = r();
            if c == `\n` do
                consstring(count);
                quitloop
            elseif c == termin do
                if count == 0 then
                    termin
                else
                    ;;; Poplog guarantees that all end-of-files are
                    ;;; preceded by end-of-lines.  However, I do not wish
                    ;;; to rely on this undocumented fact & have put this
                    ;;; line in as protection.
                    consstring( count );
                    terminator -> r;
                endif;
                quitloop
            else
                c;
                count fi_+ 1 -> count;
            endif;
        endrepeat;
    endprocedure
enddefine;

endsection;
