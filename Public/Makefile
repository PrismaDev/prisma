JSDIR = js-dev
TEMPLATEDIR = template-dev
LESSDIR = less-dev

# Phony targets #
.PHONY: all js template css index clean

all: js css

js: 
	$(MAKE) --directory=$(JSDIR)
css:
	$(MAKE) --directory=$(LESSDIR)

clean:
	$(MAKE) --directory=$(JSDIR) clean
	$(MAKE) --directory=$(LESSDIR) clean
