;;;
;;; This file contains the essential shared-core for named-argument
;;; groups. It is typically loaded with
;;;     uses pop11_named_arg_mark
;;;

compile_mode :pop11 +strict;

section $-gospl$-named_args =>
    pop11_named_arg_mark
    ;

constant named_arg_mark = 'NAMED ARGUMENT MARK';

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
#_ELSE
constant procedure order_of_appearance = identfn;
#_ENDIF


endsection;
