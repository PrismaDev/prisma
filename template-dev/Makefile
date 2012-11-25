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
<<<<<<< HEAD
	cat > tmp.template $^
	$(CC) tmp.template $@
	rm tmp.template

$(PROD)/prisma-term.min.template: term.template
	cat > tmp.template $^
	$(CC) tmp.template $@
	rm tmp.template
=======
	cat > $@ $^

$(PROD)/prisma-term.template: term.template
	cat > $@ $^
>>>>>>> parent of c2e3ef9... minified templates and javascript

$(PROD)/prisma-main.min.template: classeslist.template \
				main.template \
				microhorario.template \
				timetable.template \
				faltacursar.template
<<<<<<< HEAD
	cat > tmp.template $^
	$(CC) tmp.template $@
	rm tmp.template
=======
	cat > $@ $^
 
>>>>>>> parent of c2e3ef9... minified templates and javascript
