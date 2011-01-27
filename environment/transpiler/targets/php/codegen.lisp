;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2011 Sven Klose <pixel@copei.de>

;;;; GENERAL

(defun php-line (&rest x)
  `(,*php-indent* ,@x ,*php-separator*))

(defun php-dollarize (x)
  (? (and (atom x)
		  (symbolp x))
     (?
       (not x)
         "__w(NULL)"
       (eq t x)
         "__w(TRUE)"
	   `("$" ,x))
	 x))

(define-codegen-macro-definer define-php-macro *php-transpiler*)

(defmacro define-php-infix (name)
  `("__w (" (define-transpiler-infix *php-transpiler* ,name) ")"))

;;;; SYMBOLS

(transpiler-translate-symbol *php-transpiler* nil "__w(NULL)")
(transpiler-translate-symbol *php-transpiler* t "__w(TRUE)")

;;;; CONTROL FLOW

(define-php-macro %%tag (tag)
  `(%transpiler-native "_I_" ,tag ":" ,*php-newline*))

(define-php-macro %%vm-go (tag)
  (php-line "goto _I_" tag))

(define-php-macro %%vm-go-nil (val tag)
  (php-line "if (!$" val "&&!is_string($" val ")&&!is_numeric($" val ")) goto _I_" tag))

;;;; FUNCTIONS

(defvar *php-codegen-funinfo* nil)

(defun codegen-php-function (name x)
  (with (args (argument-expand-names 'unnamed-c-function
		      		     	         (lambda-args x))
		 fi (get-lambda-funinfo x)
		 num-locals (length (funinfo-env fi)))
    `(,(code-char 10)
	  "function &" ,(compiled-function-name name) "("
  	      ,@(transpiler-binary-expand ","
                (mapcar (fn `("&$" ,_)) args))
	      ")" ,(code-char 10)
      "{" ,(code-char 10)
		 ,@(awhen (funinfo-globals fi)
             (php-line "global " (comma-separated-list (mapcar #'php-dollarize !))))
         ,@(lambda-body x)
       	 ,(php-line "return $" '~%ret)
      "}" ,*php-newline*)))

(define-php-macro function (name &optional (x 'only-name))
  (? (eq 'only-name x)
     `(%transpiler-native "__w ("
          (%transpiler-string
              ,(transpiler-symbol-string *php-transpiler*
                                         (transpiler-obfuscate *php-transpiler* (compiled-function-name name))))
          ")")
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
  (let fi (get-lambda-funinfo-by-sym fi-sym)
    (? (funinfo-ghost fi)
  	   `("new __funref ("
             (%transpiler-string ,(transpiler-symbol-string *php-transpiler* name))
             "," ,(php-dollarize (funinfo-lexical (funinfo-parent fi)))
             ")")
	   name)))

;;;; ASSIGNMENT

(defun %transpiler-native-without-reference? (val)
  (and (%transpiler-native? val)
	   (string? .val.)
	   (string= "" .val.)))

(defun php-assignment-operator (val)
  (? (or (and (atom val)
		  	  (symbolp val))
		 (not (%transpiler-native-without-reference? val)))
   	 "=&"
  	 "="))
 
(defun php-%setq-0 (dest val)
  `((%transpiler-native
	    ,*php-indent*
	    ,@(? (transpiler-obfuscated-nil? dest)
	         '("")
			 `(,@(when (atom dest)
				   (list "$"))
			   ,dest
			   ,(php-assignment-operator val)))
        ,@(?
            (or (not val)
                (eq t val))
              (list val)
			(or (atom val)
				(and (%transpiler-native? val)
					 (atom .val.)
					 (not ..val)))
		      (list "$" val)
			(codegen-expr? val)
		      (list val)
		    `((,val. ,@(parenthized-comma-separated-list
					       (mapcar #'php-codegen-argument-filter .val)))))
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
  `(%transpiler-native "$" ,val ,*php-separator*
  					   ,(php-dollarize plc)
					   ,(php-assignment-operator val)
					   ,(php-dollarize val) ,*php-separator*))

;;;; VARIABLES

(define-php-macro %vec (v i)
  `(%transpiler-native "$" ,v "[" ,(php-dollarize i) "]"))

(define-php-macro %set-vec (v i x)
  `(%transpiler-native "$" ,x ,*php-separator*
					   (aref ,v ,i)
					   ,(php-assignment-operator x)
					   "$" ,x ,*php-separator*))

;;;; NUMBERS, ARITHMETIC, COMPARISON

(defmacro define-php-binary (op replacement-op)
    (when *show-definitions*
	  (print `(define-php-binary ,op ,replacement-op)))
	(let tre *php-transpiler*
	  (transpiler-add-inline-exception tre op)
	  (transpiler-add-plain-arg-fun tre op)
	  `(define-expander-macro
	       ,(transpiler-macro-expander tre)
	       ,op
	       (&rest args)
	     `(%transpiler-native
            "__w ("
			,,@(transpiler-binary-expand ,replacement-op
				   (mapcar #'php-dollarize args))
            ")"))))

(mapcar-macro x
    '((%%%+ "+")
      (%%%- "-")
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
  `(%transpiler-native "" ; Tell %SETQ not to make reference assignment.
					   "Array ()"))

(define-php-macro aref (arr &rest idx)
  `(%transpiler-native ,(php-dollarize arr)
     ,@(mapcar (fn `("[" ,(php-dollarize _) "]"))
               idx)))

(define-php-macro %%usetf-aref (val &rest x)
  `(%transpiler-native ,(php-dollarize val) ,*php-separator*
  					   (aref ,@x)
					   ,(php-assignment-operator val)
					   ,(php-dollarize val)))

;;;; HASH TABLE

(define-php-macro href (arr &rest idx)
  `(%transpiler-native ,(php-dollarize arr)
     ,@(mapcar (fn `("[" ,(php-dollarize _) "]"))
               idx)))

(define-php-macro %%usetf-href (val &rest x)
  `(%transpiler-native ,(php-dollarize val) ,*php-separator*
  					   (aref ,@x)
					   ,(php-assignment-operator val)
					   "$" ,val))

(define-php-macro hremove (h key)
  `(%transpiler-native "unset $" ,h "[" ,(php-dollarize key) "]"))

(define-php-macro make-hash-table (&rest args)
  (let pairs (group args 2)
    `(%transpiler-native
	   "" ; Tell %SETQ to make no reference assignment.
	   "Array ("
           ,@(when args
	           (mapcan (fn (list (first _) "=>" (second _) ","))
			           (butlast pairs)))
           ,@(when args
		       (with (x (car (last pairs)))
		         (list x. "=>" (second x))))
          ")")))

;;;; OBJECTS

(define-php-macro %new (&rest x)
  `(%transpiler-native "new "
				       ,x.
					   "(" ,@(transpiler-binary-expand ","
								 (mapcar #'php-dollarize .x))
 					   ")"))

(define-php-macro delete-object (x)
  `(%transpiler-native "unset " ,x))

(define-php-macro %slot-value (x y)
  (? (consp x)
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
