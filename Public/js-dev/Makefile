## Directory definition ##
PROD = ../js
VIEW = view
CTRL = controller
MDL = model
LIB = lib

## Compiler definition ##
CC = java -jar /usr/bin/closure-compiler.jar
CFLAGS =  --compilation_level SIMPLE_OPTIMIZATIONS

## Target definition ##
PAGES = $(PROD)/prisma-login.min.js \
	$(PROD)/prisma-term.min.js \
	$(PROD)/prisma-main.min.js

## Dependancies ##
DEP_LOGIN = $(VIEW)/loginView.js \
	$(MDL)/loginStringsModel.js \
	$(CTRL)/loginRouter.js

DEP_TERM = $(VIEW)/termView.js \
	$(CTRL)/termRouter.js

DEP_MAIN = $(MDL)/microhorarioModel.js \
	$(VIEW)/timetableView.js \
	$(VIEW)/faltacursarView.js \
	$(MDL)/mainStringsModel.js \
	$(VIEW)/microhorarioView.js \
	$(VIEW)/selectedView.js \
	$(VIEW)/mainView.js \
	$(VIEW)/classeslistView.js \
	$(CTRL)/selectedController.js \
	$(CTRL)/mainRouter.js

## Phony targets ##
all: $(PAGES)
clean:
	rm $(PAGES)

$(PROD)/prisma-login.min.js: $(DEP_LOGIN)
	cat > $@ $^
	##$(CC) --js .swp.js $(CFLAGS) --js_output_file $@
	#rm .swp.js

$(PROD)/prisma-term.min.js: $(DEP_TERM)
	cat > $@ $^
	#$(CC) --js .swp.js $(CFLAGS) --js_output_file $@
	#rm .swp.js

$(PROD)/prisma-main.min.js: $(DEP_MAIN)
	cat > $@ $^
	#$(CC) --js .swp.js $(CFLAGS) --js_output_file $@
	#rm .swp.js
