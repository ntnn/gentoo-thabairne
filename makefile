EBUILDS = $(shell find . -name '*.ebuild')
DIRS = $(dir $(EBUILDS))
MANIFESTS ?= $(patsubst %, %/Manifest, $(DIRS))

default: $(MANIFESTS)

%/Manifest: %/*.ebuild
	# Updating the timestamp of the manifest after execution;
	# repoman does not replace or touch the manifest file if it
	# didn't change.
	# This lets make think the manifest is not up to date and
	# reexcutes the recipe each time.
	cd $(@D); repoman manifest; touch Manifest

clean:
	find . -name Manifest -delete
