srcdir = .
viewdir = ${srcdir}/view
templatedir = ${srcdir}/template
controllerdir = ${srcdir}/controller

# Phony targets #
all: prisma-login prisma-term prisma-main
prisma-login: prisma-login.js prisma-login.template
prisma-term: prisma-term.js prisma-term.template
prisma-main: prisma-main.js prisma-main.template
dev: prisma.js
clean: 
	rm -fr ${viewdir}/*.jso

# Login page #
jsLogin = ${viewdir}/loginView.js \
	${srcdir}/router.js

templateLogin = ${templatedir}/login.template

prisma-login.js: ${jsLogin}
	cat > $@ $^
prisma-login.template: ${templateLogin} 
	cat > $@ $^

# Term page #
jsTerm = ${viewdir}/termView.js \
	${srcdir}/router.js

templateTerm = ${templatedir}/term.template

prisma-term.js: ${jsTerm}
	cat > $@ $^
prisma-term.template: ${templateTerm}
	cat > $@ $^

# Main page #
jsMain = ${viewdir}/timetableView.js \
	 ${viewdir}/faltacursarView.js \
	 ${viewdir}/selectedView.js \
	 ${viewdir}/mainView.js \
	${srcdir}/router.js

templateMain = ${templatedir}/classeslist.template \
		${templatedir}/main.template \
		${templatedir}/timetable.template \
		${templatedir}/faltacursar.template

prisma-main.js: ${jsMain}
	cat > $@ $^
prisma-main.template: ${templateMain}
	cat > $@ $^

