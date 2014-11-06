PROD = ../../../../Public/css

CC = lessc
REL = --x --strict-imports  
DBG = --strict-imports
CFLAGS = $(REL)

TARGETS = $(PROD)/prisma-main.min.css\
	$(PROD)/prisma-login.min.css\
	$(PROD)/prisma-term.min.css

DEP_ALL = nav.less \
	layout.less \
	basics.less\
	dialog.less\
	variables.less

DEP_LOGIN = $(DEP_ALL) \
		login.less

DEP_TERM = $(DEP_ALL) \
		term.less

DEP_MAIN = $(DEP_ALL) \
		main.less\
		tables.less\
		datatablesAdds.less\
		faltacursar.less\
		microhorario.less\
		timetable.less\
		selected.less

.PHONY: all clean setdbg debug

all: $(TARGETS)
clean:
	rm -f $(TARGETS)
debug: | setdbg all
setdbg:
	$(eval CFLAGS=$(DBG))

$(PROD)/prisma-main.min.css: $(DEP_MAIN)
	$(CC) $(CFLAGS) main.less > $@

$(PROD)/prisma-login.min.css: $(DEP_LOGIN)
	$(CC) $(CFLAGS) login.less > $@

$(PROD)/prisma-term.min.css: $(DEP_TERM)
	$(CC) $(CFLAGS) term.less > $@
