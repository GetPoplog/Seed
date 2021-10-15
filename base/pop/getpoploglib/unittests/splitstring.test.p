;;; --- Anonymous tests ---

define :unittest;
    ;;; Act
    lvars actual = splitstring( 'abc|def|ghi', '|' );
    ;;; Assert
    assert { 'abc' 'def' 'ghi' } = actual;
enddefine;

;;; --- with_data tests ---

with_data
    [ '' ','                    {''} ]
    [ '' ',' ^false ^consvector {''} ]
    [ 'abc' ','                 {'abc'} ]
    [ ',' ','                   {'' ''} ]
    [ ',' `,`                   {'' ''} ]
    [ 'abc,' ','                {'abc' ''} ]
    [ 'abc--def' '--'           {'abc' 'def'} ]
    [ 'abc----def' '--'         {'abc' '' 'def'} ]
    [ 'abc----def' '--'         {'abc' '' 'def'} ]
    [ 'abc--def--ghi' '--'      {'abc' 'def' 'ghi'} ]
    [ '---abc--def--ghi' '--'   {'' '-abc' 'def' 'ghi'} ]
    [ 'a b c' ' ' ^false ^conslist  ['a' 'b' 'c'] ]
    [ 'a b c' ' ' 1 ^conslist   ['a' 'b c'] ]
define :unittest( expected );
    ;;; Act
    lvars actual = splitstring( /*stack*/ );
    ;;; Assert
    assert actual = expected;
enddefine;

;;; --- Named tests ---

define :unittest test_splitstring_nested;

    define :unittest test_splitstring_regexp();
        ;;; Arrange
        lvars ( _, regexp_p ) = regexp_compile( '@[,;@]' );
        ;;; Act
        lvars actual = splitstring( 'abc,def;ghi', regexp_p );
        ;;; Assert
        assert actual = { 'abc' 'def' 'ghi' };
    enddefine;

    define :unittest test_splitstring_regexp_conslist();
        ;;; Arrange
        lvars ( _, regexp_p ) = regexp_compile( '@[,;@]' );
        ;;; Act
        lvars actual = splitstring( 'abc,def;ghi', regexp_p, false, conslist );
        ;;; Assert
        assert actual = [ 'abc' 'def' 'ghi' ];
    enddefine;

    define :unittest test_splitstring_regexp_conslist_max1();
        ;;; Arrange
        lvars ( _, regexp_p ) = regexp_compile( '@[,;@]' );
        ;;; Act
        lvars actual = splitstring( 'abc,def;ghi', regexp_p, 1, conslist );
        ;;; Assert
        assert actual = [ 'abc' 'def;ghi' ];
    enddefine;

enddefine;


;;; --- expect_mishap tests ---

define :unittest;
    dlocal expect_mishap = true;
    splitstring( "wordsarenotstrings", `,` ) -> _;
enddefine;
