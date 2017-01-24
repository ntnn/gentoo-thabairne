packages ?= $(shell find . -mindepth 2 -type d -not -path '*/.git/*')

manifests:
	for d in $(packages); do cd $$d; repoman manifest; cd -; done

clean:
	find . -name Manifest -delete
