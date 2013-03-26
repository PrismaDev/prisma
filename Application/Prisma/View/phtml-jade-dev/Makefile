CC = jade
REL = --no-debug
DBG = --pretty
JADEOPTS = $(REL)

JADE = $(wildcard *.jade)
PHTML = $(JADE:.jade=.phtml)
DST = ..

.PHONY: all clean debug setdbg

all: $(PHTML)
clean:
	rm $(DST)/*.phtml 

debug: | setdbg all
setdbg:
	$(eval JADEOPTS=$(DBG))
	
%.phtml: %.jade
	$(CC) $(JADEOPTS) < $< --path $< > $(DST)/$@
