
define :unittest;
enddefine;

define :unittest hello;
    ;;; This is a pass
enddefine;

define :unittest hiya;
enddefine;

define :unittest hi;
enddefine;

define :unittest byebye;
    fail_unittest()
enddefine;
