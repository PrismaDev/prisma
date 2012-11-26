PROD = ../template
CC = ./tmin

TARGETS = $(PROD)/prisma-login.min.template \
	$(PROD)/prisma-term.min.template \
	$(PROD)/prisma-main.min.template

.PHONY: all clean

all: $(TARGETS)
clean: 
	rm $(TARGETS)
	
$(PROD)/prisma-login.min.template: login.template \
				layout.template
	cat > .swp.tmp $^
	$(CC) .swp.tmp $@
	rm .swp.tmp

$(PROD)/prisma-term.min.template: term.template
	cat > .swp.tmp $^
	$(CC) .swp.tmp $@
	rm .swp.tmp

$(PROD)/prisma-main.min.template: classeslist.template \
				main.template \
				microhorario.template \
				timetable.template \
				faltacursar.template
	cat > .swp.tmp $^
	$(CC) .swp.tmp $@
	rm .swp.tmp
