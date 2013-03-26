JSDIR = js-dev
LESSDIR = less-dev

# Phony targets #
.PHONY: all js css clean debug

all: js css

js: 
	$(MAKE) --directory=$(JSDIR)
css:
	$(MAKE) --directory=$(LESSDIR)

clean:
	$(MAKE) --directory=$(JSDIR) clean
	$(MAKE) --directory=$(LESSDIR) clean
debug:
	$(MAKE) --directory=$(JSDIR) debug
	$(MAKE) --directory=$(LESSDIR) debug
