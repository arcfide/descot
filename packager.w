(@chezweb)

"\\centerline{\\titlef Descot Packager}\\medskip
\\centerline{\\bf Aaron W. Hsu}\\bigskip
\\centerline{Version 0.7}\\bigskip\\bigskip

\\noindent
Descot Packager is a utility to assist in the creation and use
of Descot stores. It is intended to be used as an easier packaging
format for programmers who write libraries. After writing the code
for the library, the programmer can write a Descot package description,
which can be then turned into an SRDF file for submission to Descot
repositories, or, it can be used to generate implementation specific
Module declarations.\\bigskip

\\rendertoc"

(@* "Descot Packager Main Program"
"\\noindent The |packager| program defined here processes the input files
and generates output to standard output of the given type specified
by |<output-type>|. At least the output-type SRDF is supported.
Additional modules supporting different output types can be loaded
dynamically based on what is available.

\\verbatim
packager: <output-type> <input-file> ...
|endverbatim"

(@> |Main Program| () () ()
(import (chezscheme))
(@< |Output handler functions|)
(scheme-start
  (lambda fns
    (@< |Validate command line| fns module-exists?)
    (@< |Maybe load processor| fns module-path)
    (@< |Process files and print| fns)))))

(@* "Validating Input"
"We should make sure that each package file can be loaded and that
the module is a valid one."

(@> |Validate command line| () () (fns module-exists?)
(assert (pair? fns))
(assert (for-all file-exists? (cdr fns)))
(assert 
  (or (string-ci=? "srdf" (car fns))
      (module-exists? (car fns))))))

(@* "Loading the output processors"
"If the output type specified is not a derivative of |SRDF|, then we 
assume that it is the name of a module that is available in the
|module-path| directory. Loading such a module should define a single
procedure |converter| that, given an SRDF expression list,
prints the results to standard output.
 
If no special output type is defined, the default module handler is
used which just prints out the SRDF code directly."

(@> |Maybe load processor| () () (fns module-path)
(cond
  [(string-ci=? "srdf" (car fns))
   (define-top-level-value 'converter
     (lambda (x)
       (for-each pretty-print x)))]
  [else
    (parameterize ([source-directories `(,(module-path))])
      (load (car fns)))])))

(@* "Processing package files"
"To process each package file, we load it with the appropriate 
evaluation procedure, which takes the form, |eval|s it through the
|(arcfide descot packager language)| environment, and then runs the
converter on it. It is important to have a specific order of 
evaluation for processing each file, and we have chosen a left to 
right order."

(@> |Process files and print| () () (fns)
(converter
  (reverse
    (fold-left
      (lambda (s file) (append (@< |Process file| file) s))
      '()
      (cdr fns))))))

(@ "Processing each file means going through and collecting up
each evaluation result, after we eval it in the correct language
environment."

(@> |Process file| () () (file)
(with-input-from-file file
  (lambda ()
    (let ([env (environment '(arcfide descot packager language))])
      (let loop ([res '()])
        (let ([form (read)])
          (if (eof-object? form)
              res
              (loop 
                (let ([x (eval form env)])
                  (if (eq? x (void))
                      res
                      (cons x res))))))))))))

(@* "Utilities for Output types"
"When handling the output type specifier, it's helpful to be able to
tell whether the module exists, and provide a means for setting the
module path. The module path is determined by checking for the
|DSCTPKGRMODPATH| environment variable, which should point to a 
directory that contains all of the Descot Packager modules for the 
output types."

(@> |Output handler functions| () (module-path module-exists?) ()
(define module-path
  (make-parameter (or (getenv "DSCTPKGRMODPATH") "")
    (lambda (x)
      (unless (and (string? x)
                   (or (zero? (string-length x))
                       (file-exists? x)))
        (errorf 'module-path
          "module-path must point to a valid path"))
      x)))
(define (module-exists? x)
  (file-exists?
    (format "~a~a" (module-path) x)))))

(@ 
"We add the actual program here."

(@c 
(include "language.w")
(@< |Main Program|)))
