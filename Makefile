PACKAGE = sogo-connector
GIT_REV = $(shell git rev-parse --verify HEAD | cut -c1-10)

ifeq ($(shell uname),Darwin)
VERSION = $(shell grep em:version install.rdf | sed -E 's@(em:version=|"| )@@g')
else
VERSION = $(shell grep em:version install.rdf | sed -e 's@\(em:version=\|\"\|\ \)@@g')
endif

FIND_FILTER = ! -path './custom/*' -type f
XPI_ARCHIVE = $(PACKAGE)-$(VERSION)-$(GIT_REV).xpi

SHELL = /bin/bash
ZIP = /usr/bin/zip

FILENAMES = $(shell cat MANIFEST)

all: MANIFEST-pre MANIFEST rest

custom-build:
	@if test "x$$build" == "x"; then \
	  echo "Building package with default settings."; \
	else \
	  echo "Building package with custom settings for '$$build'."; \
	  if ! test -d custom/$$build; then \
	    echo "Custom build '$$build' does not exist"; \
	    exit 1; \
	  fi; fi

MANIFEST: MANIFEST-pre
	@if ! cmp MANIFEST MANIFEST-pre >& /dev/null; then \
	  mv -f MANIFEST-pre MANIFEST; \
	  echo MANIFEST updated; \
	else \
	  rm -f MANIFEST-pre; \
	fi;

MANIFEST-pre:
	@echo manifest.json > $@
	@echo COPYING >> $@
	@echo ChangeLog.old >> $@
	@find . $(FIND_FILTER) -name "*.manifest" >> $@
	@find . $(FIND_FILTER) -name "*.xul" >> $@
	@find . $(FIND_FILTER) -name "*.xml" >> $@
	@find . $(FIND_FILTER) -name "*.dtd" >> $@
	@find . $(FIND_FILTER) -name "*.idl" >> $@
	@find . $(FIND_FILTER) -name "*.js" >> $@
	@find . $(FIND_FILTER) -name "*.jsm" >> $@
	@find . $(FIND_FILTER) -name "*.css" >> $@
	@find . $(FIND_FILTER) -name "*.png" >> $@
	@find . $(FIND_FILTER) -name "*.gif" >> $@
	@find . $(FIND_FILTER) -name "*.jpg" >> $@
	@find . $(FIND_FILTER) -name "*.xpt" >> $@
	@find . $(FIND_FILTER) -name "*.properties" >> $@
	@find . $(FIND_FILTER) -name "*.rdf" >> $@
	@find . $(FIND_FILTER) -name "RELEASE-NOTES" >> $@	

rest: MANIFEST
	@+make $(XPI_ARCHIVE)

$(XPI_ARCHIVE): $(FILENAMES)
	@echo Generating $(XPI_ARCHIVE)...
	@rm -f $(XPI_ARCHIVE)
	@$(ZIP) -9r $(XPI_ARCHIVE) $(FILENAMES) > /dev/null
	@if test "x$$build" != "x"; then \
	  cd custom/$$build; \
	  $(ZIP) -9r ../../$(XPI_ARCHIVE) * > /dev/null; \
	fi

clean:
	rm -f MANIFEST-pre $(XPI_ARCHIVE)
	rm -f *.xpi
	find . -name "*~" -exec rm -f {} \;

distclean: clean
	rm -f MANIFEST
