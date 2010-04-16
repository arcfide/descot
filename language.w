(@chezweb)

"\\centerline{\\titlef Descot Package Language/Syntax}\\medskip
\\centerline{\\bf Aaron W. Hsu}\\bigskip
\\centerline{Version: 0.3}\\bigskip\\bigskip

\\noindent
Descot Packager is a utility to assist in the creation and use
of Descot stores. It is intended to be used as an easier packaging
format for programmers who write libraries. After writing the code
for the library, the programmer can write a Descot package description,
which can be then turned into an SRDF file for submission to Descot
repositories, or, it can be used to generate implementation specific
Module declarations.\\bigskip

\\rendertoc"

(@* "The Descot Package Language"
"The Descot Package language is an encoding of a specific RDF based
language in prefix notation. It allows for easier and more natural
construction of Descot stores without having to do all of the heavy
syntax work that SRDF, XML, or Turtle would require.

Descot's meta language is composed of classes and properties. These
two families of vocabulary each have their own ``semantics'' and
most classes behave similarly and are used, in Descot, similarly,
while properties also fall into various use cases, based on their
domain and range.

When you create new objects, you want to associate them with particular
classes, and then associate them with a number of properties. That is
a subject node generally has a class type and then a series of properties
following it. This is accomplished using the class constructors defined
below. So, when we define a new subject for a library that we would
like to call |(arcfide chezweb tangle)|, we might write something
like this:

\\medskip
\\verbatim
(Library (arcfide chezweb tangle)
  (author (arcfide))
  (license isc-license)
  (exports tangle me silly)
  (location
    ,(Single-file *
       (uri \"gopher://gopher.sacrideo.us/9chezweb/cheztangle.ss\"))))
|endverbatim
\\medskip

The syntax for each of the properties is defined below in the corresponding
sections, and the class syntax is also defined below. Subjects are
resolved as below into URIs. In fact, in the end, when evaluating this
expression, we get out an SRDF expression suitable for use in Descot
repositories.
")

(@l "We define a library that will form the execution environment of
our Descot packages."

(arcfide descot packager language)
(export Library Library-root Library-default-properties
        Binding Binding-root Binding-default-properties
        License License-root License-default-properties
        Person Person-root Person-default-properties
        Retrieval-method Retrieval-method-root 
        Retrieval-method-default-properties
        Archive Archive-root Archive-default-properties
        Single-file Single-file-root Single-file-default-properties
        SCM SCM-root SCM-default-properties
        CVS CVS-root CVS-default-properties
        Implementation Implementation-root 
        Implementation-default-properties
        default-root
        parameterize unquote
        name alternatives description homepage import alternative-names
        export license authors creation modified contact implementation
        version location categories copyright-year copyright-owner
        email url cvs-root cvs-module)
(import (except (chezscheme) define-property import))

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
       (@< |Define subject root parameter| subject-root)
       (@< |Define default properties parameter| default-properties)
       (...
         (define-syntax name
           (syntax-rules ()
             [(_ subject property ...)
              `(,(@< |Construct subject| subject-root 'subject name)
                ,(type class-type)
                ,property ...
                . ,(default-properties))]))))]))))

(@ "Every parameter that is create should have a default failback.
This is the |default-root| parameter."

(@c
(define default-root
  (make-parameter ""
    (lambda (s)
      (assert (string? s))
      s)))))

(@ "The subject root parameter should contain a string that is the
default base root for any relatively defined subject with the given
class."

(@> |Define subject root parameter| () (subject-root) (subject-root)
(define subject-root
  (make-parameter (default-root)
    (lambda (x)
      (assert (string? x))
      x)))))

(@ "The default properties parameter should be bound in the prelude
file to any properties true that hold for all subjects of a particular
class."

(@> |Define default properties parameter| 
  () (default-properties) (default-properties)
(define default-properties
  (make-parameter '()
    (lambda (x)
      (assert (or (null? x) (pair? x)))
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
  [(symbol? subject) 
   (if (eq? '* subject) '* (format "~a~a" (subject-root) subject))]
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
    (string->symbol (format "~a-default-properties" (syntax->datum class)))))
(meta define (class-type class)
  #`(dscts #,(symbol->string (syntax->datum class))))))

(@ "With the above |define-class| syntax, we can then trivially
define each of the classes. However, all of the classes have a 
similar naming convention, so to enforce this, the following bulk
class definition syntax should be used. Basically, each class should
be a capitalized term, which forms the prefix for the two parameters,
namely, |root| and |default-properties|. Each should be prefixed
with the |Class-|. Finally, I assume that each class definition has
a node name defined by |(dscts \"Class\")| which is the type of the class
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
  Syntax
  License
  Person
  Retrieval-method
  Archive
  Single-file
  SCM
  CVS
  Implementation)))

(@* "Properties"
"Properties accept as their arguments forms which are meant to 
indicate the type of object associated with a given property. At
the root, a property establishes some property associate with the
object created from its arguments:

\\medskip
\\verbatim
(<property> <object> ...)
|endverbatim
\\medskip

\\noindent The |property| will be some URI, and the object will be
some proper object list. In order to define a property, we are
defining some syntax, which accepts some syntax for the arguments
and then performs some transformation on it to build the object.
Additionally, we provide the property's URI. Notice the allowance 
for auxilary keywords here. Originally, this was not required, but
it exists here to enable us to do escaping later on, which allows us
to embed arbitrary code into our objects. This comes in quite handy
when dealing with node properties and anonymous, blank nodes."

(@c
(define-syntax define-property
  (syntax-rules ()
    [(_ name uri (key ...) clause ...)
     (define-syntax name
       (property-syntax-rules uri (key ...) () clause ...))]))))

(@ "The |property-syntax-rules| macro makes sure to check the input
clause forms, which should be one of the following forms:

\\medskip
\\verbatim
((e ...) test? body)
((e ...) body)
|endverbatim
\\medskip

\\noindent It then creates a |syntax-rules| form of the following
shape:

\\medskip
\\verbatim
(syntax-rules (key ...)
  [(_ e ...) test? `(,uri . ,body)] ...)
|endverbatim
"

(@c
(define-syntax property-syntax-rules
  (syntax-rules (aux)
    [(_ uri (key ...) (((e ...) pass? body) ...))
     (syntax-rules (key ...)
       [(_ e ...) pass?
        `(,uri . ,body)]
       ...)]
    [(_ uri (key ...) (checked ...) ((e ...) test? body) rest ...)
     (property-syntax-rules uri (key ...)
       (checked ... ((e ...) test? body))
       rest ...)]
    [(_ uri (key ...) (checked ...) ((e ...) body) rest ...)
     (property-syntax-rules uri (key ...)
       (checked ... ((e ...) #t body))
       rest ...)]))))

(@* "Grounding/resolving relative references."
"Properties will usually have to ground their relative object
references in some way or another based on some root URI. The 
following procedure can help with that."

(@c
(define (resolve root relative)
  (assert (string? root))
  (assert (or (string? relative)
              (pair? relative)
              (symbol? relative)))
  (cond
    [(string? relative) (string-append root relative)]
    [(pair? relative) (format "~a~{~a~^/~}" root relative)]
    [(symbol? relative) (format "~a~a" root relative)]))))

(@* "Typed Properties"
"While using |define-property| by itself is okay, there are a 
number of common idioms for properties that show up, so rather than
writing each of these repeatedly, I define some of these patterns
here.")

(@ "|define-string-property| defines a property that expects a
single string argument as the object."

(@c
(define-syntax define-string-property
  (syntax-rules ()
    [(_ name uri)
     (define-property name uri ()
       [(s) (string? (syntax->datum #'s))  `(($ ,s))])]))))

(@ "|define-date-property| defines a property that expects a
single date string in a standard RDF dateTime format."

(@c
(define-syntax define-date-property
  (syntax-rules ()
    [(_ name uri)
     (define-property name uri ()
       [(s) (string? (syntax->datum #'s))
        `((^ ,s ,(xsd "dateTime")))])]))))

(@ "A special case of the date format is the Year format, and so I
define |define-year-property| to handle cases that expect the year."

(@c
(define-syntax define-year-property
  (syntax-rules ()
    [(_ name uri)
     (define-property name uri ()
       [(y) (integer? (syntax->datum #'y))
        `((^ ,(number->string y) ,(xsd "gYear")))])]))))

(@ "|define-node-proprety| defines a proprety that expects a single
node. A single node is normally resolved using the resolve procedure
defined above, but it is also possible to use |unquote| to enable
arbitrary code to be run and the result inserted as an object. This
adds the necessary flexibility for doing something like

\\medskip
\\verbatim
(location
  ,(Single-file * (url \"my-code.ss\")))
|endverbatim
\\medskip

Where the above node property |location| expects a node as an object.
Here, we may not want to give a name to each of these files, and it
is much better to inline this sort of code, which we do by using the
blank node feature of classes. However, without the unquote, this
would get treated as the tail end of a URI and resolved. The |unquote|
above prevents this an enables us to do this sort of thing."

(@c
(define-syntax define-node-property
  (syntax-rules ()
    [(_ name uri root)
     (define-property name uri (unquote)
       [(,n) `(,n)]
       [(n)
        (let ([x (syntax->datum #'n)])
          (or (string? x) (pair? x) (symbol? x)))
        `(,(resolve (root) 'n))])]))))

(@ "|define-node-list-property| defines a property that expexts a
list of nodes as its objects. The node properties helper ensures that
the |unquote| case is handled just as in the single node property
definitions."

(@c
(define-syntax define-node-list-property
  (syntax-rules ()
    [(_ name uri root)
     (begin
       (meta define (valid? x)
         (let ([x (syntax->datum x)])
           (or (string? x) (pair? x) (symbol? x))))
       (@< |Define node-properties helper| valid? root)
       (... (define-property name uri ()
         [(e1 e2 ...)
          (list (node-properties e1 e2 ...))])))]))))

(@ "The |node-properties| syntax mentioned above needs to create a list
of the object URIs. However, I want to apply the same unquote behavior
to this as I do to the normal singleton node properties definition."

(@> |Define node-properties helper| () (node-properties) (valid? root)
(... (define-syntax node-properties
  (syntax-rules (unquote)
    [(_ (unquote e)) (list e)]
    [(_ e) (list (resolve (root) 'e))]
    [(_ (unquote e1) e2 ...)
     (cons e1 (node-properties e2 ...))]
    [(_ e1 e2 ...)
     (cons (resolve (root) 'e1) (node-properties e2 ...))])))))

(@ "|define-string-list-proprety| defines a property that expects
one or more strings as objects."

(@c
(define-syntax define-string-list-property
  (syntax-rules ()
    [(_ name uri)
     (define-property name uri ()
       (...
         [(e1 e2 ...)
          (for-all string? (map syntax->datum #'(e1 e2 ...)))
          `((($ e1) ($ e2) ...))]))]))))

(@* "Descot Property Definitions"
"The following are the defined properties for Descot."

(@c
(define-string-property name (dscts "name"))
(define-node-property alternatives (dscts "alts") default-root)
(define-string-property description (dscts "desc"))
(define-node-property homepage (dscts "homepage") default-root)
(define-node-list-property import (dscts "deps") Library-root)
(define-string-list-property alternative-names (dscts "names"))
(define-node-list-property export (dscts "exports") Binding-root)
(define-node-property license (dscts "license") License-root)
(define-node-list-property authors (dscts "authors") Person-root)
(define-date-property creation (dscts "creation"))
(define-date-property modified (dscts "modified"))
(define-node-property contact (dscts "contact") Person-root)
(define-node-property implementation (dscts "implementation")
  Implementation-root)
(define-string-property version (dscts "version"))
(define-node-property location (dscts "location") Retrieval-method-root)
(define-string-list-property categories (dscts "categories"))
(define-year-property copyright-year (dscts "copyright-year"))
(define-node-property copyright-owner (dscts "copyright-owner") Person-root)
(define-string-property email (dscts "email"))
(define-string-property url (dscts "url"))
(define-string-property cvs-root (dscts "cvs-root"))
(define-string-property cvs-module (dscts "cvs-module"))))

(@* "Descot Node URIs"
"All Descot nodes are prefixed with the same URI prefix, so I define
the following helper to make sure that the prefix is thrown in at
the appropriate points."

(@c
(define (dscts x)
  (string-append
    "http://descot.sacrideo.us/11-rdf-schema#"
    x))))

(@ "|type| is a unary procedure that take some class type and returns a
SRDF predicate of the form |((: rdfs \"hasType\") class-type)| assuming
that |rdfs| is the standard RDF Syntax prefix."

(@c
(define rdf:type "http://www.w3.org/1999/02/22-rdf-syntax-ns#type")
(define (type class)
  `(,rdf:type ,class))))

(@ "|xsd| is a node constructor that creates XSD nodes using the
appropriate prefix."

(@c
(define (xsd suffix)
  (string-append
    "http://www.w3.org/2001/XMLSchema#"
    suffix))))

)
