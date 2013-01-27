;;;;; tré – Copyright (c) 2008–2013 Sven Michael Klose <pixel@copei.de>

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
  (parenthized-comma-separated-list (filter #'php-dollarize x)))

(define-codegen-macro-definer define-php-macro *php-transpiler*)

(defmacro define-php-infix (name)
  `(define-transpiler-infix *php-transpiler* ,name))


;;;; TRUTH

(transpiler-translate-symbol *php-transpiler* nil "NULL")
(transpiler-translate-symbol *php-transpiler* t "TRUE")


;;;; ARGUMENT EXPANSION CONSING

(define-php-macro %%%cons (a d)
  `(userfun_cons ,a ,d))


;;;; LITERAL SYMBOLS

(define-php-macro %quote (x)
  (php-compiled-symbol x))


;;;; CONTROL FLOW

(define-php-macro %%tag (tag)
  (? *php-goto?*
     `(%transpiler-native "_I_" ,tag ":" ,*php-newline*)
     `(%transpiler-native "case " ,tag ":" ,*php-newline*)))

(defun php-jump (tag)
  (? *php-goto?*
     `("goto _I_" ,tag)
     `(" $_I_=" ,tag "; break")))

(define-php-macro %%go (tag)
  (php-line (php-jump tag)))

(define-php-macro %%go-nil (val tag)
  (let v (php-dollarize val)
    (php-line "if (!" v "&&!is_string(" v ")&&!is_numeric(" v ")&&!is_array(" v ")) { " (php-jump tag) "; }")))


;;;; FUNCTIONS

(defun codegen-php-function (name x)
  (with (args (argument-expand-names 'unnamed-c-function (lambda-args x))
		 fi (get-lambda-funinfo x)
		 num-locals (length (funinfo-vars fi))
	     compiled-name (compiled-function-name *transpiler* name))
    `(,(code-char 10)
	  "function " ,compiled-name ,@(php-argument-list args)
      "{" ,(code-char 10)
		 ,@(awhen (funinfo-globals fi)
             (php-line "global " (php-list !)))
         ,@(& *print-executed-functions?*
              `("echo \"" ,compiled-name "\\n\";"))
         ,@(unless *php-goto?*
             (list "    $_I_=0; while (1) { switch ($_I_) { case 0:" *php-newline*))
         ,@(lambda-body x)
       	 ,(php-line "return $" '~%ret)
         ,@(unless *php-goto?*
             (list "    }}" *php-newline*))
      "}" ,*php-newline*)))

(define-php-macro function (name &optional (x 'only-name))
  (? (eq 'only-name x)
     `(%transpiler-native (%transpiler-string ,(compiled-function-name-string *transpiler* name)))
  	 (? (atom x)
		(error "codegen: arguments and body expected: ~A" x)
	  	(codegen-php-function name x))))

(define-php-macro %function-prologue (fi-sym) '(%transpiler-native ""))
(define-php-macro %function-epilogue (fi-sym) '(%transpiler-native ""))
(define-php-macro %function-return (fi-sym) '(%transpiler-native ""))

(defun php-codegen-argument-filter (x)
  (php-dollarize x))

(define-php-macro %%closure (name fi-sym)
  (let fi (get-funinfo-by-sym fi-sym)
    (? (funinfo-ghost fi)
  	   `(%transpiler-native "new __closure("
             (%transpiler-string ,(compiled-function-name-string *transpiler* name))
             ","
             ,(php-dollarize (funinfo-lexical (funinfo-parent fi)))
             ")")
	   name)))


;;;; ASSIGNMENTS

(defun %transpiler-native-without-reference? (val)
  (& (%transpiler-native? val)
     (string? .val.)
     (empty-string? .val.)))

(defun php-assignment-operator (val)
  (? (| (& (atom val) ; XXX required?
	  	   (symbol? val))
		(not (%transpiler-native-without-reference? val)))
     (? *php-by-reference?*
   	    "=&"
        "=")
  	 "="))
 
(defun php-%setq-value (val)
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
	    (& (%transpiler-native? val)
		   (atom .val.)
		   (not ..val)))
      (list "$" val)
	(codegen-expr? val)
	  (list val)
    `((,val. ,@(parenthized-comma-separated-list (filter #'php-codegen-argument-filter .val))))))

(defun php-%setq-0 (dest val)
  `((%transpiler-native
	    ,*php-indent*
	    ,@(? dest
			 `(,@(& (atom dest)
				    (list "$"))
			   ,dest
			   ,(php-assignment-operator val))
	         '(""))
        ,@(php-%setq-value val)
        ,@(unless (& (not dest)
                     (%transpiler-native? val)
                     (not ..val))
            (list *php-separator*)))))

(define-php-macro %setq (dest val)
  (? (& (not dest) (atom val))
     '(%transpiler-native "")
     (php-%setq-0 dest val)))

(define-php-macro %set-atom-fun (plc val)
  `(%transpiler-native ,(php-dollarize plc)
					   ,(php-assignment-operator val)
					   ,(php-dollarize val)))


;;;; VECTORS

(define-php-macro %make-lexical-array (&rest elements)
  `(%transpiler-native "new __l()" ""))

(define-php-macro %vec (v i)
  `(%transpiler-native ,(php-dollarize v) "->g(" ,(php-dollarize i) ")"))

(define-php-macro %set-vec (v i x)
  `(%transpiler-native ,*php-indent* ,(php-dollarize v) "->s(" ,(php-dollarize i) "," ,(php-%setq-value x) ")",*php-separator*))


;;;; NUMBERS

(defmacro define-php-binary (op replacement-op)
  (print-definition `(define-php-binary ,op ,replacement-op))
  (let tre *php-transpiler*
	(transpiler-add-inline-exception tre op)
	(transpiler-add-plain-arg-fun tre op)
	`(define-expander-macro ,(transpiler-codegen-expander tre) ,op (&rest args)
	   `(%transpiler-native ,,@(pad (filter #'php-dollarize args) ,replacement-op)))))

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
  (filter ^("[" ,(php-dollarize _) "]") indexes))

(defun php-literal-array-element (x)
  (list (compiled-function-name *transpiler* '%%key) " (" (php-dollarize x.) ") => " (php-dollarize .x.)))

(defun php-literal-array-elements (x)
  (pad (filter #'php-literal-array-element x) ","))

(define-php-macro %%%make-hash-table (&rest elements)
  `(%transpiler-native "Array (" ,@(php-literal-array-elements (group elements 2)) ")"))

(define-php-macro make-array (&rest elements)
  `(%transpiler-native "new __array ()" ""))

(define-php-macro aref (arr &rest indexes)
  `(href ,arr ,@indexes))

(define-php-macro =-aref (val arr &rest indexes)
  `(=-href ,val ,arr ,@indexes))

(define-php-macro php-aref (arr &rest indexes)
  `(%transpiler-native ,(php-dollarize arr) ,@(php-array-subscript indexes)))
 
(define-php-macro =-php-aref (val &rest x)
  `(%transpiler-native (php-aref ,@x)
                       ,(php-assignment-operator val)
                       ,(php-dollarize val)))


;;;; HASH TABLES

(defun php-array-indexes (x)
  (mapcan [list "[" (php-dollarize _) "]"] x))

(define-php-macro %%%href (h &rest k)
  `(%transpiler-native ,(php-dollarize h) ,@(php-array-indexes k)))

(define-php-macro %%%href-set (v h &rest k)
  `(%transpiler-native ,(php-dollarize h) ,@(php-array-indexes k) " = " ,(php-dollarize v)))

(define-php-macro href (h k)
  `(%transpiler-native "(is_a (" ,(php-dollarize h) ", '__l') || is_a (" ,(php-dollarize h) ", '__array')) ? "
                       ,(php-dollarize h) "->g(userfun_T37T37key (" ,(php-dollarize k) ")) : "
                       "(isset (" ,(php-dollarize h) "[userfun_T37T37key (" ,(php-dollarize k) ")]) ? "
                           ,(php-dollarize h) "[userfun_T37T37key (" ,(php-dollarize k) ")] : "
                           "NULL)"))

(define-php-macro =-href (v h k)
  `(%transpiler-native "(is_a (" ,(php-dollarize h) ", '__l') || is_a (" ,(php-dollarize h) ", '__array')) ? "
                       ,(php-dollarize h) "->s(userfun_T37T37key (" ,(php-dollarize k) ")," ,(php-dollarize v) ") : "
                       ,(php-dollarize h) "[userfun_T37T37key (" ,(php-dollarize k) ")] = " ,(php-dollarize v)))

(define-php-macro hremove (h key)
  `(%transpiler-native "null; unset ($" ,h "[" ,(php-dollarize key) "])"))

(define-php-macro make-hash-table (&rest ignored-args)
  `(make-array))

(define-php-macro %make-hash-table (&rest args)
  `(%transpiler-native "new __array (Array (" ,@(php-literal-array-elements (group args 2)) "))"))


;;;; OBJECTS

(define-php-macro %new (&rest x)
  `(%transpiler-native "new " ,x. ,@(php-argument-list .x)))

(define-php-macro delete-object (x)
  `(%transpiler-native "null; unset " ,x))

(define-php-macro %slot-value (x y)
  (? (cons? x)
	 (? (eq '%transpiler-native x.)
		`(%transpiler-native ,(php-dollarize x) "->" ,y)
		(error "%TRANSPILER-NATIVE expected"))
	 `(%transpiler-native "$" ,x "->" ,y)))

(define-php-macro %php-class-head (name)
  `(%transpiler-native "class " ,name "{"))

(define-php-macro %php-class-tail ()
  `(%transpiler-native "}" ""))

(define-php-macro %php-method-head ()
  `(%transpiler-native "public " ""))
