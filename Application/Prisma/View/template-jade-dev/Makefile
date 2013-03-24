CC = jade
DBG = --pretty
REL = --no-debug

JADEOPTS = $(REL)
PROD = ../template
INCS = includes

TARGETS = $(PROD)/prisma-login.min.template \
	$(PROD)/prisma-term.min.template \
	$(PROD)/prisma-main.min.template

DEP_ALL = layout.template \
	dialog.template

DEP_ISLOGGED = suggestions.template

DEP_LOGIN = $(DEP_ALL) \
	login.template \

DEP_TERM = $(DEP_ALL) \
	$(DEP_ISLOGGED) \
	term.template

DEP_MAIN = $(DEP_ALL) \
	$(DEP_ISLOGGED) \
	classeslist.template \
	main.template \
	microhorario.template \
	timetable.template \
	selected.template \
	faltacursar.template

.PHONY: all clean precomp debug setdbg

all: $(TARGETS)
clean: 
	rm $(TARGETS) $(DEP_LOGIN) $(DEP_TERM)
debug: | setdbg all
setdbg:
	$(eval JADEOPTS=$(DBG))

term.template: term.template.jade
	$(CC) $(JADEOPTS) < $^ --path $^ > $@

suggestions.template: suggestions.template.jade | $(INCS)/dialog-mixins.jade
	$(CC) $(JADEOPTS) < $^ --path $^ > $@

layout.template: layout.template.jade | $(INCS)/login-mixins.jade $(INCS)/topdropdown.jade
	$(CC) $(JADEOPTS) < $^ --path $^ > $@

login.template: login.template.jade | $(INCS)/login-mixins.jade
	$(CC) $(JADEOPTS) < $^ --path $^ > $@

dialog.template: dialog.template.jade | $(INCS)/dialog-mixins.jade
	$(CC) $(JADEOPTS) < $^ --path $^ > $@

$(PROD)/prisma-login.min.template: $(DEP_LOGIN)
	cat > $@ $^

$(PROD)/prisma-term.min.template: $(DEP_TERM)
	cat > $@ $^

$(PROD)/prisma-main.min.template: $(DEP_MAIN)
	cat > $@ $^

