## Directory definition ##
PROD = ../../../../Public/js
VIEW = view
CTRL = controller
MDL = model
LIB = lib

## Compiler definition ##
CC = java -jar /usr/bin/closure-compiler.jar
REL =  --compilation_level SIMPLE_OPTIMIZATIONS
DBG = false
CFLAGS = $(REL)

## Target definition ##
PAGES = $(PROD)/prisma-login.min.js \
	$(PROD)/prisma-term.min.js \
	$(PROD)/prisma-main.min.js

## Dependancies ##
DEP_ALL = $(MDL)/layoutStringsModel.js \
	$(MDL)/faqStringsModel.js \
	$(VIEW)/layoutView.js \
	$(VIEW)/dialogView.js \
	$(CTRL)/fbApiController.js

DEP_ISLOGGED = $(MDL)/loggedInDialogsStringsModel.js\
	$(VIEW)/loggedInDialogs.js

DEP_LOGIN = $(DEP_ALL) \
	$(MDL)/loginStringsModel.js \
	$(VIEW)/loginView.js \
	$(CTRL)/loginRouter.js

DEP_TERM = $(DEP_ALL) \
	$(DEP_ISLOGGED) \
	$(MDL)/termStringsModel.js \
	$(VIEW)/termView.js \
	$(CTRL)/termRouter.js

DEP_MAIN = $(DEP_ALL) \
	$(DEP_ISLOGGED) \
	$(MDL)/lib.js \
	$(MDL)/serverDictionary.js \
	$(MDL)/mainStringsModel.js \
	$(MDL)/classModel.js \
	$(MDL)/subjectModel.js \
	$(MDL)/optativaModel.js \
	$(MDL)/faltacursarModel.js\
	$(MDL)/selectedModel.js \
	$(MDL)/mainHelperModel.js \
	$(VIEW)/lib.js \
	$(VIEW)/timetableView.js \
	$(VIEW)/faltacursarView.js \
	$(VIEW)/microhorarioView.js \
	$(VIEW)/selectedView.js \
	$(VIEW)/helperView.js \
	$(VIEW)/mainView.js \
	$(VIEW)/classeslistView.js \
	$(CTRL)/microhorarioController.js \
	$(CTRL)/selectedController.js \
	$(CTRL)/mainRouter.js

## Phony targets ##
.PHONY: all clean debug setdbg

## Rules ##
all: $(PAGES)
clean: 
	rm $(PAGES)
debug: | setdbg all
setdbg: 
	$(eval DBG=true)

$(PROD)/prisma-login.min.js: $(DEP_LOGIN)
	cat > .swp.js $^
ifeq ($(DBG),false)
	$(CC) --js .swp.js $(CFLAGS) --js_output_file $@
else
	cp .swp.js $@
endif
	rm .swp.js

$(PROD)/prisma-term.min.js: $(DEP_TERM)
	cat > .swp.js $^
ifeq ($(DBG),false)
	$(CC) --js .swp.js $(CFLAGS) --js_output_file $@
else
	cp .swp.js $@
endif
	rm .swp.js

$(PROD)/prisma-main.min.js: $(DEP_MAIN)
	cat > .swp.js $^
ifeq ($(DBG),false)
	$(CC) --js .swp.js $(CFLAGS) --js_output_file $@
else
	cp .swp.js $@
endif
	rm .swp.js
