#   This tests whether passing NAME=VALUE adds and changes variables.
export popcom=/nosuchfile
poplog --run FOO=BAR poplib=/eatmyshorts pop11 ":maplist(['FOO' 'poplib' 'popcom' 'NOTDEFINED'], systranslate)=>"