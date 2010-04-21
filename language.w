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

This encoding allows us to lose some of the generality of normal RDF
graphs, in exchange for making it easier to write graphs that use a
specific vocabulary. Essentially, to build a Descot Package file is
to define a graph by specifying the association or edges associated
between a given subject and a series of objects. That is, a Descot
package file consists of global definitions and |node| forms. These
|node| forms associate a particular subject of a given type with zero
or more properties. So, a package file consists of a series of the
following forms:
 
\\medskip\\verbatim
<definition>
(node <subject> : <class> <property> ...)
|endverbatim
\\medskip
 
\\noindent
Details about subjects, properties, and classes are given in the
following sections. The combination of all of these associations forms
a graph of the various nodes and edges given in the file(s). 
Additionally, I have omitted some of the details from the above. There
are actually two other forms that could occur at the top level, and
technically, any property may also be used at the top level. This is
simply a lack of desire on my part to restrict this. It's useful, for
example, if I want to use a syntactic property inside the middle of an
SRDF literal. The additional forms that may occur are |with-escaper|
and |blank-node|. |with-escaper| is detailed in its own section, and
|blank-node| is also detailed when we talk about the |node| form.
Blank nodes have no meaning when they are used at the top level, so
while they are legal, they are essentially no-ops.
 
The output of these files is SRDF code, and these forms can be thought
of as a syntactic wrapping around SRDF. That is, they have rather
direct mappings to SRDF equivalents, provided that we allow for the
specific syntactic limitations imposed by each. They are not as
general as SRDF forms.
 
However, since these forms simply represent a special Scheme
evaluation environment that can be used to build an SRDF expression
list, it is also reasonable for us to allow that SRDF can be listed in
any place where you can place a raw Scheme value and have it
interpreted. This would be at the top level and anywhere that is
escaped by an escape form. The quoted SRDF datum may then be given
directly, instead of relying on the specific syntactic forms given
here. This allows you to use the syntactic forms whenever possible,
but allows you to break this form and use SRDF when necessary.

It would help, I imagine, if you had an example to go by:
 
\\medskip
\\verbatim
(node (arcfide chezweb tangle) : library
  (author (arcfide))
  (license isc-license)
  (exports tangle me silly)
  (with-escaper unquote
    (location
      ,(blank-node 
         (uri \"gopher://gopher.sacrideo.us/9chezweb/cheztangle.ss\"))))
|endverbatim
\\medskip
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
        parameterize escaper 
        define-class node :
        name alternatives description homepage import alternative-names
        export license authors creation modified contact implementation
        version location categories copyright-year copyright-owner
        email url cvs-root cvs-module)
(import (except (chezscheme) define-property import)
        (arcfide extended-definitions))

(@* "Class Definitions"
"Whenver we create a new node in a Descot graph, we will almost
certainly associate that node with some particular class. Each class
provides information to our nodes about how they should behave and
what valid properties can be used. Within the Packager language, we
also use them to provide roots and property defaults for resolving
node names and inserting properties for each class of nodes. 
 
At the moment, classes are used only to resolve the subjects and fill
in default properties. It could also be used to do error checking on
the properties, but this is not implemented yet. 

The Descot metalanguage defines the following classes:

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
For each class, we provide subject root and default properties
parameters, which establish the defaults for the class, as well as
the class type, which is used to automatically insert the correct
type annotation on the class subject. Subjects, if relative, will use
the subject root parameter to fully ground their locations, and the
default properties will be added to this class, and can be defined
globally."

(@c 
(define-syntax define-class
  (syntax-rules (root defaults uri)
    [(_ name subject-root default-properties class-type)
     (begin
       (@< |Define subject root parameter| subject-root)
       (@< |Define default properties parameter| default-properties)
       (module ((name %class-type))
         (define %class-type class-type)
         (define-syntax name
           (syntax-rules (root defaults uri)
             [(_ root) (subject-root)]
             [(_ defaults) (default-properties)]
             [(_ uri) %class-type]))))]))))

(@ "Even though we do define a root parameter for every class, it's
likely that some of these default root parameters will not be defined
Thus, we should have a |default-root| property that can be used as a
fallback."

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

(@> |Define classes| ()
  (Library Library-root Library-default-properties
   Binding Binding-root Binding-default-properties
   Syntax Syntax-root Syntax-default-properties
   License License-root License-default-properties
   Person Person-root Person-default-properties
   Retrieval-method Retrieval-method-root Retrieval-method-default-properties
   Archive Archive-root Archive-default-properties
   Single-file Single-file-root Single-file-default-properties
   SCM SCM-root SCM-default-properties
   CVS CVS-root CVS-default-properties
   Implementation Implementation-root Implementation-default-properties)
  ()

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

(@* "Constructing Subject URIs"
"When a |node| form is used, the subject may be in either a string,
symbol, or list form. In the latter two forms, the object or subject
is considered to be a relative reference. This means that it must
be converted to a URI path and then appended to the base URI. 
A string reference is expected to be an absolute reference."

(@> |Construct subject| () () (subject-root subject name)
(cond
  [(string? subject) subject]
  [(pair? subject) (format "~a~{~a~^/~}" subject-root subject)]
  [(symbol? subject) 
   (if (eq? '* subject) '* (format "~a~a" subject-root subject))]
  [else 
    (errorf 'name
      "expected a string, list, or symbol, but found ~s"
      subject)])))
 
(@* "Creating new Descot nodes"
"Whenever we want to generate a new node, with a given set of
properties, we use |node|. Creating a new node consists of providing a
subject URI, its type or class, and then the set of properties and
objects associated with that subject node. A node form has the
following form:
 
\\medskip\\verbatim
(node <subject> : <class> <property> ...)
|endverbatim
\\medskip

The |<subject>| should be a valid subject as defined in the previous
section --- a string, list, or symbol --- and the |<class>| should be
a class defined by |define-class|. Each property should be a property
form as described in the following sections. When this form is
expanded, it expands into an SRDF literal whose subject is resolved
using the root from the |<class>| and has at least the default
properties given by the |<class>| default properties parameter. "
 
(@c 
(define-syntax node
  (syntax-rules (:)
    [(_ subj : class prop ...)
     `(,(@< |Construct subject| (class root) 'subj node)
       ,(type (class uri))
       ,prop ...)]))
(define-auxilary-keywords :)))

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

(@* "Grounding/resolving relative references"
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
defined above, but it is also possible to use and escape keyword to
evaluate arbitrary code and have the result inserted as an object. This
adds the necessary flexibility for doing something like

\\medskip
\\verbatim
(location
  ,(Single-file * (url \"my-code.ss\")))
|endverbatim
\\medskip

\\noindent
In this above code |escaper| is set to |unquote| which is the default.
Where the above node property |location| expects a node as an object.
Here, we may not want to give a name to each of these files, and it
is much better to inline this sort of code, which we do by using the
blank node feature of classes. However, without the |unquote|, this
would get treated as the tail end of a URI and resolved. The |unquote|
above prevents this an enables us to do this sort of thing."

(@c
(define-syntax define-node-property
  (syntax-rules ()
    [(_ name uri root)
     (define-property name uri ()
       [((esc n)) (free-identifier=? #'esc (current-escaper)) `(,n)]
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
       (module ((name node-properties))
         (@< |Define node-properties helper| valid? root)
         (... (define-property name uri ()
           [(e1 e2 ...)
            (list (node-properties e1 e2 ...))]))))]))))

(@ "The |node-properties| syntax mentioned above needs to create a list
of the object URIs. However, I want to apply the same unquote behavior
to this as I do to the normal singleton node properties definition."

(@> |Define node-properties helper| () (node-properties) (valid? root)
(... (define-syntax node-properties
  (syntax-rules ()
    [(_ (esc e)) (free-identifier=? #'esc (current-escaper)) (list e)]
    [(_ e) (list (resolve (root) 'e))]
    [(_ (esc e1) e2 ...) (free-identifier=? #'esc (current-escaper))
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

(@> |Define properties| ()
  (name alternatives description homepage import export
   alternative-names license authors creation modified contact
   implementation version location categories copyright-year
   copyright-owner email url cvs-root cvs-module)
  ()

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

(@* "Escapes"
"When writing node properties, each node is essentially a quoted form
that is not evaluated, but analyzed for its shape and converted and
used as a datum. Sometimes, you may want to pass a datum directly
through, and you may want to have that datum obtained as the result of
evaluating the form instead of treating it like a datum. Escapes
provide a way for you to do this. By default, |unquote| is used as the
escaper, but this section defines the forms used to control what
escape keyword is used.
 
Two forms are defined in this section: |escaper| and |with-escaper|.
The |escaper| form works like a syntactic parameter. The
|with-escaper| form allows you to rebind the |escaper| parameter for a
specific duration. 
 
When using the |escaper| syntax paramter directly, evaluating the form
|(escaper)| will result in the current escaper identifier, whereas
doing something like |(escaper jump)| will set |jump| to be the new
escape keyword. This keyword controls how node properties handle their
nodes. So, if you have a node property |prop| that you want to pass
something directly, by evaluating it instead of treating it like a
node form, you might do something like this: 
 
\\medskip\\verbatim
(escaper lift)
(prop (lift (list 'a 'b 'c)))
|endverbatim
\\medskip
 
\\noindent
This would return a property sub-form where |prop| was directly
associated with the object |(a b c)|. By default, |unquote| is used as
the escaper."
 
(@> |Define escaper| () (escaper) ()
(define-syntax (escaper x)
  (syntax-case x ()
    [(_) #`#'#,(current-escaper)]
    [(_ id) (identifier? #'id)
     (begin
       (current-escaper #'id)
       #'(begin))]))))

(@ "|current-escaper| is a compile-time parameter that stores the
identifier that is used by node properties and |escaper|."

(@c
(meta define current-escaper
  (make-parameter #'unquote
    (lambda (x) 
      (unless (identifier? x) 
        (error 'current-escaper "expected identifier, found ~s" x))
      x)))))

(@ "{\\f Note: This section details a feature that does not currently
function as documented, it is therefore not exported and should not be
used.}
The |with-escaper| form sets and resets the |escaper| syntax
parameter for the duration of the body code, which it splices into the
existing code. It's form should look like this:
 
\\medskip\\verbatim
(with-escaper <id> <body> ...)
|endverbatim
\\medskip
 
\\noindent
And it will expand to something like this:
 
\\medskip\\verbatim
(escaper <id>)
<body> ...
(escaper <old-id>)
|endverbatim
\\medskip
 
\\noindent
You can wrap many forms with the |with-escaper| form, so it is
possible to parameterize the escape form over a number of node
definitions."
 
(@c
(define-syntax (with-escaper x)
  (syntax-case x ()
    [(_ id body ...)
     (let ([old-id (current-escaper)])
       (current-escaper #'id)
       #`(begin
           body ...
           (escaper #,old-id)))]))))

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

(@* "Program Ordering"
"The following is the compiler order for the above chunks."

(@c
(@< |Define escaper|)
(@< |Define classes|)
(@< |Define properties|)))

)
