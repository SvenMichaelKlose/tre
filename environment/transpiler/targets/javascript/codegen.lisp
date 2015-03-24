; tré – Copyright (c) 2008–2015 Sven Michael Klose <pixel@copei.de>

(defun js-call (x)
  `(,x. ,@(c-list .x)))

(defvar *js-compiled-symbols* (make-hash-table :test #'eq))

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

(define-js-macro %%call-not-nil (val consequence alternative)
  `(,*js-indent* "if(!",(js-nil? val) ")"
                     ,consequence "();"
                 "else "
                     ,alternative "();" ,*newline*))

(define-js-macro %set-atom-fun (plc val)
  `(%%native ,*js-indent* ,plc "=" ,val ,*js-separator*))

(define-js-macro return-from (block-name x)
  (error "Cannot return from unknown BLOCK ~A." block-name))


;;;; FUNCTIONS

(defun js-argument-list (debug-section args)
  (c-list (argument-expand-names debug-section args)))

(define-js-macro function (&rest x)
  (alet (. 'function x)
    (? .x
       (with (name            (lambda-name !)
              translated-name (? (defined-function name)
                                 (compiled-function-name-string name)
                                 name))
         `(,*newline*
           ,(funinfo-comment (get-funinfo name))
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
  (alet (get-funinfo name)
    (? (& (funinfo-var? ! '~%ret)
          (not (funinfo-cps? !)))
       `(,*js-indent* "return " ~%ret ,*js-separator*)
       "")))

(define-js-macro %function-epilogue (name)
  (| `((%function-return ,name)
       ,@(& (< 0 (funinfo-num-tags (get-funinfo name)))
            `("}}")))
      ""))


;;;; ASSIGNMENT

(defun js-%=-0 (dest val)
  `(,*js-indent*
	(%%native
        ,@(? dest
		     `(,dest "=")
		     '("")))
	,(? (atom|codegen-expr? val)
		val
		(js-call val))
    ,*js-separator*))

(define-js-macro %= (dest val)
  (? (& (not dest) (atom val))
	 '(%%native "")
	 (js-%=-0 dest val)))


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
  `(%%native ,@(c-list elements :type 'square)))

(define-js-macro %%%aref (arr &rest idx)
  `(%%native ,arr ,@(@ [`("[" ,_ "]")] idx)))

(define-js-macro %%%=-aref (val &rest x)
  `(%%native (%%%aref ,@x) "=" ,val))

(define-js-macro aref (arr &rest idx)
  `(%%%aref ,arr ,@idx))

(define-js-macro =-aref (val &rest x)
  `(%%%=-aref ,val ,@x))


;;;; HASH TABLES

(defun js-literal-hash-entry (name value)
  `(,(? (symbol? name)
        (make-symbol (symbol-name name))
        name)
     ":" ,value))

(define-js-macro %%%make-hash-table (&rest args)
  (c-list (@ [js-literal-hash-entry _. ._] (group args 2)) :type 'curly))

(define-js-macro href (arr &rest idx)
  `(aref ,arr ,@idx))

(define-js-macro =-href (val &rest x)
  `(=-aref ,val ,@x))

(define-js-macro hremove (h key)
  `(%%native "delete " ,h "[" ,key "]"))


;;;; OBJECTS

(define-js-macro %new (&rest x)
  `(%%native "new " ,(? (defined-function x.)
                        (compiled-function-name-string x.)
                        (obfuscated-identifier x.))
                    ,@(c-list .x)))

(define-js-macro delete-object (x)
  `(%%native "delete " ,x))


;;;; METACODES

(define-js-macro quote (x)
  (with (f  [let s (compiled-function-name-string 'symbol)
              `(,s "(\"" ,(obfuscated-symbol-name _) "\","
	            ,@(? (keyword? _)
	                 `((,s "(\"" ,(obfuscated-symbol-name (symbol-package _)) "\",null)"))
	                 '(("null")))
	            ")")])
    (alet *js-compiled-symbols*
      (| (href ! x)
         (= (href ! x) (with-gensym g
                         (push `("var " ,(obfuscated-identifier g)
                                 "="
                                 ,@(f x)
                                 ,*js-separator*)
                               (raw-decls))
                         g))))))

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

(define-js-macro %invoke-debugger ()
  '(%%native "null; debugger"))

(define-js-macro %%%eval (x)
  `((%%native "window.eval ") ,x))

(define-js-macro %global (x)
  x)

;;;; CPS FIXUPS

(define-js-macro cps-toplevel-return-value (x)
  `(%%native "function(r){" ,x "=r;}"))
