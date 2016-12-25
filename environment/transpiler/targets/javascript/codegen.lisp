(defvar *js-compiled-symbols* (make-hash-table :test #'eq))

(define-codegen-macro-definer define-js-macro *js-transpiler*)


;;;; CONTROL FLOW

(define-js-macro %%tag (tag)
  `(%%native "case " ,tag ":" ,*newline*))

(define-js-macro %%go (tag)
  `(,*js-indent* "_I_ = " ,tag "; continue" ,*js-separator*))

(defun js-nil? (x)
  `("(" ,x " == null || " ,x " === false)"))

(define-js-macro %%go-nil (tag val)
  `(,*js-indent* "if " ,(js-nil? val) " { _I_= " ,tag "; continue; }" ,*newline*))

(define-js-macro %%go-not-nil (tag val)
  `(,*js-indent* "if (!" ,(js-nil? val) ") { _I_=" ,tag "; continue; }" ,*newline*))

(define-js-macro %%call-nil (val consequence alternative)
  `(,*js-indent* "if " ,(js-nil? val) " "
                     ,consequence " ();"
                 "else "
                     ,alternative " ();" ,*newline*))

(define-js-macro %%call-not-nil (val consequence alternative)
  `(,*js-indent* "if (!",(js-nil? val) ") "
                     ,consequence " (); "
                 "else "
                     ,alternative " ();" ,*newline*))

(define-js-macro %set-local-fun (plc val)
  `(%%native ,*js-indent* ,plc " = " ,val ,*js-separator*))


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
         (developer-note "Generating function ~A…~%" name)
         `(,*newline*
           ,(funinfo-comment (= *funinfo* (get-funinfo name)))
           ,translated-name " = function " ,@(js-argument-list 'codegen-function-macro (lambda-args !)) ,*newline*
	       "{" ,*newline*
		       ,@(lambda-body !)
	       "}" ,*newline*))
       (? (symbol? x.)
          x.
          !))))

(define-js-macro %function-prologue (name)
  `(%%native ""
	   ,@(& (< 0 (funinfo-num-tags (get-funinfo name)))
	        `(,*js-indent* "var _I_ = 0" ,*js-separator*
		      ,*js-indent* "while (1) {" ,*js-separator*
		      ,*js-indent* "switch (_I_) { case 0:" ,*js-separator*))))

(define-js-macro %function-return (name)
  (alet (get-funinfo name)
    (& (funinfo-var? ! '~%ret)
       `(,*js-indent* "return " ~%ret ,*js-separator*))))

(define-js-macro %function-epilogue (name)
  (| `((%function-return ,name)
       ,@(& (< 0 (funinfo-num-tags (get-funinfo name)))
            `("}}")))
      ""))


;;;; ASSIGNMENT

(define-js-macro %= (dest val)
  (? (& (not dest) (atom val))
     '(%%native "")
     `(,*js-indent*
       ,@(? dest
            `((%%native ,dest " = ")))
       ,(? (| (atom val)
              (codegen-expr? val))
           val
           `(,val. " " ,@(c-list .val)))
      ,*js-separator*)))


;;;; VARIABLE DECLARATIONS

(define-js-macro %var (&rest names)
  `(%%native ,*js-indent* "var " ,(c-list names :brackets :none) ,*js-separator*))


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
	  (%%%neq     "!==")

	  (%%%<<      "<<")
	  (%%%>>      ">>")
	  (%%%bit-or  "|")
	  (%%%bit-and "&"))
  `(define-js-binary ,@x))


;;;; ARRAYS

(define-js-macro make-array (&rest elements)
  `(%%native ,@(c-list elements :brackets :square)))

(define-js-macro %%%aref (arr &rest idx)
  `(%%native ,arr ,@(@ [`("[" ,_ "]")] idx)))

(define-js-macro %%%=-aref (val &rest x)
  `(%%native (%%%aref ,@x) " = " ,val))

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
  (c-list (@ [js-literal-hash-entry _. ._] (group args 2)) :brackets :curly))

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

(defun make-compiled-symbol-identifier (x)
  ($ (? (keyword? x)
        'keyword_
        'symbol_)
     x))

(define-js-macro quote (x)
  (with (f  [let s (compiled-function-name-string 'symbol)
              `(,s " (\"" ,(obfuscated-symbol-name _) "\", "
	            ,@(? (keyword? _)
	                 `("KEYWORDPACKAGE")
	                 '(("null")))
	            ")")])
      (cache (aprog1 (make-compiled-symbol-identifier x)
               (push `("var " ,(obfuscated-identifier !)
                       " = "
                       ,@(f x)
                       ,*js-separator*)
                       (raw-decls)))
             (href *js-compiled-symbols* x))))

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
  `((%%native "window.eval (" ,x ")")))

(define-js-macro %global (x)
  x)


;;;; MISCELLANEOUS

(define-js-macro %%comment (&rest x)
  `(%%native "/* " ,@x " */" ,*newline*))
