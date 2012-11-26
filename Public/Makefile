JSDIR = js-dev
TEMPLATEDIR = template-dev
LESSDIR = less-dev

# Phony targets #
.PHONY: all js template css index clean

all: js template css

js: 
	$(MAKE) --directory=$(JSDIR)
template:
	$(MAKE) --directory=$(TEMPLATEDIR)
css:
	$(MAKE) --directory=$(LESSDIR)
index:
	$(TEMPLATEDIR)/tmin index-dev.php index.php

clean:
	$(MAKE) --directory=$(JSDIR) clean
	$(MAKE) --directory=$(TEMPLATEDIR) clean
	$(MAKE) --directory=$(LESSDIR) clean
