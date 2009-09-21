FILES=rdf/rdf-to-sxml.sls rdf/turtle-output.sls rdf/utilities.sls \
	web/generators.sls web/utilities.ss \
	server.sls web-app.ss web-param.ss srdf.sls

NW_FILES=rdf/rdf-to-sxml.nw rdf/turtle-output.nw rdf/utilities.nw \
	web/generators.nw \
	server.nw web-app.nw srdf.nw

.SUFFIXES: .so .ss .sls .nw

build: ${FILES}

www: web-gen.ss
	build-pages.ss

www_sacrideo: web-gen.ss
	cp web-param.ss web-param.ss.stock
	patch web-param.ss web-param-sacrideo.patch
	build-pages.ss
	mv web-param.ss.stock web-param.ss

sacrideo: build
	cp web-param.ss web-param.ss.stock
	patch web-param.ss web-param-sacrideo.patch
	@echo '(compile-file "web-app")' | scheme -q
	mv web-param.ss.stock web-param.ss

docs: 
	noweave -delay -t2 ${NW_FILES} > doc/tech/main.tex

clean: 
	rm -f ${FILES} ${WEB_FILES}
	rm -f *.so

clean_www:
	rm -rf www_static

.nw.ss: 
	notangle -R$(@F) -t2 $< > $@

.nw.sls:
	notangle -R$(@F) -t2 $< > $@

.ss.so:
	@echo '(compile-file "$*")' | scheme -q
