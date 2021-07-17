#!/usr/bin/python3
import os
import re
import glob
import subprocess
from pathlib     import Path

here = Path( os.path.realpath( __file__ ) ).parent

def runtest( in_file_name ):
    expected_file_name = re.sub( r'\.test\.sh$', r'.expected.txt', in_file_name )
    res = subprocess.getoutput( f"/bin/sh {in_file_name}" )
    with open( expected_file_name ) as exp:
        assert res.strip() == exp.read().strip()

def test_examples():
    for in_file_name in glob.glob( "poplog_commander/*.test.sh" ):
        yield runtest, in_file_name

