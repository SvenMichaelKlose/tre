;;;; UTILITIES

(fn php-line (&rest x)
  `(,*php-indent* ,@x ,*php-separator*))

(fn php-dollarize (x)
  (?
    (not x)     "NULL"
    (eq t x)    "TRUE"
    (symbol? x) `("$" ,x)
    x))

(fn php-argument-list (x)
  (c-list x))

(defmacro def-php-codegen (name &body body)
  `(define-codegen-macro *php-transpiler* ,name ,@body))

(defmacro def-php-infix (name)
  `(def-codegen-infix *php-transpiler* ,name))


;;;; TRUTH

(add-symbol-translation *php-transpiler* nil "NULL")
(add-symbol-translation *php-transpiler* t "TRUE")


;;;; LITERAL SYMBOLS

(def-php-codegen quote (x)
  (php-dollarize (php-compiled-symbol x)))

(def-php-codegen %fname (x &optional (fname nil))
  (? (| (not fname)
        (& (not (funinfo-find (get-funinfo fname) x))
           (defined-function x)))
     (compiled-function-name-string x)
     x))

(def-php-codegen %vname (x &optional (fname nil))
  `("$" ,x))


;;;; CONTROL FLOW

(def-php-codegen %tag (tag)
  `("_I_" ,tag ":" ,*terpri*))

(fn php-jump (tag)
  `("goto _I_" ,tag))

(def-php-codegen %go (tag)
  (php-line (php-jump tag)))

(def-php-codegen %go-nil (tag x)
  (php-line "if (" x " === null || " x " === false) " (php-jump tag)))

(def-php-codegen %go-not-nil (tag x)
  (php-line "if (!(" x " === null || " x " === false)) " (php-jump tag)))


;;;; FUNCTIONS

(fn codegen-php-function-0 (&key name fi args body (return-type nil))
  `(,*terpri*
    ,(funinfo-comment fi)
    "function " ,name ,@(php-argument-list args)
    ,@(!? return-type
          `(" : " ,!))
    ,*terpri*
    "{" ,*terpri*
       ,@(!? (funinfo-globals fi)
             (php-line "global " (pad (@ #'php-dollarize !) ", ")))
       ,@body
       ,@(unless (equal return-type "void")
           (… (php-line "return $" *return-symbol*)))
    "}" ,*terpri*))

(fn codegen-php-function (x)
  (with (fi   (lambda-funinfo x)
         name (funinfo-name fi))
    (developer-note "#'~A~%" name)
    (codegen-php-function-0
        :name (compiled-function-name name)
        :fi   fi
        :args (funinfo-args fi)
        :body (lambda-body x))))

(def-php-codegen function (&rest x)
  (? .x
     (codegen-php-function (. 'function x))
     `(%string ,(convert-identifier (? (%fname? x.)
                                       (cadr x.)
                                       x.)))))

(def-php-codegen %function-prologue (name) "")
(def-php-codegen %function-epilogue (name) "")
(def-php-codegen %function-return (name)   "")

(def-php-codegen %closure (name)
  (with (fi          (get-funinfo name)
         native-name `(%string ,(compiled-function-name-string name)))
    (? (funinfo-scope-arg fi)
       `("new __closure ("
              ,native-name
              ","
              ,(php-dollarize (funinfo-scope (funinfo-parent fi)))
         ")")
       native-name)))


;;;; ASSIGNMENTS

(fn php-%=-value (val)
  (?
    (& (cons? val)
       (eq 'tre_cons val.))
      `("new __cons (" ,.val. ", " ,..val. ")")
    (literal? val)
      (… val)
    (| (atom val)
       (& (%native? val)
          (atom .val.)
          (not ..val)))
      (… "$" val)
    (codegen-expr? val)
      (… val)
    `(,val. " " ,@(c-list (@ #'php-dollarize .val)))))

(def-php-codegen %= (dest val)
  (? (& (not dest)
        (atom val))  ; TODO: remove (pixel)
     ""
     `(,*php-indent*
       ,@(!? dest `(,! " = "))
       ,@(php-%=-value val)
       ,*php-separator*)))

(def-php-codegen %set-local-fun (plc val)
  `(,plc " = " ,val))


;;;; INTERNAL VECTORS
; Implements lexical scope since PHP-5.

(def-php-codegen %make-scope (&rest elements)
  `("new __l ()"))

(def-php-codegen %vec (v i)
  `(,v "->g (" ,i ")"))

(def-php-codegen %=-vec (v i x)
  `(,*php-indent*
     ,v "->s (" ,i ", " ,(php-%=-value x) ")" ,*php-separator*))


;;;; NUMBERS

(defmacro def-php-binary (op replacement-op)
  (print-definition `(def-php-binary ,op ,replacement-op))
  `(def-expander-macro (transpiler-codegen-expander *php-transpiler*)
                       ,op (&rest args)
     `(,,@(pad args ,(+ " " replacement-op " ")))))

(progn
  ,@(@ [`(def-php-binary ,@_)]
       '((%+        "+")
         (%string+  ".")
         (%-        "-")
         (%*        "*")
         (%/        "/")
         (%mod      "%")

         (%==       "==")
         (%<        "<")
         (%>        ">")
         (%<=       "<=")
         (%>=       ">=")

         ; NOTE: These do not test identity.
         (%===      "===")
         (%!==      "!==")

         (%<<       "<<")
         (%>>       ">>")
         (%bit-or   "|")
         (%bit-and  "&"))))


;;;; ARRAYS

(define-filter php-array-subscript (x)
  `("[" ,x "]"))

(fn php-literal-array-element (x)
  (… (compiled-function-name '%%key) " (" x. ") => " .x.))

(fn php-literal-array-elements (x)
  (pad (@ #'php-literal-array-element x) ", "))

(def-php-codegen %make-array (&rest elements)
  `("[" ,@(php-literal-array-elements (group elements 2)) "]"))

(def-php-codegen %aref (arr &rest indexes)
  `(,arr ,@(php-array-subscript indexes)))

(def-php-codegen %aref-defined? (arr &rest indexes)
  `("isset (" ,arr ,@(php-array-subscript indexes) ")"))

(def-php-codegen =-%aref (val &rest x)
  `((%aref ,@x) " = " ,val))

(def-php-codegen %unset-aref (x key)
  `("null; unset ($" ,x "[" ,key "])"))


;;;; OBJECTS

(def-php-codegen oref (arr &rest indexes)
  `(href ,arr ,@indexes))

(def-php-codegen =-oref (val arr &rest indexes)
  `(=-href ,val ,arr ,@indexes))

(fn php-literal-object-element (x)
  `(,(? (symbol? x.)
        (downcase (symbol-name x.))
        x.)
     " => "
     ,.x.))

(fn php-literal-object-elements (x)
  (pad (@ #'php-literal-object-element
          (group x 2))
       ","))

(def-php-codegen %make-object (&rest x)
  `("(object)[" ,@(php-literal-object-elements x) "]"))

(def-php-codegen %make-json-object (&rest x)
  `("[" ,@(php-literal-object-elements x) "]"))

(def-php-codegen %new (&rest x)
  (? x
     (? (| (%string? x.)
           (keyword? x.))
        `(%make-object ,@x)
        `("new " ,x. ,@(php-argument-list .x)))
     `"new stdClass"))

(def-php-codegen delete-object (x)
  `("null; unset " ,x))

(def-php-codegen %slot-value (x n)
  `(,x "->" ,(compiled-slot-name n)))

(def-php-codegen %=-slot-value (v x n)
  `(,x "->" ,(compiled-slot-name n) " = " ,v))

(def-php-codegen %slot-value-var (x n)
  `(,x "->{" ,n "}"))

(def-php-codegen %=-slot-value-var (v x n)
  `(,x "->{" ,n "}" " = " ,v))


;;;; CLASSES

(def-php-codegen %php-class-head (cls &key (implements nil))
  (when (member-if [member _ '(aref =-aref delete-aref)]
                   (class-slot-names cls))
    (push "ArrayAccess" implements))
  `("class " ,(class-name cls)
    ,@(!? (class-base cls)
          `(" extends " ,!))
    ,@(!? implements
          `(" implements " ,(pad (ensure-list !) ", ")))
    "{"))

(def-php-codegen %php-class-tail ()
  "}")

(fn php-class-slot-flags (slot)
  (pad (@ [downcase (symbol-name _)]
          (%slot-flags slot))
       " "))

(fn php-class-member (cls slot)
  (… (| (php-class-slot-flags slot)
        "var")
     " $" (%slot-name slot)
     *php-separator*))

(fn php-class-method (cls slot x)
  `(,@(php-class-slot-flags slot) " "
    ,@(? (eq '=-aref x.)
         (codegen-php-function-0
             :name  'offset-set
             :return-type
                    "void"
             :fi    (lambda-funinfo .x.)
             :args  (!= (lambda-args .x.)
                      (… .!. !.))
             :body  (lambda-body .x.))
         (codegen-php-function-0
             :name  (case x.
                      '__constructor  '__construct
                      'aref           'offset-get
                      'aref?          'offset-exists
                      'delete-aref    'offset-unset
                      x.)
             :return-type
                    (case x.
                      'aref         "mixed"
                      'aref?        "bool"
                      'delete-aref  "void")
             :fi    (lambda-funinfo .x.)
             :args  (lambda-args .x.)
             :body  (lambda-body .x.)))))

(fn php-class-slot (cls x)
  (let slot (class-slot-by-name cls x.)
    (? (eq :member (%slot-type slot))
       (php-class-member cls slot)
       (php-class-method cls slot x))))

(def-php-codegen %collection (which &rest items)
  (!= (href (defined-classes) which)
    `((%php-class-head ,!)
      ,@(+@ [php-class-slot ! ._] items)
      (%php-class-tail))))


;;;; GLOBAL VARIABLES

(def-php-codegen %global (x)
  `("$GLOBALS['" ,(convert-identifier x) "']"))


;;;; MISCELLANEOUS

(def-php-codegen %comment (&rest x)
  `("/* " ,@x " */" ,*terpri*))
