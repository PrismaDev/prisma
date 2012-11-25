PROD = ../template

TARGETS = $(PROD)/prisma-login.min.template \
	$(PROD)/prisma-term.min.template \
	$(PROD)/prisma-main.min.template

.PHONY: all clean

all: $(TARGETS)
clean: 
	rm $(TARGETS)
	
$(PROD)/prisma-login.min.template: login.template \
				layout.template
	cat > $@ $^

$(PROD)/prisma-term.min.template: term.template
	cat > $@ $^

$(PROD)/prisma-main.min.template: classeslist.template \
				main.template \
				microhorario.template \
				timetable.template \
				faltacursar.template
	cat > $@ $^
