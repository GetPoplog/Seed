################################################################################
# Helper targets
################################################################################
.PHONY: clean
clean:
	rm -rf ./_build
	rm -f ./systests/report.xml
	# Target "clean" completed

.PHONY: deepclean
deepclean: clean
	rm -rf ./_download

.PHONY: test
test:
	cd systests; \
	if [ -e venv ]; then \
	    . venv/bin/activate; \
	fi; \
	pytest --junit-xml=report.xml
