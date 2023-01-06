compile_mode :pop11 +strict;

uses lvars_kwargs;

section $-kwargs =>
    define_kwargs
    ;

;;; We may assume that the header is correctly formatted as the more
;;; intensive checking is done in lvars_kwargs. If it is badly formatted we
;;; just bail early with a meaningless count - but that won't get used.
define get_kwargs_nargs( closer ) -> count;
    dlocal proglist;
    0 -> count;
    until pop11_try_nextreaditem( closer ) do
        lconstant closers_procedure_dlocal = [procedure dlocal];
        while pop11_try_nextreaditem( closers_procedure_dlocal ) do
            ;;; Skip
        endwhile;
        lvars variable = readitem();
        quitunless( variable.isword );
        nextif( variable == "," );
        lvars idprops = identprops( variable );
        quitunless( idprops == 0 or idprops == "undef" );
        count + 1 -> count
    enduntil;
enddefine;

;;;
;;; The strategy is macro-like. We rewrite proglist so as to move the 
;;; argument processing into a lvars_kwargs & then loop back to -define-. 
;;; The reason for doing this is that it is difficult to independently use the 
;;; available pop11_* planting procedures, which are too tightly bound to
;;; the standard grammar, and we must use these for quitloop and return to work.
;;;
define :define_form kwargs;

    define lconstant split_at( L, tok );
        lvars before = [%
            repeat 
                if null( L ) then
                    mishap( tok, 1, 'Missing expected item in header' )
                endif;
                lvars t = L.dest -> L;
                quitif( tok == t );
                t
            endrepeat
        %];
        return( before, L )
    enddefine;

    lvars header = [%
        repeat
            lvars item = readitem();
            quitif( item == ";" );
            item
        endrepeat 
    %];

    lvars ( prefix, rest ) = split_at( header, "(" );
    lvars ( params, suffix ) = split_at( rest, ")" );

    lvars nargs = (
        procedure( L );
            dlocal proglist = L;
            [proglistL ^L] =>
            get_kwargs_nargs( [ ^KWARGS_INTRO ) ] )
        endprocedure( params )
    );

    ;;; Now set up for the next round of -define-.
    [ ^^prefix ( ) ^^suffix with_nargs ^nargs; lvars_kwargs ^^params; ^^proglist ] -> proglist;

    nonsyntax define();
enddefine;

endsection;
