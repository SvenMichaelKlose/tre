;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun js-call (x)
  `(,x. ,@(parenthized-comma-separated-list .x)))

(defvar *js-compiled-symbols* (make-hash-table :test #'eq))

(defun js-codegen-symbol-constructor-expr (tr x)
  (let s (compiled-function-name-string 'symbol)
    `(,s "(\"" ,(obfuscated-symbol-name x) "\","
	           ,@(!? (symbol-package x)
	                 `((,s "(\"" ,(obfuscated-symbol-name !) "\",null)"))
	                 '(("null")))
	     ")")))

(defun js-codegen-symbol-constructor (tr x)
  (alet *js-compiled-symbols*
    (| (href ! x)
       (= (href ! x)
          (let g (compiled-symbol-identifier x)
            (push `("var " ,(obfuscated-symbol-string g)
                           "=" ,@(js-codegen-symbol-constructor-expr tr x)
                           ,*js-separator*)
                  (transpiler-raw-decls tr))
            g)))))

(define-codegen-macro-definer define-js-macro *js-transpiler*)


;;;; CONTROL FLOW

(define-js-macro %%tag (tag)
  `(%%native "case " ,tag ":" ,*newline*))

(define-js-macro %%go (tag)
  `(,*js-indent* "_I_=" ,tag ";continue" ,*js-separator*))

(defun js-nil? (x)
  `("(!" ,x "&&" ,x "!==0&&" ,x "!=='')"))

(define-js-macro %%go-nil (tag val)
  `(,*js-indent* "if" ,(js-nil? val) "{_I_=" ,tag ";continue;}" ,*newline*))

(define-js-macro %%go-not-nil (tag val)
  `(,*js-indent* "if(!" ,(js-nil? val) "){_I_=" ,tag ";continue;}" ,*newline*))

(define-js-macro %%call-nil (val consequence alternative)
  `(,*js-indent* "if",(js-nil? val)
                     ,consequence "();"
                 "else "
                     ,alternative "();" ,*newline*))

(define-js-macro %set-atom-fun (plc val)
  `(%%native ,*js-indent* ,plc "=" ,val ,*js-separator*))


;;;; FUNCTIONS

(defun js-argument-list (debug-section args)
  (parenthized-comma-separated-list (argument-expand-names debug-section args)))

(define-js-macro function (&rest x)
  (alet (cons 'function x)
    (? .x
       (with (name            (lambda-name !)
              translated-name (? (transpiler-defined-function *transpiler* name)
                                 (compiled-function-name-string name)
                                 name))
         `(,(funinfo-comment (get-funinfo name))
           ,translated-name "=" "function " ,@(js-argument-list 'codegen-function-macro (lambda-args !)) ,*newline*
	       "{" ,*newline*
		       ,@(lambda-body !)
	       "}" ,*newline*))
       !)))

(define-js-macro %function-prologue (name)
  `(%%native ""
	   ,@(& (< 0 (funinfo-num-tags (get-funinfo name)))
	        `(,*js-indent* "var _I_=0" ,*js-separator*
		      ,*js-indent* "while(1){" ,*js-separator*
		      ,*js-indent* "switch(_I_){case 0:" ,*js-separator*))))

(define-js-macro %function-return (name)
  (? (funinfo-var? (get-funinfo name) '~%ret)
     `(,*js-indent* "return " ~%ret ,*js-separator*)
     ""))

(define-js-macro %function-epilogue (name)
  (alet (get-funinfo name)
    (| `((%function-return ,name)
	     ,@(& (< 0 (funinfo-num-tags !)) `("}}")))
        "")))


;;;; ASSIGNMENT

(defun js-%setq-0 (dest val)
  `(,*js-indent*
	(%%native
        ,@(? dest
		     `(,dest "=")
		     '("")))
	,(? (atom|codegen-expr? val)
		val
		(js-call val))
    ,*js-separator*))

(define-js-macro %setq (dest val)
  (? (& (not dest) (atom val))
	 '(%%native "")
	 (js-%setq-0 dest val)))


;;;; VARIABLE DECLARATIONS

(define-js-macro %var (name)
  `(%%native ,*js-indent* "var " ,name ,*js-separator*))


;;;; TYPE PREDICATES

(defmacro define-js-infix (name)
  `(define-transpiler-infix *js-transpiler* ,name))

(define-js-infix instanceof)


;;;; SYMBOL REPLACEMENTS

(transpiler-translate-symbol *js-transpiler* nil "null")
(transpiler-translate-symbol *js-transpiler* t   "true")


;;;; NUMBERS, ARITHMETIC AND COMPARISON

(defmacro define-js-binary (op repl-op)
  `(define-transpiler-binary *js-transpiler* ,op ,repl-op))

(mapcar-macro x
	'((%%%+       "+")
	  (%%%string+ "+")
	  (%%%-       "-")
	  (%%%/       "/")
	  (%%%*       "*")
	  (%%%mod     "%")
	  (%%%==      "==")
	  (%%%!=      "!=")
	  (%%%<       "<")
	  (%%%>       ">")
	  (%%%<=      "<=")
	  (%%%>=      ">=")
	  (%%%eq      "===")
	  (%%%neq     "!=="))
  `(define-js-binary ,@x))


;;;; ARRAYS

(define-js-macro make-array (&rest elements)
  `(%%native ,@(parenthized-comma-separated-list elements :type 'square)))

(define-js-macro %%%aref (arr &rest idx)
  `(%%native ,arr ,@(filter ^("[" ,_ "]") idx)))

(define-js-macro %%%=-aref (val &rest x)
  `(%%native (%%%aref ,@x) "=" ,val))

(define-js-macro aref (arr &rest idx)
  `(%%%aref ,arr ,@idx))

(define-js-macro =-aref (val &rest x)
  `(%%%=-aref ,val ,@x))


;;;; HASH TABLES

(defun js-literal-hash-entry (name value)
  `(,(symbol-without-package name) ":" ,value))

(define-js-macro %%%make-hash-table (&rest args)
  (parenthized-comma-separated-list (filter [js-literal-hash-entry _. ._] (group args 2)) :type 'curly))

(define-js-macro href (arr &rest idx)
  `(aref ,arr ,@idx))

(define-js-macro =-href (val &rest x)
  `(=-aref ,val ,@x))

(define-js-macro hremove (h key)
  `(%%native "delete " ,h "[" ,key "]"))


;;;; OBJECTS

(define-js-macro %new (&rest x)
  `(%%native "new " ,x. ,@(parenthized-comma-separated-list .x)))

(define-js-macro delete-object (x)
  `(%%native "delete " ,x))


;;;; METACODES

(define-js-macro %quote (x)
  (js-codegen-symbol-constructor *transpiler* x))

(define-js-macro %slot-value (x y)
  `(%%native ,x "." ,y))

(define-js-macro %try ()
  '(%%native "try {"))

(define-js-macro %closing-bracket ()
  '(%%native "}"))

(define-js-macro %catch (x)
  `(%%native "catch (" ,x ") {"))


;;;; BACKEND METACODES

(define-js-macro %vec (v i)
  `(%%native ,v "[" ,i "]"))

(define-js-macro %set-vec (v i x)
  `(%%native (aref ,v ,i) "=" ,x ,*js-separator*))

(define-js-macro %js-typeof (x)
  `(%%native "typeof " ,x))

(define-js-macro %defined? (x)
  `(%%native "\"undefined\" != typeof " ,x))

(define-js-macro %%closure (name)
  (alet (get-funinfo name)
    (? (funinfo-ghost !)
	   (!? (codegen-closure-lexical !)
  	  	   `(%closure ,name ,!)
		   (error "No lexical for ghost."))
	   name)))

(define-js-macro %invoke-debugger ()
  '(%%native "null; debugger"))

(define-js-macro %%%eval (x)
  `((%%native "window.eval ") ,x))

(define-js-macro %backtrace-pop ()
  `(%%native *BACKTRACE* "=" *BACKTRACE* ".__"))
