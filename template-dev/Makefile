CC = ./tmin
PROD = ../template

TARGETS = $(PROD)/prisma-login.template \
	$(PROD)/prisma-term.template \
	$(PROD)/prisma-main.template

.PHONY: all clean

all: $(TARGETS)
clean: 
	rm $(TARGETS)
	rm $(foreach target,$(TARGETS),$(target).min)
	
$(PROD)/prisma-login.template: login.template \
				layout.template
	cat > $@ $^
	$(CC) $@ $@.min 

$(PROD)/prisma-term.template: term.template
	cat > $@ $^
	$(CC) $@ $@.min 

$(PROD)/prisma-main.template: classeslist.template \
				main.template \
				microhorario.template \
				timetable.template \
				faltacursar.template
	cat > $@ $^
	$(CC) $@ $@.min 
