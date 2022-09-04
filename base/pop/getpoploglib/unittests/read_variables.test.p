compile_mode :pop11 +strict;

section;

define :unittest no_variables_to_termin();
    dlocal proglist = [];
    assert read_variables() == [];
enddefine;

define :unittest no_variables_to_semi();
    dlocal proglist = [;];
    assert read_variables() == [];
enddefine;

define :unittest no_variables_to_close_parenthesis();
    dlocal proglist = [)];
    assert read_variables() == [];
enddefine;

define :unittest one_variables_no_comma();
    dlocal proglist = [x];
    assert read_variables() = [x];
enddefine;

define :unittest one_variables_with_commas();
    dlocal proglist = [,x,];
    assert read_variables() = [x];
enddefine;

define :unittest two_variables_with_many_commas();
    dlocal proglist = [,x,,,y];
    assert read_variables() = [x y];
enddefine;






endsection;
