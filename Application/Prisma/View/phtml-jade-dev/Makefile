CC = jade
REL = --no-debug
DBG = --pretty
CFLAGS = $(REL)

JADE = $(wildcard *.jade)
PHTML = $(JADE:.jade=.phtml)
DST = ..

.PHONY: all clean debug setdbg

all: $(PHTML)
clean:
	rm -f $(DST)/*.phtml 

debug: | setdbg all
setdbg:
	$(eval CFLAGS=$(DBG))
	
%.phtml: %.jade
	$(CC) $(CFLAGS) < $< --path $< > $(DST)/$@
