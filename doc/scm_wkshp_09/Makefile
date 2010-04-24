descot.dvi: descot.tex sigplanconf.cls
	latex descot.tex

descot.ps: descot.dvi
	dvips -o descot.ps -t letter descot.dvi

descot.pdf: descot.ps
	ps2pdf descot.ps
