import subprocess
from pathlib import Path
from typing import List

HERE = Path(__file__).absolute().parent
CHANGELOG_YAML_PATH = HERE / 'TEST_CHANGELOG.yml'
MAKE_CHANGELOG_PATH = HERE.parent / 'make_changelog.py'


def test_generating_markdown_changelog(tmp_path):
    run_and_check_make_changelog(
        [],
        HERE / 'TEST_CHANGELOG.md',
        tmp_path,
    )

def test_generating_latest_markdown_changelog(tmp_path):
    run_and_check_make_changelog(
        ["--latest"],
        HERE / 'TEST_CHANGELOG-latest.md',
        tmp_path,
    )

def test_generating_debian_changelog(tmp_path):
    run_and_check_make_changelog(
        ["--format", "debian"],
        HERE / 'TEST_CHANGELOG.debian',
        tmp_path,
    )

def run_and_check_make_changelog(
    args: List[str],
    expected_output_file: Path,
    output_dir: Path,
):
    assert expected_output_file.exists()
    assert output_dir.exists()
    output_path = output_dir / 'out'
    subprocess.check_call([
        "python3",
        str(MAKE_CHANGELOG_PATH),
        str(CHANGELOG_YAML_PATH),
        *args,
        str(output_path),
    ])
    with open(expected_output_file, 'r') as f:
        expected = f.read()
    assert output_path.exists()
    with open(output_path, 'r') as f:
        assert f.read() == expected
