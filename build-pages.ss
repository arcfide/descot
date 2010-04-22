#! /usr/bin/env scheme-script
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Build Static Descot Web Pages
;;; 
;;; Copyright (c) 2009 Aaron Hsu <arcfide@sacrideo.us>
;;; 
;;; Permission to use, copy, modify, and distribute this software for
;;; any purpose with or without fee is hereby granted, provided that the
;;; above copyright notice and this permission notice appear in all
;;; copies.
;;; 
;;; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
;;; WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
;;; WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
;;; AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL
;;; DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF USE, DATA
;;; OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER
;;; TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
;;; PERFORMANCE OF THIS SOFTWARE.
(import (chezscheme) (riastradh foof-loop) (arcfide descot web parameters))

(meta define script-root "www")
(define descot-web-docroot (make-parameter "www_static"))

(meta define valid-script?
  (lambda (fname)
    (let ([sl (string-length fname)])
      (string=? ".ss" (substring fname (- sl 3) sl)))))

(meta define script-pages
  (lambda (root)
    (collect-list (for fname (in-list (directory-list root)))
		  (if (valid-script? fname))
      (string-append script-root (string (directory-separator)) fname))))

(define-syntax include-script-files
  (lambda (x)
    (with-syntax ([(f1 ...) (script-pages script-root)])
      #'(begin (include f1) ...))))

(when (pair? (command-line-arguments))
	(descot-web-docroot (car (command-line-arguments))))

(include-script-files)

(printf "Done!~%")

(exit)