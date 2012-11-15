srcdir = .
viewsdir = ${srcdir}/view

views = ${viewsdir}/loginView.js

jsobjects = ${viewsdir}/views.jso

components = ${jsobjects}\
	${srcdir}/router.js\

all: prisma.js
dev: prisma.js
clean: 
	rm -fr ${jsobjects}

${viewsdir}/views.jso: ${views}
	cat > $@ $^

prisma.js: ${components}
	cat > $@ $^
