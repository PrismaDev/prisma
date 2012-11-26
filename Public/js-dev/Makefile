## Directory definition ##
PROD = ../js
VIEW = view
CTRL = controller
MDL = model

## Compiler definition ##
CC = java -jar /usr/bin/closure-compiler.jar
CFLAGS =  --compilation_level SIMPLE_OPTIMIZATIONS

## Target definition ##
PAGES = $(PROD)/prisma-login.min.js \
	$(PROD)/prisma-term.min.js \
	$(PROD)/prisma-main.min.js

## Phony targets ##
all: $(PAGES)
clean:
	rm $(PAGES)

$(PROD)/prisma-login.min.js: $(VIEW)/loginView.js \
			$(MDL)/loginStringsModel.js \
			$(CTRL)/router.js
	cat > .swp.js $^
	$(CC) --js .swp.js $(CFLAGS) --js_output_file $@
	rm .swp.js

$(PROD)/prisma-term.min.js: $(VIEW)/termView.js \
			$(CTRL)/router.js
	cat > .swp.js $^
	$(CC) --js .swp.js $(CFLAGS) --js_output_file $@
	rm .swp.js

$(PROD)/prisma-main.min.js:  $(VIEW)/timetableView.js \
			$(VIEW)/faltacursarView.js \
			$(VIEW)/microhorarioView.js \
			$(VIEW)/selectedView.js \
			$(VIEW)/mainView.js \
			$(VIEW)/classeslistView.js \
			$(CTRL)/selectedController.js \
			$(CTRL)/router.js
	cat > .swp.js $^
	$(CC) --js .swp.js $(CFLAGS) --js_output_file $@
	rm .swp.js
