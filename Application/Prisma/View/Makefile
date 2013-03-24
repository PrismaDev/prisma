PHTMLDIR = phtml-jade-dev
TEMPLATEDIR = template-jade-dev

.PHONY: all phtml template

all: phtml template

phtml:
	$(MAKE) --directory=$(PHTMLDIR)

template:
	$(MAKE) --directory=$(TEMPLATEDIR)

clean:
	$(MAKE) --directory=$(TEMPLATEDIR) clean
	$(MAKE) --directory=$(PHTMLDIR)
