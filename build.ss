#! /usr/bin/scheme --program
(import (chezscheme) (riastradh foof-loop) (arcfide building) (arcfide ffi-bind parameters))

(unless (<= 3 (length (command-line-arguments)))
	(printf "~a : <output-program> <build-dir> <files> ... ~%" (car (command-line)))
	(exit 1))

(define (read-inputs-from-file infile)
	(collect-list (for lib (in-file infile read)) lib))

(define out-file (car (command-line-arguments)))
(define build-dir (cadr (command-line-arguments)))
(define inputs (read-inputs-from-file (caddr (command-line-arguments))))

(unless (file-exists? build-dir) (mkdir build-dir))

(ffi-build-path build-dir)
(library-extensions '(".chezscheme.sls" ".sls" ""))
(build-program out-file build-dir inputs)

(exit 0)
