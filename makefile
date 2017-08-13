EBUILDS = $(shell find . -name '*.ebuild')
DIRS = $(dir $(EBUILDS))
MANIFESTS ?= $(patsubst %, %/Manifest, $(DIRS))
REPOMAN ?= repoman --if-modified=y
CHANGED ?= $(shell git status --porcelain | awk '/^.[^D].+\.ebuild/ { print $$2 }')

default: $(MANIFESTS)

manifests:
%/Manifest: %/*.ebuild
	# Updating the timestamp of the manifest after execution;
	# repoman does not replace or touch the manifest file if it
	# didn't change.
	# This lets make think the manifest is not up to date and
	# reexcutes the recipe each time.
	cd $(@D); repoman manifest; touch Manifest

test:
	$(REPOMAN) full
	sudo USE=test ebuild $(CHANGED) clean install test

commit: $(MANIFESTS)
	$(REPOMAN) full
	$(REPOMAN) commit

clean:
	find . -name Manifest -delete

print:
	@echo EBUILDS: $(EBUILDS)
	@echo DIRS: $(DIRS)
	@echo MANIFESTS: $(MANIFESTS)
	@echo CHANGED: $(CHANGED)
