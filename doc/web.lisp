(eval-when (:compile-toplevel :load-toplevel :execute)
  (require :aserve))

(defpackage #:clpython-web
  (:use #:common-lisp #:net.html.generator))

(in-package #:clpython-web)

(defun run ()
  (create-pages))

(defun create-pages ()
  (loop for (fname name) in `(("index.html" :main)
                              ("manual.html" :manual)
                              ("dictionary.html" :dictionary)
                              ("status.html" :status))
      do  (with-open-file (f fname
			   :direction :output
			   :if-exists :supersede
			   :if-does-not-exist :create)
            (format t "Creating file ~A ...~%" fname)
	    (html-stream f (fill-page name)))))

(defparameter *style*
    "<style type=\"text/css\">
 h1, h2 {font-family: Georgia, Palatino, \"Times New Roman\", Times, serif; font-weight: normal;}
 h1 {color: navy}
 body, div {color: #000; background-color: #fff}
 h2     {font-family: Georgia, Palatino, Times, serif; font-size: 120%; xbackground-color: #ddd;
         position: relative; left: -20px; margin-right: -12px; display: inline}
 pre {font-family: \"Lucida Console\", Monaco, monospace; font-size: 80%; background-color: #dedede;
        position: relative; left: 0%; width: 100%; overflow: auto; padding: 4px}
 .input {color: brown}
 h2 + p {display: inline}
 h2:after {content: \" \\02014 \"} // 02014 = mdash
</style>")

(defgeneric fill-page (page)
  (:documentation "Emit html"))

(defmacro with-page-template (options &body body)
  (let ((title (second (find :title options :key #'first)))
        #+(or)(backlink (second (find :backlink options :key #'first)))
        (page (second (find :page options :key #'first))))
    (check-type title string)
    `(html
      (:html
       (:head (:title ,title)
              (:princ *style*))
       ((:body style "position: absolute; left: 10%; width: 80%")
        ((:div style "text-align: center; margin-bottom: 35px")

         ((:div style "text-align: left; font-size: small")
          ,(if (eq page :main) "Introduction" '((:a href "./index.html") "Introduction"))
          " | "
          ,(if (eq page :manual) "Reference Manual" '((:a href "./manual.html") "Reference Manual"))
          " | "
          ,(if (eq page :dictionary) "Dictionary" '((:a href "./dictionary.html") "Dictionary"))
          " | "
          ,(if (eq page :status) "Status" '((:a href "./status.html") "Status"))
          )
         
         (:h1 ,title))
        ,@body
        (:p)
        ((:div style "font-size: small; text-align: center")
         "&mdash; Updated "
         (:princ (multiple-value-bind (second minute hour date month year day)
                     (get-decoded-time)
                   (declare (ignore second minute hour day))
                   (format nil "~4,'0D-~2,'0D-~2,'0D" year month date)))
         " &mdash"))))))

(eval-when (:compile-toplevel :load-toplevel :execute)
(defun make-anchor-text (string)
  (string-downcase (substitute #\_ #\Space string :test #'char=)))

(defun anchor-link (string)
  `((:a href ,(concatenate 'string "#" (make-anchor-text string)))
    ,string))
)

(defmacro make-anchor-links (&rest strings)
  (assert strings)
  `(:p "[ " ,(anchor-link (car strings))
       ,@(loop for s in (cdr strings)
             collect " | "
             collect (anchor-link s))
       " ]"))
    
(defmacro h2-anchor (string)
  `((:h2 id ,(make-anchor-text string)) ,string))

(defmethod fill-page ((page (eql :main)))
  (with-page-template ((:page :main)
                       (:title "CLPython - an implementation of Python in Common Lisp"))
    
    (make-anchor-links #1="Introduction" #2="Requirements" #3="Download" #4="Running Python Code"
                       #5="Documentation" #6="Mailing Lists")

    (h2-anchor #1#)
    (:p "CLPython is a complete implementation of "
        ((:a href "http://www.python.org")
         "Python")
        " in Common Lisp. With CLPython you can run
Python programs in a Lisp environment. Moreover, libraries written in Lisp can be made available to Python code, and Python libraries can be accessed by Lisp code.")
    (:p "CLPython also offers functionality to analyse Python source code. This can be used for automatic documentation generation, and it can be used by tools that check source code for semantic errors.")

    (:p "CLPython is developed by Willem Broekema with support from Franz Inc. and released under the "
        ((:a href "http://opensource.franz.com/preamble.html")
         "LLGPL")
        ".")

    (h2-anchor #2#)
    (:p "CLPython currently requires "
        ((:a href "http://franz.com/products/allegrocl/") "Allegro CL 8.0")
        "; it should work fine in the free Express edition.
The main dependencies on Allegro CL are yacc (for parsing) and environments access
 (for compiling). Supporting other Lisp implementations is a goal.")
    (:p)
    (h2-anchor #3#)
    (:p "The source code is in a public CVS repository. To grab it: ")
    (:pre "<span class=\"input\">cvs -d :pserver:cvspublic@cvspublic.franz.com:/cvs-public login</span>
Password: <span class=\"input\">cvspublic</a><span>
<span class=\"input\">cvs -d :pserver:cvspublic@cvspublic.franz.com:/cvs-public checkout clpython</span>")
    (:p "To compile and load CLPython, use asdf to load the systems <i>clpython</i> and <i>clpython-app</i>.")
     
    (h2-anchor #4#)
    (:p "There are different ways to execute Python code. In this example we use the file <i>b2.py</i> from the Pie-thon benchmarks, which calculates the first 1000 digits of pi. To compile and run this file, we can call <i>run-python-file</i>:")
    (:pre
     "clpython(119): <span class=\"input\">(run-python-file \"parrotbench/b2.py\")</span>
 3 1 4 1 5 9 2 6 5 3 5 8 9 7 9 3 2 3 8 4 6 2 6 4 3 3 8 3 2 7 9 5 0 2 8 8 4 1 9 <i>(output truncated)</i>
clpython.app.repl(120):
"
     )
    (:p "Alternatively, we can start a read-eval-print loop, import the module, and run the main function there:")
    (:pre
     "clpython.app.repl(120): <span class=\"input\">(repl)</span>
[CLPython -- type `:q' to quit, `:help' for help]
>>> <span class=\"input\">import sys</span>
>>> <span class=\"input\">sys.path.append(\"./parrotbench/\")</span>
>>> <span class=\"input\">import b2</span>
;;; Compiling file parrotbench/b2.py
;;; Writing fasl file /Users/willem/dev/lisp/python/lib/parrotbench/b2.fasl
;;; Fasl write complete
; Fast loading /Users/willem/dev/lisp/python/lib/parrotbench/b2.fasl
#&lt;module `b2' from file #P\"parrotbench/b2.py\" @ #x172420da>
>>> <span class=\"input\">b2.main()</span>
 3 1 4 1 5 9 2 6 5 3 5 8 9 7 9 3 2 3 8 4 6 2 6 4 3 3 8 3 2 7 9 5 0 2 8 8 4 1 9 <i>(output truncated)</i>
>>>")
    (:p "Note that <i>run-python-file</i> is exported from package <i>clpython</i> and is part of the
asdf system <i>clpython</i>." (:br) "Meanwhile, <i>repl</i> is exported from package <i>clpython.app.repl</i> and is
 part of system <i>clpython-app</i>.")
    (h2-anchor #5#)
    (:p "The following documents are currently available:" (:br)
        "&#187; " ((:a href "manual.html") "Reference Manual")
        ": a complete description of CLPython;" (:br)
        "&#187; " ((:a href "dictionary.html") "Dictionary")
        ": the CLPython interface;" (:br)
        "&#187; " ((:a href "status.html") "Status")
        ": progress report of the implementation of Python functions and modules.")
    (:p)

    (h2-anchor #6#)
    (:p "There are two mailing lists, both low-traffic:"
        (:br)
        "&#187; "
        ((:a href "http://common-lisp.net/cgi-bin/mailman/listinfo/clpython-devel")
         "devel")
        ": for general discussion and bug reports;"
        (:br)
        "&#187; "
        ((:a href "http://common-lisp.net/cgi-bin/mailman/listinfo/clpython-announce")
         "announce")
        ": for announcements of new releases.")))

(defmethod fill-page ((page (eql :status)))
  (with-page-template ((:page :status)
                       (:title "CLPython - Status")
                       (:backlink t))
    (make-anchor-links #1="Language Features" #2="Modules" )

    (h2-anchor #1#)
    (:p "Almost all language features are implemented, including the <i>yield</i> statement (to create generators). Some new features, introduced with "
        ((:a href "http://docs.python.org/whatsnew/whatsnew25.html")
         "Python 2.5")
        ", have not been implemented yet. This is due to lack of time, not for technical reasons.")
    (:p "The missing language features are:")
    (:ul
     (:li "Conditional expressions: " (:pre "x = 1 if y else 0"))
     (:li "Absolute and relative Imports: " (:pre "from .. import x"))
     (:li "Generators using <i>yield</i> as expression: " (:pre "y = (yield x)"))
     (:li "The <i>with</i> statement: " (:pre "with open('foo.txt') as f:")))

    (h2-anchor #2#)
    (:p "The following modules of the "
        ((:a href "http://python.org/doc/current/modindex.html")
         "Python standard library")
        " are currently being implemented:")
    (:ul
     (loop for p in (sort (excl:package-children :clpython.module) #'string< :key #'package-name)
         for first = t then nil
         do (let* ((completeness (or (nth-value 1 (clpython::package-impl-status p)) 0))
                   (percentage (round (* 100 completeness))))
             (html (:li (eval `(html ,(anchor-link (clpython::relative-package-name p))))
                        ": "
                        (:princ percentage)
                        "%"
                        (when first
                          (html " completed")))))))))

(defmethod fill-page ((page (eql :manual)))
  (with-page-template ((:page :manual)
                       (:title "CLPython Reference Manual")
                       (:backlink t))
    (make-anchor-links #10="ASDF Systems" #11="Packages" #1="Readtables" #2="Parser"
                       #4="Compiler" #5="Runtime" #6="Test suite")
 
    (h2-anchor #10#)
    (:p "The CLPython source code is divided into three ASDF systems:")
    (:ul (:li "<i>clpython</i> contains the parser, compiler and runtime;")
         (:li "<i>clpython-test</i> contains the test suite for <i>clpython</i>;")
         (:li "<i>clpython-app</i> contains applications built on top of CLPython, for example the read-eval-print loop (\"interpreter\" in Python parlance)."))
    (:p "To load the runtime and applications:")
    (:pre "(asdf:operate 'asdf:load-op :clpython-app)")
    (:p "Both <i>clpython-test</i> and <i>clpython-app</i> depend on <i>clpython</i>, and the latter system will thus be loaded automatically when one of the former is.")
    (:p "To run the test suite, either of these two expressions can be used:")
    (:pre "(asdf:operate 'asdf:load-op :clpython-test)
\(asdf:operate 'asdf-test-op :clpython)")

    (h2-anchor #11#)
    (:p "CLPython has one main package, named <i>clpython</i>, which is the package that other packages typically <i>use</i>. But internally the functionality is spread over separate packages:")
    (:ul (:li "<i>clpython:</i> &nbsp;main package"
              (:ul (:li "<i>clpython.parser:</i> &nbsp; parser and code walker")
                   (:li "<i>clpython.ast:</i> &nbsp; aggregation package for abstract syntax tree representation"
                        (:ul (:li "<i>clpython.ast.reserved:</i> &nbsp;reserved words")
                             (:li "<i>clpython.ast.operator:</i> &nbsp;mathematical operators")
                             (:li "<i>clpython.ast.punctuation:</i> &nbsp;punctionation characters")
                             (:li "<i>clpython.ast.node:</i> &nbsp;AST nodes")))
                   (:li "<i>clpython.user:</i> &nbsp; identifiers in Python code"
                        (:ul (:li "<i>clpython.user.builtin</i>")
                             (:li "<i>clpython.user.builtin.type</i>")
                             (:li "<i>clpython.user.builtin.type.exception</i>")
                             (:li "<i>clpython.user.builtin.value</i>")))
                   (:li "<i>clpython.module:</i> &nbsp;aggregation package of Python modules")
                   (:li "<i>clpython.app:</i> &nbsp;programs and utilities"
                        (:ul (:li "<i>clpython.app.repl:</i>&nbsp; read-eval-print loop")))
                   (:li "<i>clpython.package:</i> &nbsp;utilities"))))
    (h2-anchor #1#)
    (:p "Programs that deal with abstract syntax trees (AST) of Python programs have to deal with symbols in different packages: the nodes of the AST are in package <i>clpython.ast</i> or a subpackage, e.g. <i>clpython.ast.node:if-stmt</i>. Identifiers used in the Python code, on the other hand, are interned in package <i>clpython.user</i>, like <i>clpython.user::foo</i>.")
    (:p "It is impractical to have one package in which all these symbols are accessible, as in Python code there can be an identifier called <i>newline</i> which conflicts with <i>clpython.ast.token:newline</i>; and moreover some symbols will conflict with ones in the Common Lisp package (e.g. <i>clpython.ast.operator:+</i>, <i>clpython.ast.token:number</i> and <i>clpython.user:pi</i>).")
    (:p "To nevertheless be able to refer to those symbols without having to state the package explicitly each time, a custom readtable has been created in which <i>[foo]</i> (a symbol in square brackets) refers to that symbol as found in the <i>clpython.ast</i> package; and <i>{bar}</i> (in curly brackets) refers to symbol <i>bar</i> in the <i>clpython.user</i> package. The above examples thus become <i>[if-stmt]</i> and <i>{pi}</i>.")
    (:p "There are three such readtables:")
    (:ul (:li "<i>clpython.package:*ast-readtable*,</i> in which the <i>{foo}</i> styntax can be used;")
         (:li "<i>clpython.package:*user-readtable*,</i> in which <i>[if-stmt]</i> can be used;")
         (:li "<i>clpython.package:*ast-user-readtable*,</i> in which both notations are supported."))
    (:p "These readtables have been named <i>:py-ast-readtable</i>, <i>:py-user-readtable</i> and <i>:py-ast-user-readtable</i>, respectively. These named readtables are refered to in the mode line at the top of CLPython source files. In <i>compiler.lisp</i> the top of the file looke like:")
    (:pre ";; -*- package: clpython; readtable: py-ast-user-readtable -*-
\(in-package :clpython)
\(in-syntax *ast-user-readtable*)")
    (:p "(The <i>in-syntax</i> macro as "
        ((:a href "http://groups.google.nl/group/comp.lang.lisp/msg/d97a08bd49db2b82?dmode=source")
         "proposed")
        "  by Kent Pitman is available in package <i>clpython</i>).")

    (h2-anchor #2#)
    (:p "The parser translates Python source into an abstract syntax tree. The parser consists of two parts: a lexer and a grammar specification.")
    (:p "The lexer converts a stream of characters (a string or a file) into a stream of <i>tokens</i>. For example, the characters <i>i</i> and <i>f</i> can be combined to form the reserved word <i>if</i>. The characters <i>1</i>, <i>3</i> and <i>5</i> together form the number <i>135</i>. The lexer knows how to properly combine characters into a literal number, literal string, punctuation, or identifier token.")
    (:p "The grammar specification defines the syntax of Python in terms of what token may occur in what place. For example, the rule for <i>if</i> statements is:")
    (:pre "[if] test [:] suite elif--test--suite* else--suite?")
    (:p "which means that it starts with the token \"if\", followed by a <i>test</i> expression, then a colon as punctuation, then any number of \"elif ...\" clauses, and perhaps an \"else: ...\" clause at the end.")
    (:p "A character input stream is first tokenized by the lexer; then the grammar rules are applied. The result is an abstract syntax tree. For example, the source code:")
    (:pre "if x > 0:
  s = 'positive'
\elif x == 0:
  s = 'zero'
\else:
  s = 'negative'")
    (:p "is represented by the AST:")
    (:pre "([if-stmt]
   ((([>] (clpython.ast.node:identifier-expr {x}) 0)
      ([suite-stmt]
         (([assign-stmt] \"positive\" (([identifier-expr] {s}))))))
     (([==] ([identifier-expr] {x}) 0)
         ([suite-stmt]
            (([assign-stmt] \"zero\" (([identifier-expr] {s})))))))
    ([suite-stmt]
       (([assign-stmt] \"negative\" (([identifier-expr] {s}))))))")
    (:p "The AST is thus represented by a nested list containing symbols, numbers and strings. The <i>car</i> of every sublist determines what the other items in the sublist represent. The <i>if-stmt</i> AST list has two items after it: first a list of <i>(condition body)</i> pairs, then (optionally) the body of the <i>else</i> body.")
    (:p "The compiler is implemented by defining a macro for every possible <i>car</i> value, e.g. there are macros for <i>if-stmt</i>, <i>identifier-expr</i> and <i>assign-stmt</i>.")

    (:p)
    (h2-anchor #4#)
    (:p "todo")
    (:p)
    (h2-anchor #5#)
    (:p "todo")
    (:p)
    (h2-anchor #6#)
    (:p "todo")
    (:p)
    ))

(defmethod fill-page ((page (eql :dictionary)))
  (with-page-template ((:page :dictionary)
                       (:title "CLPython Dictionary"))
    
    (make-anchor-links #101="Remarks" #1="Parser" #2="Code walker" #3="Compiler")

    (h2-anchor #101#)
    (:p "This document lists the most important functions and variables of the CLPython interface. When time allows it, more items will be added here.")
    (:p)
    
    (h2-anchor #1#)
    (:ul (:li (:p (:b "parse-python-file")
                  (:i " &nbsp;file ")
                  "&key "
                  (:i "tab-width-spaces incl-module include-line-numbers &nbsp;=>&nbsp; ast")
                  (:br)
                  (:b "parse-python-string")
                  (:i " &nbsp;string ")
                  "&key "
                  (:i "tab-width-spaces incl-module include-line-numbers &nbsp;=>&nbsp; ast"))
              ((:p style "position: relative; left: 15px")
               "<i>file</i> &mdash; a pathname or a stream." (:br)
               "<i>string</i> &mdash; a string." (:br)
               "<i>tab-width-spaces</i> &mdash; a non-negative integer. The default is 8." (:br)
               "<i>include-line-numbers</i> &mdash; a boolean. The default is nil." (:br)
               "<i>ast</i> &mdash; an abstract syntax tree.")
              (:p "<i>Parse-python-file</i> and <i>parse-python-string</i> return the result of parsing the given file or string.")
              (:p "One <i>Tab</i> character will be treated as <i>tab-width-spaces</i> times a <i>Space</i>. This is only relevant if in the source the indentation consists of both spaces and tabs.")
              (:p "If <i>include-line-numbers</i> is true, then the generated AST will contain tokens representing line numbers in the source. This can be useful for tools doing source code coverage analyses. Note that not every source line number will be included in the AST.")))

    (h2-anchor #2#)
    (:ul (:li (:p "[Macro] " (:b "with-py-ast")
                  (:i " &nbsp;(subform ast ")
                  "&rest "
                  (:i "&key build-result lists-only into-nested-namespaces) ")
                  "&body "
                  (:i "body"))
              ((:p style "position: relative; left: 15px")
               "<i>subform</i> &mdash; a symbol <i>sym</i>, or the list <i>(sym &key clpython::value clpython::target)</i> with <i>sym</i> a symbol." (:br)
               "<i>ast</i> &mdash; an abstract syntax tree." (:br)
               "<i>build-result</i> &mdash; a boolean. The default is false." (:br)
               "<i>lists-only</i> &mdash; a boolean. The default is true." (:br)
               "<i>into-nested-namespaces</i> &mdash; a boolean. The default is false."
               )
              (:p "The <i>body</i> will be executed each time the code walker recurses into the <i>ast</i>, which is essentially a tree structure. Each time <i>body</i> is executed, variable <i>sym</i> is bound to the current sub-AST.")
              (:p "If the list form of <i>subform</i> is used, then <i>value</i> and <i>target</i> are bound to the context in which the sub-AST <i>sym</i> is used:")
              (:ul (:li "<i>value</i> will be <i>true</i> if the sub-AST is used for its value (e.g. \"y\" in \"x = y\")")
                   (:li "<i>target</i> will be <i>true</i> if the sub-AST is used to store a value (e.g. \"x\" in \"x = y\")"))
              (:p "For statements, both <i>value</i> and <i>target</i> are usually false. For some expressions both are true (e.g. \"x\" in \"x += 2\"). There are different <i>true</i> values for both <i>value</i> (e.g. <i>+normal-value+</i>, <i>+augassign-value+</i>) and <i>target</i> (e.g. <i>+normal-target+</i>, <i>+delete-target+</i>).")
              (:p "The return values of <i>body</i> are used as follows:")
              (:ul (:li "The first value is the form that the code walker will recurse into next. Typically it is the subform to which <i>sym</i> is bound.")
                   (:li "The second value indicates whether the code walker should consider this recursion branch finished: if <i>true</i>, then the code walker will not recurse deeper into the form returned as first value; otherwise it will recurse in the first value returned (if possible);"))
              (:p "If <i>lists-only</i> is true, then the body will only be executed for subforms that are lists; this will skip numbers and strings.")
              (:p "If <i>into-nested-namespaces</i> is true, then recursion into nested namespaces will take place; otherwise recursion stops just before entering the nested namespace. (A nested namespace is the body of an inner function or inner class.)")
              (:p "If <i>build-result</i> is true, then on each invocation the (first) return value of <i>body</i> is collected. After walking, walk-py-ast returns the AST that is a copy of the original AST, except that every time when <i>body</i> returned a different subform than the value it got for <i>sym</i>, the form returned by <i>body</i> replaces the form of <i>sym</i> in the returned AST. (Think of it as a \"tree-replace\" function with special knowledge of the AST structure.)")))

    (h2-anchor #3#)
    (:p "todo")
    (:p)))
