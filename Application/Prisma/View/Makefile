PHTMLDIR = phtml-jade-dev
TEMPLATEDIR = template-jade-dev

.PHONY: all phtml template clean debug

all: phtml template

phtml:
	$(MAKE) --directory=$(PHTMLDIR)

template:
	$(MAKE) --directory=$(TEMPLATEDIR)

clean:
	$(MAKE) --directory=$(TEMPLATEDIR) clean
	$(MAKE) --directory=$(PHTMLDIR) clean

debug:
	$(MAKE) --directory=$(TEMPLATEDIR) debug
	$(MAKE) --directory=$(PHTMLDIR) debug
