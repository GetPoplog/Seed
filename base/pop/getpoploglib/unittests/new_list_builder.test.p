
define :unittest test_new_list_builder;

    define :unittest empty;
        ;;; Arrange
        lvars b = new_list_builder();
        ;;; Act
        lvars L = b( termin );
        lvars M = b( termin );
        ;;; Assert
        assert L == nil;
        assert M == nil;
    enddefine;

    define :unittest some;
        ;;; Arrange
        lvars b = new_list_builder();
        lvars items = [ a b c ];
        applist( items, b );
        ;;; Act
        lvars L = b( termin );
        lvars M = b( termin );
        ;;; Assert
        assert L = items;
        assert L /== items;
        assert M == nil;
    enddefine;

    define :unittest is;
        ;;; Arrange
        lvars banana = "banana";
        lvars b = new_list_builder();
        ;;; Act
        lvars banana_is = is_list_builder( banana );
        lvars b_is = is_list_builder( b );
        ;;; Assert
        assert banana_is.not;
        assert b_is;
    enddefine;

enddefine;
