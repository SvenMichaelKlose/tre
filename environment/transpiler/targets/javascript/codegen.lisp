(defmacro def-js-codegen (name &body body)
  `(define-codegen-macro *js-transpiler* ,name ,@body))


;;;; CONTROL FLOW

(def-js-codegen %tag (tag)
  `(%native "case " ,tag ":" ,*terpri*))

(def-js-codegen %go (tag)
  `(,*js-indent* "_I_ = " ,tag "; continue" ,*js-separator*))

(fn js-nil? (x)
  `("(" ,x " == null || " ,x " === false)"))

(def-js-codegen %go-nil (tag val)
  `(,*js-indent* "if " ,(js-nil? val)
                 " { _I_= " ,tag "; continue; }" ,*terpri*))

(def-js-codegen %go-not-nil (tag val)
  `(,*js-indent* "if (!" ,(js-nil? val) ")"
                 " { _I_=" ,tag "; continue; }" ,*terpri*))

(def-js-codegen %set-local-fun (plc val)
  `(%native ,*js-indent* ,plc " = " ,val ,*js-separator*))


;;;; FUNCTIONS

(def-js-codegen function (&rest x)
  (!= (. 'function x)
    (? .x
       (let name (lambda-name !)
         (developer-note "#'~A~%" name)
         `(,*terpri*
           ,(funinfo-comment (= *funinfo* (get-funinfo name)))
           ,(? (defined-function name)
               (compiled-function-name-string name)
               name)
           " = function "
               ,@(c-list (argument-expand-names name (lambda-args !)))
               ,*terpri*
           "{" ,*terpri*
               ,@(lambda-body !)
           "}" ,*terpri*))
       (? (symbol? x.)
          x.
          !))))

(def-js-codegen %function-prologue (name)
  `(%native ""
     ,@(& (< 0 (funinfo-num-tags (get-funinfo name)))
          `(,*js-indent* "var _I_ = 0" ,*js-separator*
            ,*js-indent* "while (1) {" ,*js-separator*
            ,*js-indent* "switch (_I_) { case 0:" ,*js-separator*))))

(def-js-codegen %function-return (name)
  (& (funinfo-var? (get-funinfo name) *return-id*)
     `(,*js-indent* "return " ,*return-id* ,*js-separator*)))

(def-js-codegen %function-epilogue (name)
  (| `((%function-return ,name)
       ,@(& (< 0 (funinfo-num-tags (get-funinfo name)))
            `("}}")))
      ""))


;;;; ASSIGNMENTS

(def-js-codegen %= (dest val)
  (? (& (not dest) (atom val))
     '(%native "")
     `(,*js-indent*
       ,@(? dest
            `((%native ,dest " = ")))
       ,(? (| (atom val)
              (codegen-expr? val))
           val
           `(,val. " " ,@(c-list .val)))
      ,*js-separator*)))


;;;; VARIABLE DECLARATIONS

(def-js-codegen %var (&rest names)
  `(%native ,*js-indent* "var " ,(c-list names :parens-type nil) ,*js-separator*))


;;;; TYPE PREDICATES

(defmacro def-js-infix (name)
  `(def-codegen-infix *js-transpiler* ,name))

(def-js-infix instanceof)


;;;; SYMBOL REPLACEMENTS

(transpiler-translate-symbol *js-transpiler* nil "null")
(transpiler-translate-symbol *js-transpiler* t   "true")


;;;; NUMBERS, ARITHMETIC AND COMPARISON

(defmacro def-js-binary (op repl-op)
  `(def-codegen-binary *js-transpiler* ,op ,repl-op))

(progn
  ,@(@ [`(def-js-binary ,@_)]
       '((%+        "+")
         (%string+  "+")
         (%-        "-")
         (%/        "/")
         (%*        "*")
         (%mod      "%")

         (%==       "==")
         (%!=       "!=")
         (%<        "<")
         (%>        ">")
         (%<=       "<=")
         (%>=       ">=")
         (%===      "===")
         (%!==      "!==")

         (%<<       "<<")
         (%>>       ">>")
         (%bit-or   "|")
         (%bit-and  "&"))))


;;;; ARRAYS

(def-js-codegen %make-array (&rest elements)
  `(%native ,@(c-list elements :parens-type :brackets)))

(def-js-codegen %aref (arr &rest idx)
  `(%native ,arr ,@(@ [`("[" ,_ "]")] idx)))

(def-js-codegen =-%aref (val &rest x)
  `(%native (%aref ,@x) " = " ,val))


;;;; HASH TABLES

(def-js-codegen hremove (h key)
  `(%native "delete " ,h "[" ,key "]"))


;;;; (JSON) OBJECTS

(def-js-codegen oref (arr &rest idx)
  `(%aref ,arr ,@idx))

(def-js-codegen =-oref (val &rest x)
  `(=-%aref ,val ,@x))

(def-js-codegen %make-json-object (&rest args)
  (c-list (@ [`( ,_. ": " ,._.)] (group args 2))
          :parens-type :braces))

(def-js-codegen %new (&rest x)
  (? x
     `(%native "new " ,(? (defined-function x.)
                           (compiled-function-name-string x.)
                           x.)
                       ,@(c-list .x))
     `(%native "{}")))

(def-js-codegen delete-object (x)
  `(%native "delete " ,x))


;;;; METACODES

(def-js-codegen quote (x)
  (js-compiled-symbol x))

(def-js-codegen %slot-value (x y)
  `(%native ,x "." ,(compiled-slot-name y)))

(def-js-codegen %=-slot-value (v x y)
  `(%native ,x "." ,(compiled-slot-name y) " = " ,v))

(def-js-codegen %try () ; TODO: Check if stale.
  '(%native "try {"))

(def-js-codegen %closing-bracket () ; TODO: Check if stale.
  '(%native "}"))

(def-js-codegen %catch (x)  ; TODO: Check if stale.
  `(%native "catch (" ,x ") {"))


;;;; BACKEND METACODES

(def-js-codegen %vec (v i)
  `(%native ,v "[" ,i "]"))

(def-js-codegen %=-vec (v i x)
  `(%native (%aref ,v ,i) "=" ,x ,*js-separator*))

(def-js-codegen %js-typeof (x)
  `(%native "typeof " ,x))

(def-js-codegen %invoke-debugger ()
  '(%native "null; debugger"))

(def-js-codegen %eval (x)
  `(%native "window.eval (" ,x ")"))

;;; TODO: Looking like a PHP target stub. (pixel)
(def-js-codegen %global (x)
  x)

;;;; CLASSES

(def-js-codegen %js-class-head (cls)
  `(%native
     "class " ,(class-name cls)
     ,@(!? (class-base cls)
           `(" extends " ,!))
     "{"))

(def-js-codegen %js-class-tail ()
  `(%native "}" ""))

(fn js-class-slot-flags (slot)
  (pad (@ [?
            (in? _ :protected :public)
              ""
            (eq _ :private)
              (+ "#" (downcase (symbol-name _)))
            (downcase (symbol-name _))]
          (%slot-flags slot))
       " "))

(fn js-class-member (cls slot)
  (… (| (js-class-slot-flags slot) "")
     " "
     (%slot-name slot)
     *js-separator*))

(fn js-class-method (cls slot x)
  (with-temporary *funinfo* (lambda-funinfo .x.)
    `(,@(js-class-slot-flags slot) " "
      ,(funinfo-comment *funinfo*)
      ,(case x.
         '__constructor  'constructor
         x.)
      ,@(c-list (argument-expand-names (lambda-name .x.)
                                       (lambda-args .x.))) ,*terpri*
      "{" ,*terpri*
          ,@(lambda-body .x.)
      "}" ,*terpri*)))

(fn js-class-slot (cls x)
  (let slot (class-slot-by-name cls x.)
    (? (eq :member (%slot-type slot))
       (js-class-member cls slot)
       (js-class-method cls slot x))))

(def-js-codegen %collection (class-name &rest pairs)
  (!= (href (defined-classes) class-name)
    `((%js-class-head ,!)
      ,@(+@ [js-class-slot ! ._] pairs)
      (%js-class-tail))))


;;;; MISCELLANEOUS

(def-js-codegen %comment (&rest x)
  `(%native "/* " ,@x " */" ,*terpri*))
