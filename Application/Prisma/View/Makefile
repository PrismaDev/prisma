PHTMLDIR = phtml-jade-dev
TEMPLATEDIR = template-jade-dev
JSDIR = js-dev
LESSDIR = less-dev

.PHONY: all js css phtml template clean debug

all: phtml template js css

phtml:
	$(MAKE) --directory=$(PHTMLDIR)

template:
	$(MAKE) --directory=$(TEMPLATEDIR)

js: 
	$(MAKE) --directory=$(JSDIR)

css:
	$(MAKE) --directory=$(LESSDIR)

clean:
	$(MAKE) --directory=$(JSDIR) clean
	$(MAKE) --directory=$(LESSDIR) clean
	$(MAKE) --directory=$(TEMPLATEDIR) clean
	$(MAKE) --directory=$(PHTMLDIR) clean

debug:
	$(MAKE) --directory=$(JSDIR) debug
	$(MAKE) --directory=$(LESSDIR) debug
	$(MAKE) --directory=$(TEMPLATEDIR) debug
	$(MAKE) --directory=$(PHTMLDIR) debug
