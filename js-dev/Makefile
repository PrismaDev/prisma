## Directory definition ##
PROD = ../js
VIEW = view
CTRL = controller
MDL = model

## Target definition ##
PAGES = $(PROD)/prisma-login.js \
	$(PROD)/prisma-term.js \
	$(PROD)/prisma-main.js

## Phony targets ##
all: $(PAGES)
clean:
	rm $(PAGES)

$(PROD)/prisma-login.js: $(VIEW)/loginView.js \
			$(MDL)/loginStringsModel.js \
			$(CTRL)/router.js
	cat > $@ $^

$(PROD)/prisma-term.js: $(VIEW)/termView.js \
			$(CTRL)/router.js
	cat > $@ $^

$(PROD)/prisma-main.js:  $(VIEW)/timetableView.js \
			$(VIEW)/faltacursarView.js \
			$(VIEW)/microhorarioView.js \
			$(VIEW)/mainView.js \
			$(VIEW)/classeslistView.js \
			$(CTRL)/selectedController.js \
			$(CTRL)/router.js
	cat > $@ $^
