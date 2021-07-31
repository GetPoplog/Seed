from pathlib import Path
import subprocess

HERE = Path(__file__).absolute().parent
CHANGELOG_YAML_PATH = HERE / 'TEST_CHANGELOG.yml'
MAKE_CHANGELOG_PATH = HERE.parent / 'make_changelog.py'

def test_generating_markdown_changelog(tmp_path):
    output_path = tmp_path / 'TEST_CHANGELOG.md'
    subprocess.check_call(["python3", str(MAKE_CHANGELOG_PATH), str(CHANGELOG_YAML_PATH), str(output_path)])
    with open(HERE / 'TEST_CHANGELOG.md', 'r') as f:
        expected = f.read()
    assert output_path.exists()
    with open(output_path, 'r') as f:
        assert f.read() == expected


def test_generating_latest_markdown_changelog(tmp_path):
    output_path = tmp_path / 'TEST_CHANGELOG.md'
    subprocess.check_call(["python3", str(MAKE_CHANGELOG_PATH), "--latest", str(CHANGELOG_YAML_PATH), str(output_path)])
    with open(HERE / 'TEST_CHANGELOG-latest.md', 'r') as f:
        expected = f.read()
    assert output_path.exists()
    with open(output_path, 'r') as f:
        assert f.read() == expected


def test_generating_debian_changelog(tmp_path):
    output_path = tmp_path / 'TEST_CHANGELOG.debian'
    subprocess.check_call(["python3",  str(MAKE_CHANGELOG_PATH), "--format", "debian", str(CHANGELOG_YAML_PATH), str(output_path)])
    with open(HERE / 'TEST_CHANGELOG.debian', 'r') as f:
        expected = f.read()
    assert output_path.exists()
    with open(output_path, 'r') as f:
        assert f.read() == expected
