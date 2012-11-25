JSDIR = js-dev

templatedevdir = template-dev
templatedir = template

lessdevdir = less-dev
cssdir = css

# Phony targets #
all: js template css

js: 
	@cd $(JSDIR)
	$(MAKE)
	

template: prisma-login.template prisma-term.template \
	prisma-main.template
css:

# Login page #
templateLogin = ${templatedevdir}/login.template \
		${templatedevdir}/layout.template

prisma-login.template: ${templateLogin} 
	cat > ${templatedir}/$@ $^

# Term page #
templateTerm = ${templatedevdir}/term.template

${jsdir}/prisma-term.js: ${jsTerm}
	cat > $@ $^
prisma-term.template: ${templateTerm}
	cat > ${templatedir}/$@ $^

# Main page #
jsMain =
templateMain = ${templatedevdir}/classeslist.template \
		${templatedevdir}/main.template \
		${templatedevdir}/microhorario.template \
		${templatedevdir}/timetable.template \
		${templatedevdir}/faltacursar.template

${jsdir}/prisma-main.js: ${jsMain}
	cat > $@ $^
prisma-main.template: ${templateMain}
	cat > ${templatedir}/$@ $^

