;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

(defun js-call (x)
  `(,x. ,@(parenthized-comma-separated-list .x)))

(defun js-stack (x)
  ($ '_I_S x))

(defvar *js-compiled-symbols* (make-hash-table :test #'eq))

(defun js-codegen-symbol-constructor-expr (tr x)
  (let s (transpiler-obfuscated-symbol-string tr (compiled-function-name 'symbol))
    `(,s "(\"" ,(transpiler-obfuscated-symbol-name tr x) "\", "
	           ,@(if (symbol-package x)
	                 `((,s "(\"" ,(symbol-name (symbol-package x)) "\", null)"))
	                 '(("null")))
	     ")")))

(defun js-codegen-symbol-constructor (tr x)
  (or (href *js-compiled-symbols* x)
      (setf (href *js-compiled-symbols* x)
            (with-gensym g ;XXX hogs the browser: ($ 'compiled_symbol_ x)
              (push `("var " ,(transpiler-obfuscated-symbol-string tr g)
                             "=" ,@(js-codegen-symbol-constructor-expr tr x)
		                     ,*js-separator*)
                    (transpiler-raw-decls tr))
              g))))

(define-codegen-macro-definer define-js-macro *js-transpiler*)

;;;; CONTROL FLOW

(define-js-macro %%tag (tag)
  `("case " ,tag ":" ,*js-newline*))

(define-js-macro %%vm-go (tag)
  `(,*js-indent* "_I_=" ,tag "; continue" ,*js-separator*))

(define-js-macro %%vm-go-nil (val tag)
  `(,*js-indent* "if (typeof ",val"=='undefined'||!" ,val "&&" ,val "!==0&&" ,val "!=='') {_I_=" ,tag "; continue;}" ,*js-newline*))

(define-js-macro %%vm-call-nil (val consequence alternative)
  `(,*js-indent* "if (!" ,val "&&" ,val "!==0&&" ,val "!=='') "
                    ,consequence"();"
                    "else " ,alternative "();" ,*js-newline*))

(define-js-macro %set-atom-fun (plc val)
  `(,*js-indent* ,plc "=" ,val ,*js-separator*))

;;;; FUNCTIONS

(define-js-macro function (&rest x)
  (when ..x
	(error "an optional function name followed by the head/body expected"))
  (setf x (if .x .x. x.))
  (if (or (atom x)
		  (%stack? x))
	  x
      `("function " ,@(parenthized-comma-separated-list
      					  (argument-expand-names 'unnamed-js-function (lambda-args x)))
		  			,(code-char 10)
	    "{" ,(code-char 10)
			,@(lambda-body x)
	    "}" ,(code-char 10))))

(define-js-macro %function-prologue (fi-sym)
  `(,@(when (transpiler-stack-locals? *js-transpiler*)
	    `(,*js-indent* "var _locals = []" ,*js-separator*))
	,@(when (< 0 (funinfo-num-tags (get-lambda-funinfo-by-sym fi-sym)))
	    `(,*js-indent* "var _I_ = 0" ,*js-separator*
		  ,*js-indent* "while (1) {" ,*js-separator*
		  ,*js-indent* "switch (_I_) {case 0:" ,*js-separator*))))

(define-js-macro %function-return (fi-sym)
  (let fi (get-lambda-funinfo-by-sym fi-sym)
    `(,*js-indent* "return " ,(place-assign (place-expand-0 fi '~%ret)) ,*js-separator*)))

(define-js-macro %function-return-cps (fi-sym)
  (let fi (get-lambda-funinfo-by-sym fi-sym)
    (if (and (funinfo-num-tags fi)
             (< 0 (funinfo-num-tags fi)))
        `(,*js-indent*  "return" ,*js-separator*)
        "")))

(define-js-macro %function-epilogue (fi-sym)
  (let fi (get-lambda-funinfo-by-sym fi-sym)
    (or `(,@(if (and (transpiler-continuation-passing-style? *js-transpiler*)
                     (funinfo-needs-cps? fi))
              `((%function-return-cps ,fi-sym))
              `((%function-return ,fi-sym)))
	      ,@(when (< 0 (funinfo-num-tags fi))
	          `(,*js-indent* "}" ,*js-newline*))
	      ,@(when (< 0 (funinfo-num-tags fi))
	          `(,*js-indent* "}" ,*js-newline*)))
        "")))

;;;; ASSIGNMENT

(defun js-%setq-0 (dest val)
  `(,*js-indent*
    ,@(if dest
	      `(,dest "=")
	      '("")))
	,(if (or (atom val)
			 (codegen-expr? val))
		 val
		 (js-call val))
    ,*js-separator*))

(define-js-macro %setq (dest val)
  (if (and (not dest)
		   (atom val))
	  ""
	  (js-%setq-0 dest val)))

;;;; VARIABLE DECLARATIONS

(define-js-macro %var (name)
  `(,*js-indent* "var " ,name ,*js-separator*))

;;;; TYPE PREDICATES

(defmacro define-js-infix (name)
  `(define-transpiler-infix *js-transpiler* ,name))

(define-js-infix instanceof)

;;;; SYMBOL REPLACEMENTS

(transpiler-translate-symbol *js-transpiler* nil "null")
(transpiler-translate-symbol *js-transpiler* t "true")

;;;; NUMBERS, ARITHMETIC AND COMPARISON

(defmacro define-js-binary (op repl-op)
  `(define-transpiler-binary *js-transpiler* ,op ,repl-op))

(mapcar-macro x
	'((%%%+ "+")
	  (%%%string+ "+")
	  (%%%- "-")
	  (%%%= "==")
	  (%%%< "<")
	  (%%%> ">")
	  (%%%<= "<=")
	  (%%%>= ">=")
	  (%%%eq "==="))
  `(define-js-binary ,@x))

;;;; ARRAYS

(define-js-macro make-array (&rest elements)
  `("[" ,@(transpiler-binary-expand "," elements) "]"))

(define-js-macro aref (arr &rest idx)
  `(,arr ,@(mapcar (fn `("[" ,_ "]")) idx)))

(define-js-macro %%usetf-aref (val &rest x)
  `(aref ,@x) "=" ,val)

;;;; HASH TABLES

(define-js-macro make-hash-table (&rest args)
  (let pairs (group args 2)
    `("{"
      ,@(when args
	      (mapcan (fn (list (first _) ":" (second _) ","))
			      (butlast pairs)))
      ,@(when args
		  (with (x (car (last pairs)))
		    (list x. ":" (second x))))
     "}")))

(define-js-macro href (arr &rest idx)
  `(,arr ,@(mapcar (fn `("[" ,_ "]")) idx)))

(define-js-macro %%usetf-href (val &rest x)
  `(aref ,@x) "=" ,val)

(define-js-macro hremove (h key)
  `("delete " ,h "[" ,key "]"))

;;;; OBJECTS

(define-js-macro %new (&rest x)
  `("new " ,(compiled-function-name x.) "(" ,@(transpiler-binary-expand "," .x) ")"))

(define-js-macro delete-object (x)
  `("delete " ,x))

;;;; META-CODES

(define-js-macro %quote (x)
  (if (not (string= "" (symbol-name x)))
	  (js-codegen-symbol-constructor *js-transpiler* x)
	  x))

(define-js-macro %slot-value (x y)
  `(,(if (consp x)
         x
         (transpiler-obfuscated-symbol-string *js-transpiler* x))
    "."
    ,(if (consp y)
         y
         (transpiler-obfuscated-symbol-string *js-transpiler* y))))

;;;; BACK-END META-CODES

(define-js-macro %stack (x)
  (if (transpiler-stack-locals? *js-transpiler*)
  	  `("_locals[" ,x "]")
      (js-stack x)))

;; Experimental for lambda-export.
(define-js-macro %vec (v i)
  `(,v "[" ,i "]"))

;; Experimental for lambda-export.
(define-js-macro %set-vec (v i x)
  `(aref ,v ,i) "=" ,x ,*js-separator*)

(define-js-macro %js-typeof (x)
  `("typeof " ,x))

(define-js-macro %%funref (name fi-sym)
  (let fi (get-lambda-funinfo-by-sym fi-sym)
    (if (funinfo-ghost fi)
	    (aif (funinfo-lexical (funinfo-parent fi))
  	  		 `(%funref ,name ,!)
			 (error "no lexical for ghost"))
	    name)))
