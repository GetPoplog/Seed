;;;
;;; This file contains the essential shared-core for named-argument
;;; groups. It is typically loaded with
;;;     uses pop11_named_arg_mark
;;;

compile_mode :pop11 +strict;

section $-gospl$-named_args =>
    pop11_named_arg_mark
    ;

#_IF not(DEF pop11_named_arg_mark)
;;; We do not want this re-executed, so we protect it behind this #_IF check.
constant pop11_named_arg_mark = conskey( "pop11_named_arg_mark", [] ).class_cons.apply;
#_ENDIF

;;; Syntactic separators.
constant
    key_value_separator = "=",
    rename_separator = "/"
;

;;; Variable/Keyword pairs
constant procedure(
    new_vk = conspair,
    vk_variable = front,
    vk_keyword = back
);

#_IF false

;;;
;;; This is an attempt to arrange that the preferred order
;;; of keywords when calling is the same as the order of
;;; declaration.  What we do is track the order of appearance
;;; of keywords and use that as the basis for sorting.
;;; Crude, it is true, but better than just plain sort.
;;;
vars next_count = 0;
constant procedure order_of_appearance = (
    newanyproperty(
        [], 8, 1, false,
        false, false, "perm",
        false,
        procedure( kw, self );
            next_count + 1 ->> next_count ->> self( kw )
        endprocedure
    )
);

define ascending( kw1, kw2 );
    kw1.order_of_appearance <= kw2.order_of_appearance
enddefine;

define descending( kw1, kw2 );
    kw1.order_of_appearance >= kw2.order_of_appearance
enddefine;

#_ELSE

constant procedure
    ascending = alphabefore,
    descending = alphabefore <> not;

#_ENDIF


endsection;
