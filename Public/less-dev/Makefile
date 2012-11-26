PROD = ../css

CC = lessc
CFLAGS = --yui-compressor --strict-imports

TARGETS = $(PROD)/prisma-main.min.css\
	$(PROD)/prisma-login.min.css\
	$(PROD)/prisma-term.min.css

all: $(TARGETS)
clean:
	rm $(TARGETS)

$(PROD)/prisma-main.min.css: main.less
	$(CC) $(CFLAGS) $^ > $@

$(PROD)/prisma-login.min.css: login.less
	$(CC) $(CFLAGS) $^ > $@

$(PROD)/prisma-term.min.css: term.less
	$(CC) $(CFLAGS) $^ > $@
