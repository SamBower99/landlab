.PHONY: clean clean-test clean-pyc clean-build docs help
.DEFAULT_GOAL := help

define BROWSER_PYSCRIPT
import os, webbrowser, sys

try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

clean: clean-build clean-pyc clean-test ## remove all build, test, coverage and Python artifacts

clean-build: ## remove build artifacts
	rm -fr build/
	rm -fr dist/
	rm -fr .eggs/
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +

clean-pyc: ## remove Python file artifacts
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
	find . -name '*~' -exec rm -f {} +
	find . -name '__pycache__' -exec rm -fr {} +

clean-test: ## remove test and coverage artifacts
	rm -fr .tox/
	rm -f .coverage
	rm -fr htmlcov/
	rm -fr .pytest_cache

lint: ## check style with flake8
	flake8 landlab tests

pretty: ## reformat files to make them look pretty
	find landlab tests -name '*.py' | xargs isort
	black setup.py landlab tests

requirements: ## create requirements files from pyproject.toml
	python requirements.py > requirements.txt
	python requirements.py dev > requirements-dev.txt
	python requirements.py docs > requirements-docs.txt
	python requirements.py notebooks > requirements-notebooks.txt
	python requirements.py testing > requirements-testing.txt

test: ## run tests quickly with the default Python
	pytest -n4

coverage: ## check code coverage quickly with the default Python
	pytest --cov --cov-report=html
	$(BROWSER) htmlcov/index.html

docs: ## generate Sphinx HTML documentation, including API docs and link check
	$(MAKE) -C docs clean
	$(MAKE) -C docs html
	$(MAKE) -C docs linkcheck
	$(BROWSER) docs/build/html/index.html

install: clean ## install the package to the active Python's site-packages
	pip install -e .
