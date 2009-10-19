FILES=rdf/rdf-to-sxml.sls rdf/turtle-output.sls rdf/utilities.sls \
	web/generators.sls server.sls web-app.ss srdf.sls

NW_FILES=rdf/rdf-to-sxml.nw rdf/turtle-output.nw rdf/utilities.nw \
	web/generators.nw server.nw web-app.nw srdf.nw

DEPSFILE=BUILD_LIBS

.SUFFIXES: .so .ss .sls .nw

build: ${FILES}

server: build
	build.ss descot-web-server.so build ${DEPSFILE}

docs: 
	noweave -delay -t2 ${NW_FILES} > doc/tech/main.tex

clean: 
	rm -f ${FILES} 
	rm -f *.so
	rm -f *.c
	rm -f descot-web-server
	rm -rf www_static

clean_www:
	rm -rf www_static

.nw.ss: 
	notangle -R$(@F) -t2 $< > $@

.nw.sls:
	notangle -R$(@F) -t2 $< > $@

.ss.so:
	@echo '(compile-file "$*")' | scheme -q
