PROD = ../template

TARGETS = $(PROD)/prisma-login.template \
	$(PROD)/prisma-term.template \
	$(PROD)/prisma-main.template

.PHONY: all clean

all: $(TARGETS)
clean: 
	rm $(TARGETS)
	
$(PROD)/prisma-login.template: login.template \
				layout.template
	cat > $@ $^

$(PROD)/prisma-term.template: term.template
	cat > $@ $^

$(PROD)/prisma-main.template: classeslist.template \
				main.template \
				microhorario.template \
				timetable.template \
				faltacursar.template
	cat > $@ $^
 
