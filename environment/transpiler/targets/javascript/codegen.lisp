(def-codegen-macro def-js-codegen *js-transpiler*)


;;;; CONTROL FLOW

(def-js-codegen %%tag (tag)
  `(%%native "case " ,tag ":" ,*terpri*))

(def-js-codegen %%go (tag)
  `(,*js-indent* "_I_ = " ,tag "; continue" ,*js-separator*))

(fn js-nil? (x)
  `("(" ,x " == null || " ,x " === false)"))

(def-js-codegen %%go-nil (tag val)
  `(,*js-indent* "if " ,(js-nil? val) " { _I_= " ,tag "; continue; }" ,*terpri*))

(def-js-codegen %%go-not-nil (tag val)
  `(,*js-indent* "if (!" ,(js-nil? val) ") { _I_=" ,tag "; continue; }" ,*terpri*))

(def-js-codegen %%call-nil (val consequence alternative)
  `(,*js-indent* "if " ,(js-nil? val) " "
                     ,consequence " ();"
                 "else "
                     ,alternative " ();" ,*terpri*))

(def-js-codegen %%call-not-nil (val consequence alternative)
  `(,*js-indent* "if (!",(js-nil? val) ") "
                     ,consequence " (); "
                 "else "
                     ,alternative " ();" ,*terpri*))

(def-js-codegen %set-local-fun (plc val)
  `(%%native ,*js-indent* ,plc " = " ,val ,*js-separator*))


;;;; FUNCTIONS

(fn js-argument-list (debug-section args)
  (c-list (argument-expand-names debug-section args)))

(def-js-codegen function (&rest x)
  (!= (. 'function x)
    (? .x
       (with (name            (lambda-name !)
              translated-name (? (defined-function name)
                                 (compiled-function-name-string name)
                                 name))
         (developer-note "Generating function ~A…~%" name)
         `(,*terpri*
           ,(funinfo-comment (= *funinfo* (get-funinfo name)))
           ,translated-name " = function " ,@(js-argument-list 'codegen-function-macro (lambda-args !)) ,*terpri*
           "{" ,*terpri*
               ,@(lambda-body !)
           "}" ,*terpri*))
       (? (symbol? x.)
          x.
          !))))

(def-js-codegen %function-prologue (name)
  `(%%native ""
       ,@(& (< 0 (funinfo-num-tags (get-funinfo name)))
            `(,*js-indent* "var _I_ = 0" ,*js-separator*
              ,*js-indent* "while (1) {" ,*js-separator*
              ,*js-indent* "switch (_I_) { case 0:" ,*js-separator*))))

(def-js-codegen %function-return (name)
  (& (funinfo-var? (get-funinfo name) '~%ret)   ; TODO: Required?
     `(,*js-indent* "return " ~%ret ,*js-separator*)))

(def-js-codegen %function-epilogue (name)
  (| `((%function-return ,name)
       ,@(& (< 0 (funinfo-num-tags (get-funinfo name)))
            `("}}")))
      ""))


;;;; ASSIGNMENT

(def-js-codegen %= (dest val)
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

(def-js-codegen %var (&rest names)
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

{,@(@ [`(define-js-binary ,@_)]
      '((%%%+        "+")
        (%%%string+  "+")
        (%%%-        "-")
        (%%%/        "/")
        (%%%*        "*")
        (%%%mod      "%")

        (%%%==       "==")
        (%%%!=       "!=")
        (%%%<        "<")
        (%%%>        ">")
        (%%%<=       "<=")
        (%%%>=       ">=")
        (%%%eq       "===")

        (%%%<<       "<<")
        (%%%>>       ">>")
        (%%%bit-or   "|")
        (%%%bit-and  "&")))}


;;;; ARRAYS

(def-js-codegen make-array (&rest elements)
  `(%%native ,@(c-list elements :brackets :square)))

(def-js-codegen %aref (arr &rest idx)
  `(%%native ,arr ,@(@ [`("[" ,_ "]")] idx)))

(def-js-codegen =-%aref (val &rest x)
  `(%%native (%aref ,@x) " = " ,val))

(def-js-codegen aref (arr &rest idx)
  `(%aref ,arr ,@idx))

(def-js-codegen =-aref (val &rest x)
  `(=-%aref ,val ,@x))


;;;; HASH TABLES

(def-js-codegen href (arr &rest idx)
  `(%aref ,arr ,@idx))

(def-js-codegen =-href (val &rest x)
  `(=-%aref ,val ,@x))

(def-js-codegen property-remove (h key)
  `(%%native "delete " ,h "[" ,key "]"))

(def-js-codegen hremove (h key)
  `(%%native "delete " ,h "[" ,key "]"))


;;;; OBJECTS

(def-js-codegen %%%make-object (&rest args)
  (c-list (@ [`( ,_. ": " ,._.)] (group args 2)) :brackets :curly))

(def-js-codegen %new (&rest x)
  (? x
     `(%%native "new " ,(? (defined-function x.)
                           (compiled-function-name-string x.)
                           x.)
                       ,@(c-list .x))
     `(%%native "{}")))

(def-js-codegen delete-object (x)
  `(%%native "delete " ,x))


;;;; METACODES

(fn make-compiled-symbol-identifier (x)
  ($ (!? (symbol-package x)
         (+ (symbol-name !) "_p_")
         "")
     x))

(def-js-codegen quote (x)
  (js-compiled-symbol x))

(def-js-codegen %slot-value (x y)
  `(%%native ,x "." ,(? (%%string? y)
                        .y.
                        y)))

(def-js-codegen prop-value (x y)
  `(%aref ,x ,y))

(def-js-codegen %try ()
  '(%%native "try {"))

(def-js-codegen %closing-bracket ()
  '(%%native "}"))

(def-js-codegen %catch (x)
  `(%%native "catch (" ,x ") {"))


;;;; BACKEND METACODES

(def-js-codegen %vec (v i)
  `(%%native ,v "[" ,i "]"))

(def-js-codegen %set-vec (v i x)
  `(%%native (aref ,v ,i) "=" ,x ,*js-separator*))

(def-js-codegen %js-typeof (x)
  `(%%native "typeof " ,x))

(def-js-codegen %defined? (x)
  `(%%native "\"undefined\" != typeof " ,x))

(def-js-codegen %invoke-debugger ()
  '(%%native "null; debugger"))

(def-js-codegen %%%eval (x)
  `((%%native "window.eval (" ,x ")")))

(def-js-codegen %global (x)
  x)


;;;; MISCELLANEOUS

(def-js-codegen %%comment (&rest x)
  `(%%native "/* " ,@x " */" ,*terpri*))
