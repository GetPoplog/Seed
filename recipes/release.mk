################################################################################
# Changelogs
################################################################################
$(BUILD)/changelogs/CHANGELOG.debian: CHANGELOG.yml
	python3 contributor_tools/make_changelog.py --format debian "$<" "$@"

$(BUILD)/changelogs/CHANGELOG.md: CHANGELOG.yml
	python3 contributor_tools/make_changelog.py --latest "$<" "$@"


################################################################################
# Perform a GitHub release via CircleCI. You must be authorized to push tags to
# the upstream repository on GitHub to perform this action.
################################################################################
.PHONY: github-release
github-release:
	git tag v$(GETPOPLOG_VERSION) -a -m "GetPoplog v$(GETPOPLOG_VERSION)" ; \
	git push origin v$(GETPOPLOG_VERSION)
