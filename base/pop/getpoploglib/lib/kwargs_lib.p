compile_mode :pop11 +strict;

section $-kwargs =>
    pop_kwargs_top_mark,
    pop_kwargs_bottom_mark
    ;

#_IF not(DEF pop_kwargs_mark_key)
;;; We do not want this re-executed, so we protect it behind this #_IF check.

constant pop_kwargs_mark_key = conskey( "pop_kwargs_mark", [full] );
constant pop_kwargs_top_mark = class_cons( pop_kwargs_mark_key )( "TOP" );
constant pop_kwargs_bottom_mark = class_cons( pop_kwargs_mark_key )( "BOTTOM" );

;;; Syntactic separators.
constant
    KWARGS_INTRO = "-&-",
    KEY_VALUE_SEPARATOR = "=",
    RENAME_SEPARATOR = "/"
;

#_ENDIF

endsection;