"""Generate changelog files

The input changelog file is in YAML format. It has the structure:
  "0.2.0":
    datetime: 2021-07-24T17:00:01Z
    description: |
      Initial commit
    bugfixes:  # this is optional
      - Fixes blah
      - Fixes foo
    changes:  # this is optional
      - Changes bleh to blah

A variety of output formats can be produced:
- markdown: for publication on the Github release
- debian: for inclusion in a debian package
"""
import argparse
import yaml
from typing import Dict, Any
from pathlib import Path
from jinja2 import Environment, FileSystemLoader, select_autoescape
from datetime import datetime
import textwrap


parser = argparse.ArgumentParser(
    description=__doc__,
    formatter_class=argparse.RawDescriptionHelpFormatter,
)
parser.add_argument("changelog_yml", type=Path, help="Path to YAML changelog file")
parser.add_argument("output", type=Path, help="Path to generated changelog file")
parser.add_argument("--format", choices=["debian", "markdown"], default="markdown")
parser.add_argument(
    "--latest",
    action="store_true",
    help="[markdown only] Only output the latest changelog entry",
)
HERE = Path(__file__).parent

ENV = Environment(
    loader=FileSystemLoader(HERE / "templates"),
    autoescape=select_autoescape(),
    trim_blocks=True,
    lstrip_blocks=True,
)


def load_changelog_yaml(changelog_yml_path: Path) -> Dict[Any, Any]:
    with open(changelog_yml_path, "r") as f:
        changelog = yaml.safe_load(f)
    changelog_entries = []
    for version, body in changelog.items():
        for expected_entry in ["datetime", "description", "author", "author_email"]:
            if expected_entry not in body:
                raise ValueError(f"Missing {expected_entry} entry for {version}")
        if not isinstance(body["datetime"], datetime):
            raise TypeError(
                f"Expected datetime entry for {version} to be a datetime type, but was {body['datetime'].__class__.__name__}"
            )
        body["version"] = version
        body.setdefault("bugfixes", [])
        body.setdefault("changes", [])
        changelog_entries.append(body)
    return {"entries": changelog_entries}


def generate_debian_changelog(changelog_entries) -> str:
    return ENV.get_template("changelog.debian.j2").render(changelog_entries)


def generate_markdown_changelog(changelog_entries, latest: bool = False) -> str:
    if latest:
        changelog_entries = {"entries": [changelog_entries["entries"][0]]}
    return ENV.get_template("changelog.md.j2").render(changelog_entries)


def main(args):
    changelog_entries = load_changelog_yaml(args.changelog_yml)
    if args.format == "markdown":
        out = generate_markdown_changelog(changelog_entries, latest=args.latest)
    elif args.format == "debian":
        out = generate_debian_changelog(changelog_entries)
    else:
        raise ValueError(f"Unknown changelog type '{args.format}'")
    args.output.parent.mkdir(exist_ok=True, parents=True)
    with open(args.output, "w") as f:
        f.write(out)


if __name__ == "__main__":
    main(parser.parse_args())
