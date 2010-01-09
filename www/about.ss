;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Descot Web Application About Page
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

(import 
  	(arcfide descot web generators)
  	(arcfide descot web parameters)
  	(arcfide descot web utilities))

(define (about-page)
  (descot-wrapper "About" descot-stylesheet
    `(div (@ (class "left_box"))
       (a (@ (href "/10-rdf-schema")) "Descot RDF Schema")
       " | "
       (a (@ (href "http://www.w3.org/TR/rdf-primer/")) "RDF Primer")
       " | "
       (a (@ (href "/docs/descot-scheme-workshop-2009.pdf"))
         "Scheme Workshop Paper")
       " | "
       (a (@ (href "#guides")) "Guides (Getting Started)"))
    (h3 "Overview")
    (p
      "So you've written your Scheme code that's going to save the
       world; now what? How do you make sure that people can learn about
       your library? How do you make it easy for others to port your
       library to their preferred Scheme implementation? In essence, how
       do you share your code with others? Descot helps you do this
       easier.")
    (p
      "Descot is a collection of technologies all surrounding a semantic
       web framework that, in essence, portably describes the meta
       information related to your Scheme code. It allows you to share
       and use this information in useful ways. For example, you can
       easily upload this information to a Descot repository, and users
       can track updates and search for your library. Other repositories
       can mirror this information and central repostories can collect
       Scheme code together in a single place, for it to be found, and
       shared.")
    (p
      "Descot doesn't stop there. In essence, Descot is information and
       process. You can provide Descot meta files with your code, and
       someone who grabs your Scheme code can then generate module files
       for their own Scheme implementation just from the Descot
       meta-information: you don't have to do it.")
    (p
      "Descot is the core foundation that lets users communicate
       information about Scheme code with each other, without being
       bound by the same toolset, implementation, or really, just about
       anything else. Descot exposes the communications layer that
       supports things like packaging and indexing libraries. It doesn't
       tell you what tools to use, and in fact, Descot's meta-language
       can be extended in compatible ways to let you add new information
       for your specific tools if you want. Descot can be a foundation
       for your implementation packages, if you wanted, for example.")
    (h3 "Goals")
    (ol
      (li "To aggregate and bring together as much Scheme code as possible.")
      (li "To deliver portable/easy-to-port code.")
      (li "To deliver high quality code.")
      (li "To reduce developer burden when attempting to use libraries."))
    (h3 "Plans")
    (p
      "The current 1.0 release has seen a bit of testing, and revealed
       the need for some minor extensions to the language in order to
       achieve its goals. These changes will be released as the 1.1
       version of the Descot meta-language.")
    (p 
      "Once these updates are made, A set of tools are in the works to
       make using Descot easy. They are designed to make a few things
       very easy to do:")
    (ul
      (li "Packaging Scheme code portably")
      (li "Publishing your Scheme code"))
    (p
      "With these tools, users will be able to grab your code an easily
       port it to their implementation. As a library writer, you'll be
       able to easily submit your code in a convenient format to Descot
       repositories that will make your code public, visible, and easily
       found and downloaded by other users.")
    (p
      "At the moment, we are not going to be developing the end-user
       client tools for Descot repositories, yet. These are the tools
       that let you grab and easily install/use libraries that are
       published on repostories, like apt-get does for other programs.
       Nonetheless, we hope that people will write their own. We do
       provide a web client, which runs on our Descot repository, but
       we'd like to see integration with tools like Snow.") 
    (h3 "Getting Started")
    (p '(a (@ (name "guides")) "")
      "Descot has many facets, so it can be confusing when you're just
       starting out. To help with that, we've made several guides made
       specifically for users who just want to know what they need to
       know to use Descot for themselves.")
    '(dl
       (dt 
         (a (@ (href "/docs/packager_guide.pdf"))
           "Descot Guide to Packaging"))
       (dd
         "If you want to use Descot to package your libraries and code in
          a portable manner, see this guide.")
       (dt
         (a (@ (href "/docs/publisher_guide.pdf"))
           "Descot Guide to Sharing Code"))
       (dd
         "If you want to use Descot to share your code with others, see
          this guide, which will show you how to share your code easily
          using Descot")
       (dt
         (a (@ (href "/docs/repository_guide.pdf"))
           "Descot Guide to Repositories"))
       (dd
         "If you are interested in hosting your own repository, this is
          the guide for you.")
       (dt
         (a (@ (href "/docs/client_guide.pdf"))
           "Descot Guide for the Leecher"))
       (dd
         "If you have some Descot packaged or shared code (maybe a friend
          gave it to you or you found it on a Descot Repository), and
          just want to know how to make use of either the code or a
          Descot repository, this is the guide for you.")
       (dt
         (a (@ (href "/docs/technical_documentation.pdf"))
           "Descot Technical Documentation"))
       (dd
         "If you are a crazy mad hacker, and want to work on the Descot
          internals, see here."))
    (h3 "What Descot is NOT")
    (p
      "Descot is "
      '(strong "not")
      " the entire package. It doesn't solve all the problems 
       or provide all the tools that you need to manage packages. 
       It makes it clear how tools are to communicate, and 
       provides a standard interface for you to work with 
       repositories, but it doesn't try to say how you should 
       use the library information available in the repositories. 
       We intend to provide some basic tools for users and
       authors, which should work well, but remember that 
       Descot's focus isn't on the tools, its on how the 
       tools talk. I hope that the Scheme community will 
       step up and write their own tools to connect in with 
       Descot, thus enhancing what people can do with Descot 
       and making it better for everyone.")
    (p
      "Descot also isn't a specific server for hosting 
       libraries. It specifies how a server should behave, but 
       it doesn't force you to use any one server over another. 
       I provide a server for general use, and I hope to mirror 
       most of the servers that will be launched, but there 
       isn't any reason to host library information directly 
       on my server unless you want to. It is easy to 
       run your own descot server, and I'm writing more tools 
       to make it easier everyday.")
    (p 
      "Most importantly, Descot isn't complete yet. It has a 
       lot of cool things in it, but this isn't it! We'll be 
       adding much more in the days ahead.")))

(printf "~a~%" (string-append (descot-web-docroot) "/about.html"))
(call-with-output-file (string-append (descot-web-docroot) "/about.html")
  (lambda (port)
    (put-string port (write-html-page (about-page))))
  'replace)
