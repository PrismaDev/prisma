srcdir = .
viewdir = ${srcdir}/view
templatedir = ${srcdir}/template
controllerdir = ${srcdir}/controller
modeldir = ${srcdir}/model

# Phony targets #
all: prisma-login prisma-term prisma-main
prisma-login: prisma-login.js prisma-login.template
prisma-term: prisma-term.js prisma-term.template
prisma-main: prisma-main.js prisma-main.template
clean: 
	rm -fr ${viewdir}/*.jso

# Login page #
jsLogin = ${viewdir}/loginView.js \
	${modeldir}/loginStringsModel.js \
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
	${viewdir}/microhorarioView.js \
	${viewdir}/mainView.js \
	${viewdir}/classeslistView.js \
	${controllerdir}/selectedController.js \
	${srcdir}/router.js

templateMain = ${templatedir}/classeslist.template \
		${templatedir}/main.template \
		${templatedir}/microhorario.template \
		${templatedir}/timetable.template \
		${templatedir}/faltacursar.template

prisma-main.js: ${jsMain}
	cat > $@ $^
prisma-main.template: ${templateMain}
	cat > $@ $^

