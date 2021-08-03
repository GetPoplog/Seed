#!/usr/bin/python3
import os
import re
import glob
import subprocess
import pytest
from pathlib import Path

here = Path( os.path.realpath( __file__ ) ).parent

@pytest.mark.parametrize("in_file_name", glob.glob(f"{here.absolute()}/poplog_commander_tests/*.test.sh"))
def test_poplog_commander(in_file_name):
    expected_file_name = re.sub( r'\.test\.sh$', r'.expected.txt', in_file_name )
    res = subprocess.getoutput( f"/bin/bash {in_file_name}" )
    with open( expected_file_name, 'r' ) as exp:
        assert exp.read().strip() == res.strip()
