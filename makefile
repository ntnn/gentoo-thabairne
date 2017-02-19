PACKAGES ?= $(shell find . -mindepth 2 -type d -not -path '*/.git/*')
MANIFESTS ?= $(patsubst %, %/Manifest, $(PACKAGES))

default: $(MANIFESTS)

%/Manifest: $(wildcard $(@D)/*.ebuild)
	cd $(@D); repoman manifest

clean:
	find . -name Manifest -delete
