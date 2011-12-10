;;;;; tré - Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

;;;; GENERAL

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
  (pad (mapcar #'php-dollarize x) ","))

(defun php-argument-list (x)
  `("(" ,@(pad (mapcar #'php-dollarize x) ",") ")"))

(define-codegen-macro-definer define-php-macro *php-transpiler*)

(defmacro define-php-infix (name)
  `(define-transpiler-infix *php-transpiler* ,name))

;;;; SYMBOLS

(transpiler-translate-symbol *php-transpiler* nil "NULL")
(transpiler-translate-symbol *php-transpiler* t "TRUE")

;;;; CONTROL FLOW

(define-php-macro %%tag (tag)
  (? *php-goto?*
     `(%transpiler-native "_I_" ,tag ":" ,*php-newline*)
     `(%transpiler-native "case " ,tag ":" ,*php-newline*)))

(defun php-jump (tag)
  (? *php-goto?*
     `("goto _I_" ,tag ";")
     `(" $_I_=" ,tag "; break;")))

(define-php-macro %%vm-go (tag)
  (php-line (php-jump tag)))

(define-php-macro %%vm-go-nil (val tag)
  (php-line "if (!$" val "&&!is_string($" val ")&&!is_numeric($" val ")) { " (php-jump tag) "}"))

(define-php-macro %%vm-go-not-nil (val tag)
  (php-line "if (!(!$" val "&&!is_string($" val ")&&!is_numeric($" val "))) { " (php-jump tag) "}"))

;;;; FUNCTIONS

(defvar *php-codegen-funinfo* nil)

(defun codegen-php-function (name x)
  (with (args (argument-expand-names 'unnamed-c-function
		      		     	         (lambda-args x))
		 fi (get-lambda-funinfo x)
		 num-locals (length (funinfo-env fi)))
    `(,(code-char 10)
	  "function " ,(compiled-function-name *php-transpiler* name) ,@(php-argument-list args)
      "{" ,(code-char 10)
		 ,@(awhen (funinfo-globals fi)
             (php-line "global " (php-list !)))
         ,@(unless *php-goto?*
             (list "    $_I_=0; while (1) { switch ($_I_) { case 0:" *php-newline*))
         ,@(lambda-body x)
       	 ,(php-line "return $" '~%ret)
         ,@(unless *php-goto?*
             (list "    }}" *php-newline*))
      "}" ,*php-newline*)))

(define-php-macro function (name &optional (x 'only-name))
  (? (eq 'only-name x)
     `(%transpiler-native (%transpiler-string ,(compiled-function-name-string *php-transpiler* name)))
  	 (? (atom x)
		(error "codegen: arguments and body expected: ~A" x)
	  	(codegen-php-function name x))))

(define-php-macro %function-prologue (fi-sym) '(%transpiler-native ""))
(define-php-macro %function-epilogue (fi-sym) '(%transpiler-native ""))
(define-php-macro %function-return (fi-sym) '(%transpiler-native ""))

(defun php-codegen-argument-filter (x)
  (php-dollarize x))

;;;; FUNCTION REFERENCE

(define-php-macro %%funref (name fi-sym)
  (let fi (get-funinfo-by-sym fi-sym)
    (? (funinfo-ghost fi)
  	   `(%transpiler-native "new __funref("
             (%transpiler-string ,(transpiler-symbol-string *php-transpiler* name))
             ","
             ,(php-dollarize (funinfo-lexical (funinfo-parent fi)))
             ")")
	   name)))

;;;; ASSIGNMENT

(defun %transpiler-native-without-reference? (val)
  (and (%transpiler-native? val)
	   (string? .val.)
	   (string= "" .val.)))

(defun php-assignment-operator (val)
  (? (or (and (atom val)
		  	  (symbol? val))
		 (not (%transpiler-native-without-reference? val)))
     (? *php-by-reference?*
   	    "=&"
        "=")
  	 "="))
 
(defun php-%setq-value (val)
  (?
    (or (not val)
        (eq t val)
        (number? val)
        (string? val))
      (list val)
	(or (atom val)
	    (and (%transpiler-native? val)
		     (atom .val.)
		     (not ..val)))
      (list "$" val)
	(codegen-expr? val)
	  (list val)
    `((,val. ,@(parenthized-comma-separated-list (mapcar #'php-codegen-argument-filter .val))))))

(defun php-%setq-0 (dest val)
  `((%transpiler-native
	    ,*php-indent*
	    ,@(? dest
			 `(,@(when (atom dest)
				   (list "$"))
			   ,dest
			   ,(php-assignment-operator val))
	         '(""))
        ,@(php-%setq-value val)
        ,@(unless (and (not dest)
                       (%transpiler-native? val)
                       (not ..val))
            (list *php-separator*)))))

(define-php-macro %setq (dest val)
  (? (and (transpiler-obfuscated-nil? dest)
	      (atom val))
     '(%transpiler-native "")
     (php-%setq-0 dest val)))

(define-php-macro %set-atom-fun (plc val)
  `(%transpiler-native ,(php-dollarize plc)
					   ,(php-assignment-operator val)
					   ,(php-dollarize val)))

;;;; VARIABLES

(define-php-macro %make-lexical-array (&rest elements)
  `(%transpiler-native "new __l()" ""))

(define-php-macro %vec (v i)
  `(%transpiler-native ,(php-dollarize v) "->g(" ,(php-dollarize i) ")"))

(define-php-macro %set-vec (v i x)
  `(%transpiler-native ,*php-indent* ,(php-dollarize v) "->s(" ,(php-dollarize i) "," ,(php-%setq-value x) ")",*php-separator*))

;;;; NUMBERS, ARITHMETIC, COMPARISON

(defmacro define-php-binary (op replacement-op)
  (when *show-definitions*
	(print `(define-php-binary ,op ,replacement-op)))
  (let tre *php-transpiler*
	(transpiler-add-inline-exception tre op)
	(transpiler-add-plain-arg-fun tre op)
	`(define-expander-macro ,(transpiler-macro-expander tre) ,op (&rest args)
	   `(%transpiler-native ,,@(pad (mapcar #'php-dollarize args) ,replacement-op)))))

(mapcar-macro x
    '((%%%+ "+")
      (%%%- "-")
      (%%%* "*")
      (%%%/ "/")
      (%%%mod "%")
      (%%%= "==")
      (%%%< "<")
      (%%%> ">")
      (%%%<= "<=")
      (%%%>= ">=")
      (%%%eq "==="))
  `(define-php-binary ,@x))

(define-php-binary %%%string+ ".")

;;;; ARRAYS

(define-php-macro make-array (&rest elements)
  `(%transpiler-native "Array()" ""))

(defun php-array-subscript (indexes)
  (mapcar (fn `("[" ,(php-dollarize _) "]")) indexes))

(define-php-macro aref (arr &rest indexes)
  `(%transpiler-native ,(php-dollarize arr) ,@(php-array-subscript indexes)))

(define-php-macro %%usetf-aref (val &rest x)
  `(%transpiler-native (aref ,@x)
					   ,(php-assignment-operator val)
					   ,(php-dollarize val)))

;;;; HASH TABLE

(define-php-macro href (x y)
  `(%transpiler-native "(is_a (" ,(php-dollarize x) ", '__l') ? "
                       ,(php-dollarize x) "->g(" ,(php-dollarize y) ") : "
                       ,(php-dollarize x) "[" ,(php-dollarize y) "])"))

(define-php-macro %%usetf-href (v x y)
  `(%transpiler-native "(is_a (" ,(php-dollarize x) ", '__l') ? "
                       ,(php-dollarize x) "->s(" ,(php-dollarize y) "," ,(php-dollarize v) ") : "
                       ,(php-dollarize x) "[" ,(php-dollarize y) "] = " ,(php-dollarize v) ")"))

(define-php-macro hremove (h key)
  `(%transpiler-native "null; unset ($" ,h "[" ,(php-dollarize key) "])"))

(define-php-macro make-hash-table (&rest ignored-args)
  `(%transpiler-native "Array()" ""))

(defun php-literal-array-element (x)
  (list (php-dollarize x.) "=>" (php-dollarize .x.)))

(defun php-literal-array-elements (x)
  (pad (mapcar #'php-literal-array-element x) ","))

(define-php-macro %make-hash-table (&rest args)
  `(%transpiler-native "Array(" ,@(php-literal-array-elements (group args 2)) ")"))

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

;;;; MISCELLANEOUS

(define-php-macro %quote (x)
  (php-compiled-symbol x))

(define-php-macro %php-class-head (name)
  `(%transpiler-native "class " ,name "{"))

(define-php-macro %php-class-tail ()
  `(%transpiler-native "}" ""))

(define-php-macro %php-method-head ()
  `(%transpiler-native "public " ""))
