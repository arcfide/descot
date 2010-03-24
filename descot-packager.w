(@chezweb)

"\\centerline{\\titlef Descot Packager}\\medskip
\\centerline{\\bf Aaron W. Hsu}\\bigskip
\\centerline{Version: 0.1}\\bigskip\\bigskip
"

(@* "The Big Idea" 
"The Descot packager is designed to improve the portability of code
that is distributed by Scheme programmers. Rather than define code
using a specific module system that must be individually translated,
into either other module systems or into Descot metadata, the
Descot packager provides an easy to write encoding of the core 
vocabulary in the Descot metalanguage in an extensible format. 
Instead of writing SRDF files for each file, you define a prelude
file that defines some basic defaults for a set of files, and you
then define specific properties for each specific library that
you have defined. This forms, in effect, a module or package
declaration of the file directly using Descot. The packager can
then build an SRDF file suitable for uploading to a Descot server
for publication and indexing, or it can be used to general system
specific modules for use by the users of the code.")

(@* "The Descot Package Language"
"The Descot Package language is defined as the code is written
here, but at a high-level, it consists of forms for defining
Class objects, properties, and objects. Any given node or object
is either a string or a list form, or, as a special case, a
symbol is considered to be a shorthand for a list form of one
element. The list form is a relative
reference, while a string form is considered an absolute reference.
Properties are designed to be used in the tails of Class forms,
and associate given class's property with some object/node.
Class forms associate a single object (subject) with a set of
properties.

\\medskip
\\verbatim
(Library (arcfide chezweb tangle)
  (author (arcfide))
  (license isc-license)
  (exports tangle me silly)
  (location
    (Gopher *
      (uri \"gopher://gopher.sacrideo.us/9chezweb/cheztangle.ss\"))))
|endverbatim
\\medskip")

(@l "We define a library that will form the execution environment of
our Descot packages."

(arcfide descot packager environment)
(export Library Binding License Person Retrieval-method Archive
        Single-file SCM CVS Implementation)
(import (chezscheme))

(@* "Class Definitions"
"The Descot metalanguage defines the following classes:

\\unorderedlist
\\li Library
\\li Binding
\\li License
\\li Person
\\li Retrieval-method
\\li Archive
\\li Single-file
\\li SCM
\\li CVS
\\li Implementation
\\endunorderedlist

\\noindent
The Descot packager defines class forms for each of these. They all
share a common form.

\\medskip
\\verbatim
(<class-name> <subject> <property> ...)
|endverbatim
\\medskip

\\noindent
This allows for a fairly straightforward definition for classes.
For each class, we provide subject root and default properties
parameters, which establish the defaults for the class, as well as
the class type, which is used to automatically insert the correct
type annotation on the class subject. Subjects, if relative, will use
the subject root parameter to fully ground their locations, and the
default properties will be added to this class, and can be defined
globally."

(@c
(define-syntax define-class
  (syntax-rules ()
    [(_ name subject-root default-properties class-type)
     (begin
       (@< |Define subject root parameter|)
       (@< |Define default properties parameter|)
       (...
         (define-syntax name
           (syntax-rules ()
             [(_ subject property ...)
              `(,(@< |Construct subject|)
                (type class-type)
                property ...
                . ,(default-properties))]))))]))))

(@ "The subject root parameter should contain a string that is the
default base root for any relatively defined subject with the given
class."

(@> |Define subject root parameter| () (subject-root) (subject-root)
(define subject-root
  (make-parameter (default-root)
    (lambda (x)
      (unless (string? x)
        (errorf 'subject-root "expected a URI string, found ~s" x))
      x)))))

(@ "The default properties parameter should be bound in the prelude
file to any properties true that hold for all subjects of a particular
class."

(@> |Define default properties parameter| 
  () (default-properties) (default-properties)
(define default-properties
  (make-parameter '()
    (lambda (x)
      (unless (or (null? x) (pair? x))
        (errorf 'default-properties 
          "Expected a list of properties, found ~s" x))
      x)))))

(@ "When a class form is used, the subject may be in either a string,
symbol, or list form. In the latter two forms, the object or subject
is considered to be a relative reference. This means that it must
be converted to a URI path and then appended to the base URI. 
A string reference is expected to be an absolute reference."

(@> |Construct subject| () () (subject-root subject name)
(cond
  [(string? subject) subject]
  [(pair? subject) (format "~a~{~a~^/~}" (subject-root) subject)]
  [(symbol? subject) (format "~a~a" (subject-root) subject)]
  [else 
    (errorf 'name
      "expected a string, list, or symbol, but found ~s"
      subject)])))

(@ "The following procedures enforce the naming conventions mentioned
in the next section."

(@c
(meta define (class-parameter class)
  (datum->syntax class
    (string->symbol (format "~a-root" (syntax->datum class)))))
(meta define (class-default-properties class)
  (datum->syntax class
    (string->sybmol (format "~a-default-properties" (syntax->datum class)))))
(meta define (class-type class)
  (datum->syntax class
    (string->symbol (format "dscts:~a" (syntax->datum class)))))))

(@ "With the above |define-class| syntax, we can then trivially
define each of the classes. However, all of the classes have a 
similar naming convention, so to enforce this, the following bulk
class definition syntax should be used. Basically, each class should
be a capitalized term, which forms the prefix for the two parameters,
namely, |root| and |default-properties|. Each should be prefixed
with the |Class-|. Finally, I assume that each class definition has
a node name defined by |dscts:Class| which is the type of the class
in RDF."

(@c
(define-syntax define-classes
  (lambda (x)
    (syntax-case x ()
      [(_ class)
       (with-syntax ([param (class-parameter #'class)]
                     [def-prop (class-default-properties #'class)]
                     [type (class-type #'class)])
         #'(define-class class param def-prop type))]
      [(_ class classes ...)
       (with-syntax ([param (class-parameter #'class)]
                     [def-prop (class-default-properties #'class)]
                     [type (class-type #'class)])
         #'(begin
             (define-class class param def-prop type)
             (define-classes classes ...)))])))))

(@ "Now I am free to define a nice looking set of classes that were
mentioned in the ealier section."

(@c
(define-classes
  Library
  Binding
  License
  Person
  Retrieval-method
  Archive
  Single-file
  SCM
  CVS
  Implementation)))

)
