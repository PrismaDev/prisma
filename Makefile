JSDIR = js-dev
TEMPLATEDIR = template-dev
LESSDIR = less-dev

# Phony targets #
.PHONY: all js template css clean

all: js template css

js: 
	$(MAKE) --directory=$(JSDIR)
template:
	$(MAKE) --directory=$(TEMPLATEDIR)
css:

clean:
	$(MAKE) --directory=$(JSDIR) clean
	$(MAKE) --directory=$(TEMPLATEDIR) clean
