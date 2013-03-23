PHTMLDIR = phtml-jade-dev
TEMPLATEDIR = template-jade-dev

all: phtml template
phtml:
	$(MAKE) --directory=$(PHTMLDIR)

template:
	$(MAKE) --directory=$(TEMPLATEDIR)

clean:
	$(MAKE) --directory=$(TEMPLATEDIR) clean
	$(MAKE) --directory=$(PHTMLDIR)
