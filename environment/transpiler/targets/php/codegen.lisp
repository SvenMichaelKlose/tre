;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

;;;; CODE GENERATION HELPERS

(defvar *php-by-reference?* nil)

(defun php-line (&rest x)
  `(,*php-indent* ,@x ,*php-separator*))

(defun php-dollarize (x)
  (? (symbol? x)
     (?
       (not x) "NULL"
       (eq t x) "TRUE"
       (number? x) x
       (string? x) x
	   `("$" ,x))
	 x))

(defun php-list (x)
  (pad (filter #'php-dollarize x) ","))

(defun php-argument-list (x)
  (c-list (filter #'php-dollarize x)))

(define-codegen-macro-definer define-php-macro *php-transpiler*)

(defmacro define-php-infix (name)
  `(define-transpiler-infix *php-transpiler* ,name))


;;;; TRUTH

(transpiler-translate-symbol *php-transpiler* nil "NULL")
(transpiler-translate-symbol *php-transpiler* t "TRUE")


;;;; LITERAL SYMBOLS

(define-php-macro %quote (x)
  (php-compiled-symbol x))


;;;; CONTROL FLOW

(define-php-macro %%tag (tag)
  `(%%native "_I_" ,tag ":" ,*php-newline*))

(defun php-jump (tag)
  `("goto _I_" ,tag))

(define-php-macro %%go (tag)
  (php-line (php-jump tag)))

(define-php-macro %%go-nil (tag val)
  (let v (php-dollarize val)
    (php-line "if (!" v "&&!is_string(" v ")&&!is_numeric(" v ")&&!is_array(" v ")) { " (php-jump tag) "; }")))

(define-php-macro %%go-not-nil (tag val)
  (let v (php-dollarize val)
    (php-line "if (!(!" v "&&!is_string(" v ")&&!is_numeric(" v ")&&!is_array(" v "))) { " (php-jump tag) "; }")))

(define-php-macro return-from (block-name x)
  (error "Cannot return from unknown BLOCK ~A." block-name))


;;;; FUNCTIONS

(defun codegen-php-function (x)
  (with (fi            (get-lambda-funinfo x)
         name          (funinfo-name fi)
		 num-locals    (length (funinfo-vars fi))
	     compiled-name (compiled-function-name name))
    `(,*php-newline*
      ,(funinfo-comment fi)
	  "function " ,compiled-name ,@(php-argument-list (funinfo-args fi))
      "{" ,(code-char 10)
		 ,@(awhen (funinfo-globals fi)
             (php-line "global " (php-list !)))
         ,@(& *print-executed-functions?*
              `("echo \"" ,compiled-name "\\n\";"))
         ,@(lambda-body x)
       	 ,(php-line "return $" '~%ret)
      "}" ,*php-newline*)))

(define-php-macro function (&rest x)
  (? .x
     (codegen-php-function (cons 'function x))
     `(%%native (%%string ,(obfuscated-identifier x.)))))

(define-php-macro %function-prologue (name) '(%%native ""))
(define-php-macro %function-epilogue (name) '(%%native ""))
(define-php-macro %function-return (name)   '(%%native ""))

(defun php-codegen-argument-filter (x)
  (php-dollarize x))

(define-php-macro %%closure (name)
  (with (fi            (get-funinfo name)
         native-name  `(%%string ,(compiled-function-name-string name)))
    (? (funinfo-scope-arg fi)
  	   `(%%native "new __closure(" ,native-name "," ,(php-dollarize (funinfo-scope (funinfo-parent fi))) ")")
       native-name)))


;;;; ASSIGNMENTS

(defun %%native-without-reference? (val)
  (& (%%native? val)
     (string? .val.)
     (empty-string? .val.)))

(defun php-assignment-operator (val)
  (? (| (& (atom val) ; XXX required?
	  	   (symbol? val))
		(not (%%native-without-reference? val)))
     (? *php-by-reference?*
   	    "=&"
        "=")
  	 "="))
 
(defun php-%=-value (val)
  (?
    (& (cons? val)
       (eq 'userfun_cons val.))
      `("new __cons (" ,(php-dollarize .val.) "," ,(php-dollarize ..val.) ")")
    (| (not val)        ; XXX CONSTANT-LITERAL?
       (eq t val)
       (number? val)
       (string? val))
      (list val)
	(| (atom val)
	    (& (%%native? val)
		   (atom .val.)
		   (not ..val)))
      (list "$" val)
	(codegen-expr? val)
	  (list val)
    `((,val. ,@(c-list (filter #'php-codegen-argument-filter .val))))))

(defun php-%=-0 (dest val)
  `((%%native
	    ,*php-indent*
	    ,@(? dest
			 `(,@(& (atom dest)
				    (list "$"))
			   ,dest
			   ,(php-assignment-operator val))
	         '(""))
        ,@(php-%=-value val)
        ,@(unless (& (not dest)
                     (%%native? val)
                     (not ..val))
            (list *php-separator*)))))

(define-php-macro %= (dest val)
  (? (& (not dest) (atom val))
     '(%%native "")
     (php-%=-0 dest val)))

(define-php-macro %set-atom-fun (plc val)
  `(%%native ,(php-dollarize plc)
             ,(php-assignment-operator val)
             ,(php-dollarize val)))


;;;; VECTORS

(define-php-macro %make-scope (&rest elements)
  `(%%native "new __l()" ""))

(define-php-macro %vec (v i)
  `(%%native ,(php-dollarize v) "->g(" ,(php-dollarize i) ")"))

(define-php-macro %set-vec (v i x)
  `(%%native ,*php-indent* ,(php-dollarize v) "->s(" ,(php-dollarize i) "," ,(php-%=-value x) ")",*php-separator*))


;;;; NUMBERS

(defmacro define-php-binary (op replacement-op)
  (print-definition `(define-php-binary ,op ,replacement-op))
  (let tre *php-transpiler*
	(transpiler-add-plain-arg-fun tre op)
	`(define-expander-macro ,(transpiler-codegen-expander tre) ,op (&rest args)
	   `(%%native ,,@(pad (filter #'php-dollarize args) ,replacement-op)))))

(mapcar-macro x
    '((%%%+   "+")
      (%%%-   "-")
      (%%%*   "*")
      (%%%/   "/")
      (%%%mod "%")
      (%%%==  "==")
      (%%%<   "<")
      (%%%>   ">")
      (%%%<=  "<=")
      (%%%>=  ">=")
      (%%%eq  "==="))
  `(define-php-binary ,@x))

(define-php-binary %%%string+ ".")


;;;; ARRAYS

(defun php-array-subscript (indexes)
  (filter [`("[" ,(php-dollarize _) "]")]
          indexes))

(defun php-literal-array-element (x)
  (list (compiled-function-name '%%key) " (" (php-dollarize x.) ") => " (php-dollarize .x.)))

(defun php-literal-array-elements (x)
  (pad (filter #'php-literal-array-element x) ","))

(define-php-macro %%%make-hash-table (&rest elements)
  `(%%native "Array (" ,@(php-literal-array-elements (group elements 2)) ")"))

(define-php-macro make-array (&rest elements)
  `(%%native "new __array ()" ""))

(define-php-macro aref (arr &rest indexes)
  `(href ,arr ,@indexes))

(define-php-macro =-aref (val arr &rest indexes)
  `(=-href ,val ,arr ,@indexes))

(define-php-macro php-aref (arr &rest indexes)
  `(%%native ,(php-dollarize arr) ,@(php-array-subscript indexes)))

(define-php-macro php-aref-defined? (arr &rest indexes)
  `(%%native "isset (" ,(php-dollarize arr) ,@(php-array-subscript indexes) ")"))

(define-php-macro =-php-aref (val &rest x)
  `(%%native (php-aref ,@x)
             ,(php-assignment-operator val)
             ,(php-dollarize val)))


;;;; HASH TABLES

(defun php-array-indexes (x)
  (mapcan [list "[" (php-dollarize _) "]"] x))

(define-php-macro %%%href (h &rest k)
  `(%%native ,(php-dollarize h) ,@(php-array-indexes k)))

(define-php-macro %%%href-set (v h &rest k)
  `(%%native ,(php-dollarize h) ,@(php-array-indexes k) " = " ,(php-dollarize v)))

(define-php-macro href (h k)
  `(%%native "(is_a (" ,(php-dollarize h) ", '__l') || is_a (" ,(php-dollarize h) ", '__array')) ? "
                 ,(php-dollarize h) "->g(userfun_T37T37key (" ,(php-dollarize k) ")) : "
                 "(isset (" ,(php-dollarize h) "[userfun_T37T37key (" ,(php-dollarize k) ")]) ? "
                     ,(php-dollarize h) "[userfun_T37T37key (" ,(php-dollarize k) ")] : "
                     "NULL)"))

(define-php-macro =-href (v h k)
  `(%%native "(is_a (" ,(php-dollarize h) ", '__l') || is_a (" ,(php-dollarize h) ", '__array')) ? "
                 ,(php-dollarize h) "->s(userfun_T37T37key (" ,(php-dollarize k) ")," ,(php-dollarize v) ") : "
                 ,(php-dollarize h) "[userfun_T37T37key (" ,(php-dollarize k) ")] = " ,(php-dollarize v)))

(define-php-macro hremove (h key)
  `(%%native "null; unset ($" ,h "[" ,(php-dollarize key) "])"))

(define-php-macro make-hash-table (&rest ignored-args)
  `(make-array))

(define-php-macro %%make-hash-table (&rest args)
  `(%%native "new __array (Array (" ,@(php-literal-array-elements (group args 2)) "))"))


;;;; OBJECTS

(define-php-macro %new (&rest x)
  `(%%native "new " ,x. ,@(php-argument-list .x)))

(define-php-macro delete-object (x)
  `(%%native "null; unset " ,x))

(define-php-macro %slot-value (x y)
  (? (cons? x)
	 (? (%%native? x)
		`(%%native ,(php-dollarize x) "->" ,y)
		(error "%%NATIVE expected instead of ~A." x))
	 `(%%native "$" ,x "->" ,y)))

(define-php-macro %php-class-head (name)
  `(%%native "class " ,name "{"))

(define-php-macro %php-class-tail ()
  `(%%native "}" ""))


;;;; GLOBAL VARIABLES

(define-php-macro %global (x)
  `(%%native "$GLOBALS['" ,(obfuscated-identifier x) "']"))
