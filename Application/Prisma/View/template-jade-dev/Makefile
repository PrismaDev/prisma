PROD = ../template
CC = jade

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

.PHONY: all clean

all: precomp | $(TARGETS) cleartmp
clean: 
	rm $(TARGETS)

cleartmp:
	rm tmp

precomp: login.template.jade includes/login-mixins.jade includes/topdropdown.jade \
		dialog.template.jade
	$(CC) < dialog.template.jade --path dialog.template.jade > dialog.template
	$(CC) < login.template.jade --path login.template.jade > login.template
	$(CC) < layout.template.jade --path layout.template.jade > layout.template

$(PROD)/prisma-login.min.template: $(DEP_LOGIN)
	##$(CC) < $^ --path $^ > tmp
	#cat > $@ tmp
	cat > $@ $^

$(PROD)/prisma-term.min.template: $(DEP_TERM)
	cat > $@ $^

$(PROD)/prisma-main.min.template: $(DEP_MAIN)
	cat > $@ $^
