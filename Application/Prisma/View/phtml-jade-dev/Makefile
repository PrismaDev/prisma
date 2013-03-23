CC = jade
JADE = $(wildcard *.jade)
PHTML = $(JADE:.jade=.phtml)
DST = ..

all: $(PHTML)
clean:
	rm $(DST)/*.phtml 

%.phtml: %.jade
	$(CC) < $< --path $< > $(DST)/$@
