# -*- coding: utf-8; mode: makefile-gmake -*-

include ./.config.mk

PYOBJECTS = searx
DOC       = docs
PY_SETUP_EXTRAS ?= \[test\]

PYDIST=./dist/py
PYBUILD=./build/py

include utils/makefile.include
include utils/makefile.python
include utils/makefile.sphinx

all: clean install

PHONY += help
help:
	@echo  '  test      - run developer tests'
	@echo  '  docs      - build documentation'
	@echo  '  docs-live - autobuild HTML documentation while editing'
	@echo  '  run       - run developer instance'
	@echo  '  install   - developer install (./local)'
	@echo  '  uninstall - uninstall (./local)'
	@echo  '  gh-pages  - build docs & deploy on gh-pages branch'
	@echo  '  clean     - drop builds and environments'
	@echo  ''
	@echo  'environment'
	@echo  '  SEARX_URL = $(SEARX_URL)'
	@echo  '  GIT_URL   = $(GIT_URL)'
	@echo  '  DOCS_URL  = $(DOCS_URL)'
	@echo  ''
	@$(MAKE) -s -f utils/makefile.include make-help
	@echo  ''
	@$(MAKE) -s -f utils/makefile.python python-help

PHONY += install
install: pyenvinstall

PHONY += uninstall
uninstall: pyenvuninstall

PHONY += clean
clean: pyclean
	$(call cmd,common_clean)

PHONY += run
run:  pyenvinstall
	$(Q) ( \
	sed -i -e "s/debug : False/debug : True/g" ./searx/settings.yml ; \
	sleep 2 ; \
	xdg-open http://127.0.0.1:8888/ ; \
	sleep 3 ; \
	sed -i -e "s/debug : True/debug : False/g" ./searx/settings.yml ; \
	) &
	$(PY_ENV)/bin/python ./searx/webapp.py

# docs
# ----

PHONY += docs

docs:  pyenvinstall sphinx-doc prebuild-includes
	$(call cmd,sphinx,html,docs,docs)

PHONY += docs-live
docs-live:  pyenvinstall sphinx-live prebuild-includes
	$(call cmd,sphinx_autobuild,html,docs,docs)

prebuild-includes:
	@mkdir -p $(DOCS_BUILD)/includes
	@./utils/searx.sh doc | cat > $(DOCS_BUILD)/includes/searx.rst
	@./utils/filtron.sh doc | cat > $(DOCS_BUILD)/includes/filtron.rst
	@./utils/morty.sh doc | cat > $(DOCS_BUILD)/includes/morty.rst


$(GH_PAGES)::
	@echo "doc available at --> $(DOCS_URL)"

# test
# ----

PHONY += test test.sh test.pylint test.pep8 test.unit test.robot

test: test.pylint test.pep8 test.unit test.robot

# TODO: balance linting with pylint

test.pylint: pyenvinstall
	$(call cmd,pylint,searx/preferences.py)
	$(call cmd,pylint,searx/testing.py)

test.sh:
	shellcheck -x utils/lib.sh
	shellcheck -x utils/filtron.sh
	shellcheck -x utils/searx.sh
	shellcheck -x utils/morty.sh
	shellcheck -x utils/lxc.sh
	shellcheck -x utils/lxc.env
	shellcheck -x .config.sh

test.pep8: pyenvinstall
	$(PY_ENV_ACT); ./manage.sh pep8_check

test.unit: pyenvinstall
	$(PY_ENV_ACT); ./manage.sh unit_tests

test.robot: pyenvinstall
	$(PY_ENV_ACT); ./manage.sh install_geckodriver
	$(PY_ENV_ACT); ./manage.sh robot_tests

.PHONY: $(PHONY)
