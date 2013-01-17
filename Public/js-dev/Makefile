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
DEP_ALL = $(MDL)/layoutStringsModel.js \
	$(MDL)/faqStringsModel.js \
	$(VIEW)/layoutView.js \
	$(VIEW)/dialogView.js

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
