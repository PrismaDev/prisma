PROD = ../css

CC = lessc
CFLAGS = --yui-compressor --strict-imports 

TARGETS = $(PROD)/prisma-main.min.css\
	$(PROD)/prisma-login.min.css\
	$(PROD)/prisma-term.min.css

all: $(TARGETS)
clean:
	rm $(TARGETS)

$(PROD)/prisma-main.min.css: main.less\
				basics.less\
				tables.less\
				datatablesAdds.less\
				faltacursar.less\
				microhorario.less\
				selected.less
	$(CC) $(CFLAGS) main.less > $@

$(PROD)/prisma-login.min.css: login.less
	$(CC) $(CFLAGS) login.less > $@

$(PROD)/prisma-term.min.css: term.less
	$(CC) $(CFLAGS) term.less > $@
