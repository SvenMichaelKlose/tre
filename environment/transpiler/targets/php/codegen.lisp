;;;; CODE GENERATION HELPERS

(fn php-line (&rest x)
  `(,*php-indent* ,@x ,*php-separator*))

(fn php-dollarize (x)
  (?
    (not x)      "NULL"
    (eq t x)     "TRUE"
    (symbol? x)  `("$" ,x)
    x))

(fn php-argument-list (x)
  (c-list (@ #'php-dollarize x)))

(defmacro def-php-codegen (name &body body)
  `(define-codegen-macro *php-transpiler* ,name ,@body))

(defmacro def-php-infix (name)
  `(def-codegen-infix *php-transpiler* ,name))


;;;; TRUTH

(transpiler-translate-symbol *php-transpiler* nil "NULL")
(transpiler-translate-symbol *php-transpiler* t "TRUE")


;;;; LITERAL SYMBOLS

(def-php-codegen quote (x)
  (php-compiled-symbol x))


;;;; CONTROL FLOW

(def-php-codegen %%tag (tag)
  `(%%native "_I_" ,tag ":" ,*terpri*))

(fn php-jump (tag)
  `("goto _I_" ,tag))

(def-php-codegen %%go (tag)
  (php-line (php-jump tag)))

(def-php-codegen %%go-nil (tag val)
  (let v (php-dollarize val)
    (php-line "if (" v " === null || " v " === false) " (php-jump tag))))

(def-php-codegen %%go-not-nil (tag val)
  (let v (php-dollarize val)
    (php-line "if (!(" v " === null || " v " === false)) " (php-jump tag))))


;;;; FUNCTIONS

(fn codegen-php-function (x)
  (with (fi             (get-lambda-funinfo x)
         name           (funinfo-name fi)
         num-locals     (length (funinfo-vars fi))
         compiled-name  (compiled-function-name name))
    (developer-note "Generating function ~A…~%" name)
    `(,*terpri*
      ,(funinfo-comment fi)
      "function " ,compiled-name ,@(php-argument-list (funinfo-args fi)) ,*terpri*
      "{" ,*terpri*
         ,@(!? (funinfo-globals fi)
               (php-line "global " (pad (@ #'php-dollarize !) ", ")))
         ,@(lambda-body x)
         ,(php-line "return $" '~%ret)
      "}" ,*terpri*)))

(def-php-codegen function (&rest x)
  (? .x
     (codegen-php-function (. 'function x))
     `(%%native (%%string ,(convert-identifier x.)))))

(def-php-codegen %function-prologue (name) '(%%native ""))
(def-php-codegen %function-epilogue (name) '(%%native ""))
(def-php-codegen %function-return (name)   '(%%native ""))

(def-php-codegen %closure (name)
  (with (fi            (get-funinfo name)
         native-name  `(%%string ,(compiled-function-name-string name)))
    (? (funinfo-scope-arg fi)
       `(%%native "new __closure (" ,native-name "," ,(php-dollarize (funinfo-scope (funinfo-parent fi))) ")")
       native-name)))


;;;; ASSIGNMENTS

(fn php-%=-value (val)
  (?
    (& (cons? val)
       (eq 'tre_cons val.))
      `("new __cons (" ,(php-dollarize .val.) ", " ,(php-dollarize ..val.) ")")
    (constant-literal? val)
      (list val)
    (| (atom val)
       (& (%%native? val)
          (atom .val.)
          (not ..val)))
      (list "$" val)
    (codegen-expr? val)
      (list val)
    `((,val. " " ,@(c-list (@ #'php-dollarize .val))))))

(def-php-codegen %= (dest val)
  (? (& (not dest) (atom val))
     '(%%native "")
     `(%%native
        ,*php-indent*
        ,@(& dest
             `(,(php-dollarize dest) ," = "))
        ,@(php-%=-value val)
        ,*php-separator*)))

(def-php-codegen %set-local-fun (plc val)
  `(%%native ,(php-dollarize plc) " = " ,(php-dollarize val)))


;;;; VECTORS

(def-php-codegen %make-scope (&rest elements)
  `(%%native "new __l ()" ""))

(def-php-codegen %vec (v i)
  `(%%native ,(php-dollarize v) "->g (" ,(php-dollarize i) ")"))

(def-php-codegen %set-vec (v i x)
  `(%%native ,*php-indent* ,(php-dollarize v) "->s (" ,(php-dollarize i) ", " ,(php-%=-value x) ")",*php-separator*))


;;;; NUMBERS

(defmacro def-php-binary (op replacement-op)
  (print-definition `(def-php-binary ,op ,replacement-op))
  `(def-expander-macro (transpiler-codegen-expander *php-transpiler*) ,op (&rest args)
     `(%%native ,,@(pad (@ #'php-dollarize args)
                ,(+ " " replacement-op " ")))))

(progn
  ,@(@ [`(def-php-binary ,@_)]
       '((%%%+        "+")
         (%%%string+  ".")
         (%%%-        "-")
         (%%%*        "*")
         (%%%/        "/")
         (%%%mod      "%")

         (%%%==       "==")
         (%%%<        "<")
         (%%%>        ">")
         (%%%<=       "<=")
         (%%%>=       ">=")
         (%%%eq       "===")

         (%%%<<       "<<")
         (%%%>>       ">>")
         (%%%bit-or   "|")
         (%%%bit-and  "&"))))


;;;; ARRAYS

(fn php-array-subscript (indexes)
  (@ [`("[" ,(php-dollarize _) "]")] indexes))

(fn php-literal-array-element (x)
  (list (compiled-function-name '%%key) " (" (php-dollarize x.) ") => " (php-dollarize .x.)))

(fn php-literal-array-elements (x)
  (pad (@ #'php-literal-array-element x) ", "))

(def-php-codegen %%%make-array (&rest elements)
  `(%%native "[" ,@(php-literal-array-elements (group elements 2)) "]"))

; TODO: Replace by CL type MAKE-ARRAY.
(def-php-codegen make-array (&rest elements)
  `(%%native "new __array ()" ""))

(def-php-codegen aref (arr &rest indexes)
  `(href ,arr ,@indexes))

(def-php-codegen =-aref (val arr &rest indexes)
  `(=-href ,val ,arr ,@indexes))

(def-php-codegen %aref (arr &rest indexes)
  `(%%native ,(php-dollarize arr) ,@(php-array-subscript indexes)))

(def-php-codegen %aref-defined? (arr &rest indexes)
  `(%%native "isset (" ,(php-dollarize arr) ,@(php-array-subscript indexes) ")"))

(def-php-codegen =-%aref (val &rest x)
  `(%%native (%aref ,@x) " = " ,(php-dollarize val)))


;;;; HASH TABLES

(def-php-codegen href (h k)
  `(%%native "(is_array (" ,(php-dollarize h) ")) ? "
                 ,(php-dollarize h) "[" ,(php-dollarize k) "] ?? NULL : "
                 ,(php-dollarize h) "->g(" ,(compiled-function-name '%%key) "(" ,(php-dollarize k) "))"))

(def-php-codegen =-href (v h k)
  `(%%native "(is_array (" ,(php-dollarize h) ")) ? "
                 ,(php-dollarize h) "[" ,(php-dollarize k) "] = " ,(php-dollarize v) " : "
                 ,(php-dollarize h) "->s(" ,(compiled-function-name '%%key) "(" ,(php-dollarize k) ")," ,(php-dollarize v) ")"))

(def-php-codegen hremove (h key)
  `(%%native "null; unset ($" ,h "[" ,(php-dollarize key) "])"))

(def-php-codegen make-hash-table (&rest ignored-args)
  `(%%native "new __array ()" ""))


;;;; OBJECTS

(def-php-codegen oref (arr &rest indexes)
  `(href ,arr ,@indexes))

(def-php-codegen =-oref (val arr &rest indexes)
  `(=-href ,val ,arr ,@indexes))

(fn php-literal-object-element (x)
  `(,x. " => " ,(php-dollarize .x.)))

(fn php-literal-object-elements (x)
  (pad (@ #'php-literal-object-element x) ", "))

(def-php-codegen %%%make-object (&rest elements)
  `(%%native "(object) array (" ,@(php-literal-object-elements (group elements 2)) ")"))

(def-php-codegen %new (&rest x)
  (? x
     `(%%native "new " ,x. ,@(php-argument-list .x))
     `(%%native "new stdClass")))

(def-php-codegen delete-object (x)
  `(%%native "null; unset " ,x))

(def-php-codegen %slot-value (x y)
  `(%%native ,(php-dollarize x)
             "->"
             ,(?
                (%%string? y)  .y.
                (symbol? y)    (convert-identifier (make-symbol (symbol-name y) "TRE"))
                y)))

(def-php-codegen prop-value (x y)  ; TODO: Use SLOT-VALUE instead.
  `(%%native ,(php-dollarize x) "->$" ,y))

(def-php-codegen %php-class-head (name)
  `(%%native "class " ,name "{"))

(def-php-codegen %php-class-tail ()
  `(%%native "}" ""))


;;;; GLOBAL VARIABLES

(def-php-codegen %global (x)
  `(%%native "$GLOBALS['" ,(convert-identifier x) "']"))


;;;; MISCELLANEOUS

(def-php-codegen %%comment (&rest x)
  `(%%native "/* " ,@x " */" ,*terpri*))
