## Directory definition ##
PROD = ../js
VIEW = view
CTRL = controller
MDL = model

## Compiler definition ##
CC = java -jar /usr/bin/closure-compiler.jar
CFLAGS =  --compilation_level SIMPLE_OPTIMIZATIONS

## Target definition ##
PAGES = $(PROD)/prisma-login.js \
	$(PROD)/prisma-term.js \
	$(PROD)/prisma-main.js

## Phony targets ##
all: $(PAGES)
clean:
	rm $(PAGES)
	rm $(foreach page,$(PAGES),$(page).min)

$(PROD)/prisma-login.js: $(VIEW)/loginView.js \
			$(MDL)/loginStringsModel.js \
			$(CTRL)/router.js
	cat > $@ $^
	$(CC) --js $@ $(CFLAGS) --js_output_file $@.min

$(PROD)/prisma-term.js: $(VIEW)/termView.js \
			$(CTRL)/router.js
	cat > $@ $^
	$(CC) --js $@ $(CFLAGS) --js_output_file $@.min

$(PROD)/prisma-main.js:  $(VIEW)/timetableView.js \
			$(VIEW)/faltacursarView.js \
			$(VIEW)/microhorarioView.js \
			$(VIEW)/mainView.js \
			$(VIEW)/classeslistView.js \
			$(CTRL)/selectedController.js \
			$(CTRL)/router.js
	cat > $@ $^
	$(CC) --js $@ $(CFLAGS) --js_output_file $@.min
