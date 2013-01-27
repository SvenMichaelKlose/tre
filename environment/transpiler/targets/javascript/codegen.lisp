;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

(defun js-call (x)
  `(,x. ,@(parenthized-comma-separated-list .x)))

(defun js-stack (x)
  ($ '_I_S x))

(defvar *js-compiled-symbols* (make-hash-table :test #'eq))

(defun js-codegen-symbol-constructor-expr (tr x)
  (let s (compiled-function-name-string tr 'symbol)
    `(,s "(\"" ,(transpiler-obfuscated-symbol-name tr x) "\","
	           ,@(!? (symbol-package x)
	                 `((,s "(\"" ,(transpiler-obfuscated-symbol-name tr !) "\",null)"))
	                 '(("null")))
	     ")")))

(defun js-codegen-symbol-constructor (tr x)
  (| (href *js-compiled-symbols* x)
     (= (href *js-compiled-symbols* x)
        (let g (compiled-symbol-identifier x)
          (push `("var " ,(transpiler-obfuscated-symbol-string tr g)
                         "=" ,@(js-codegen-symbol-constructor-expr tr x)
                         ,*js-separator*)
                (transpiler-raw-decls tr))
          g))))

(define-codegen-macro-definer define-js-macro *js-transpiler*)


;;;; CONTROL FLOW

(define-js-macro %%tag (tag)
  `(%transpiler-native "case " ,tag ":" ,*js-newline*))

(define-js-macro %%go (tag)
  `(,*js-indent* "_I_=" ,tag ";continue" ,*js-separator*))

(define-js-macro %%go-nil (val tag)
  `(,*js-indent* "if(!" ,val "&&" ,val "!==0&&" ,val "!==''){_I_=" ,tag ";continue;}" ,*js-newline*))

(define-js-macro %%call-nil (val consequence alternative)
  `(,*js-indent* "if(!" ,val "&&" ,val "!==0&&" ,val "!=='')"
                     ,consequence "();"
                 "else "
                     ,alternative "();" ,*js-newline*))

(define-js-macro %set-atom-fun (plc val)
  `(%transpiler-native ,*js-indent* ,plc "=" ,val ,*js-separator*))


;;;; FUNCTIONS

(defun js-argument-list (debug-section args)
  (parenthized-comma-separated-list (argument-expand-names debug-section args)))

(define-js-macro function (&rest x)
  (& ..x (error "an optional function name followed by the head/body expected"))
  (= x (? .x .x. x.))
  (? (| (atom x) (%stack? x))
	 x
     `("function " ,@(js-argument-list 'unnamed-js-function (lambda-args x)) ,(code-char 10)
	   "{" ,(code-char 10)
		   ,@(lambda-body x)
	   "}")))

(define-js-macro %function-prologue (fi-sym)
  `(%transpiler-native ""
	   ,@(& (transpiler-stack-locals? *transpiler*)
	        `(,*js-indent* "var _locals=[]" ,*js-separator*))
	   ,@(& (< 0 (funinfo-num-tags (get-funinfo-by-sym fi-sym)))
	        `(,*js-indent* "var _I_=0" ,*js-separator*
		      ,*js-indent* "while(1){" ,*js-separator*
		      ,*js-indent* "switch(_I_){case 0:" ,*js-separator*))))

(define-js-macro %function-return (fi-sym)
  (let fi (get-funinfo-by-sym fi-sym)
    `(,*js-indent* "return " ,(place-assign (place-expand-0 fi '~%ret)) ,*js-separator*)))

(define-js-macro %function-return-cps (fi-sym)
  (let fi (get-funinfo-by-sym fi-sym)
    (? (& (funinfo-num-tags fi)
          (< 0 (funinfo-num-tags fi)))
       `(,*js-indent*  "return" ,*js-separator*)
       "")))

(define-js-macro %function-epilogue (fi-sym)
  (let fi (get-funinfo-by-sym fi-sym)
    (| `(,@(? (& (transpiler-continuation-passing-style? *transpiler*)
                 (funinfo-needs-cps? fi))
              `((%function-return-cps ,fi-sym))
              `((%function-return ,fi-sym)))
	     ,@(& (< 0 (funinfo-num-tags fi)) `("}}")))
        "")))


;;;; ASSIGNMENT

(defun js-%setq-0 (dest val)
  `(,*js-indent*
	(%transpiler-native
        ,@(? dest
		     `(,dest "=")
		     '("")))
	,(? (| (atom val) (codegen-expr? val))
		val
		(js-call val))
    ,*js-separator*))

(define-js-macro %setq (dest val)
  (? (& (not dest) (atom val))
	 '(%transpiler-native "")
	 (js-%setq-0 dest val)))


;;;; VARIABLE DECLARATIONS

(define-js-macro %var (name)
  `(%transpiler-native ,*js-indent* "var " ,name ,*js-separator*))


;;;; TYPE PREDICATES

(defmacro define-js-infix (name)
  `(define-transpiler-infix *js-transpiler* ,name))

(define-js-infix instanceof)


;;;; SYMBOL REPLACEMENTS

(transpiler-translate-symbol *js-transpiler* nil "null")
(transpiler-translate-symbol *js-transpiler* t "true")


;;;; ARGUMENT EXPANSION CONSING

(define-js-macro %%%cons (a d)
  `(userfun_cons ,a ,d))


;;;; NUMBERS, ARITHMETIC AND COMPARISON

(defmacro define-js-binary (op repl-op)
  `(define-transpiler-binary *js-transpiler* ,op ,repl-op))

(mapcar-macro x
	'((%%%+ "+")
	  (%%%string+ "+")
	  (%%%- "-")
	  (%%%/ "/")
	  (%%%* "*")
	  (%%%mod "%")
	  (%%%== "==")
	  (%%%!= "!=")
	  (%%%< "<")
	  (%%%> ">")
	  (%%%<= "<=")
	  (%%%>= ">=")
	  (%%%eq "===")
	  (%%%neq "!=="))
  `(define-js-binary ,@x))


;;;; ARRAYS

(define-js-macro make-array (&rest elements)
  `(%transpiler-native ,@(parenthized-comma-separated-list elements :type 'square)))

(define-js-macro %%%aref (arr &rest idx)
  `(%transpiler-native ,arr
     ,@(filter ^("[" ,_ "]") idx)))

(define-js-macro %%%=-aref (val &rest x)
  `(%transpiler-native (%%%aref ,@x) "=" ,val))

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
  `(%transpiler-native "delete " ,h "[" ,key "]"))


;;;; OBJECTS

(define-js-macro %new (&rest x)
  `(%transpiler-native "new " ,(compiled-function-name *transpiler* x.)
                              ,@(parenthized-comma-separated-list .x)))

(define-js-macro delete-object (x)
  `(%transpiler-native "delete " ,x))


;;;; META-CODES

(define-js-macro %quote (x)
  (? (not (string== "" (symbol-name x))) ;XXX
	 (js-codegen-symbol-constructor *transpiler* x)
	 x))

(define-js-macro %slot-value (x y)
  `(%transpiler-native
       ,(? (cons? x)
           x
           (transpiler-obfuscated-symbol-string *transpiler* x))
       "."
       ,(? (cons? y)
           y
           (transpiler-obfuscated-symbol-string *transpiler* y))))

(define-js-macro %try ()
  '(%transpiler-native "try {"))

(define-js-macro %closing-bracket ()
  '(%transpiler-native "}"))

(define-js-macro %catch (x)
  `(%transpiler-native "catch (" ,x ") {"))


;;;; BACK-END META-CODES

(define-js-macro %stack (x)
  (? (transpiler-stack-locals? *transpiler*)
  	 `(%transpiler-native "_locals[" ,x "]")
     (js-stack x)))

(define-js-macro %vec (v i)
  `(%transpiler-native ,v "[" ,i "]"))

(define-js-macro %set-vec (v i x)
  `(%transpiler-native (aref ,v ,i) "=" ,x ,*js-separator*))

(define-js-macro %js-typeof (x)
  `(%transpiler-native "typeof " ,x))

(define-js-macro %defined? (x)
  `(%transpiler-native "\"undefined\" != typeof " ,x))

(define-js-macro %%closure (name fi-sym)
  (let fi (get-funinfo-by-sym fi-sym)
    (? (funinfo-ghost fi)
	   (!? (funinfo-lexical (funinfo-parent fi))
  	  	   `(%closure ,name ,!)
		   (error "no lexical for ghost"))
	   name)))

(define-js-macro %invoke-debugger ()
  '(%transpiler-native "null; debugger"))

(define-js-macro %%%eval (x)
  `((%transpiler-native "window.eval ") ,x))
