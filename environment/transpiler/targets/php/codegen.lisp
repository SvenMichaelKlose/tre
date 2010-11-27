;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>

;;;; GENERAL

(defun php-line (&rest x)
  `(,*php-indent* ,@x ,*php-separator*))

(defun php-codegen-symbol-constructor (tr x)
    `(,(transpiler-symbol-string tr
	       (transpiler-obfuscate tr (compiled-function-name 'symbol)))
	       "(\"" ,(symbol-name x) "\", " ,(when (keywordp x) "true") ")"))

(defun php-dollarize (x)
  (if (and (atom x)
		   (symbolp x))
	  `("$" ,x)
	  x))

(define-codegen-macro-definer define-php-macro *php-transpiler*)

(defmacro define-php-infix (name)
  `(define-transpiler-infix *php-transpiler* ,name))

;;;; SYMBOLS

(transpiler-translate-symbol *php-transpiler* nil "NULL")
(transpiler-translate-symbol *php-transpiler* t "true")

(define-php-macro %unobfuscated-lookup-symbol (name pkg)
  `(,(transpiler-obfuscate-symbol *php-transpiler*
								  '%lookup-symbol)
	   (%transpiler-string
		   ,(symbol-name (transpiler-obfuscate-symbol
						 *php-transpiler* (make-symbol .name.))))
		   ,pkg))

;;;; CONTROL FLOW

(define-php-macro %%tag (tag)
  `(%transpiler-native 
	   ,@(if (< *php-version* 503)
	         `("case " ,tag ":")
             `("_I_" ,tag ":"))
       ,*php-newline*))

(define-php-macro vm-go (tag)
  (if (< 503 *php-version*)
      (php-line "$_I_=" tag *php-separator* "continue")
	  (php-line "goto _I_" tag)))

(define-php-macro vm-go-nil (val tag)
  (if (< 503 *php-version*)
      (php-line "if (!$" val "&&$" val "!=0) { $_I_=" tag "; continue; }")
      (php-line "if (!$" val "&&$" val "!=0) goto _I_" tag)))

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
		 ,(php-line "global "
					(comma-separated-list (mapcar #'php-dollarize
                                                  (cons "$NULL" (funinfo-globals fi)))))
	     ,@(when (< *php-version* 503)
			 (php-line "$_I_=0; while (1) { switch ($_I_) { case 0:"))
         ,@(lambda-body x)
	     ,@(when (< *php-version* 503)
			 `(,*php-indent* "}" ,*php-newline*))
       	 ,(php-line "return $" '~%ret)
	     ,@(when (< *php-version* 503)
			 `("}" ,*php-newline*))
      "}" ,*php-newline*)))

(define-php-macro function (name &optional (x 'only-name))
  (if (eq 'only-name x)
      `("symbol_function (" ,name ")")
  	  (if (atom x)
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
    (if (funinfo-ghost fi)
  	  	`(%funref (%transpiler-string ,(symbol-name name)) ,(funinfo-lexical (funinfo-parent fi)))
	    name)))

;;;; ASSIGNMENT

(defun php-class-fun (x)
  (and (consp x)
	   (if
		 (eq x. 'tresymbol_compiled_%class-head)
		   `("class " ,.x. " { " ,*php-newline*)
		 (eq x. 'tresymbol_compiled_%class-tail)
		   `("}" ,*php-newline*)
		 (eq x. 'tresymbol_compiled_%separator)
		   `("," ,*php-newline*))))

(defun php-assignment-operator (val)
  (if (or (and (atom val)
		  	   (symbolp val))
		  (and (consp val)
			   (or (not (%transpiler-native? val))
			   	   (and (stringp .val.)
						(not (string= "" .val.))))))
   	  "=&"
  	  "="))
 
(defun php-%setq-0 (dest val)
  `((%transpiler-native
	    ,*php-indent*
	    ,@(if (transpiler-obfuscated-nil? dest)
	          '("")
			  `(,@(when (atom dest)
				    (list "$"))
				,dest
			    ,(php-assignment-operator val)))
        ,@(if
			(or (atom val)
				(and (%transpiler-native? val)
					 (atom .val.)
					 (not ..val)))
		      (list "$" val)
			(codegen-expr? val)
		      (list val)
		    `((,val. ,@(parenthized-comma-separated-list
					       (mapcar #'php-codegen-argument-filter .val)))))
    ,*php-separator*)))

(define-php-macro %setq (dest val)
  (or (php-class-fun val)
      (if (and (transpiler-obfuscated-nil? dest)
		       (atom val))
  	      '(%transpiler-native "")
	      (php-%setq-0 dest val))))

(define-php-macro %set-atom-fun (plc val)
  `(%transpiler-native "$" ,val ,*php-separator*
  					   ,(php-dollarize plc)
					   ,(php-assignment-operator val)
					   "$" ,val ,*php-separator*))

;;;; VARIABLES

;; Experimental for lambda-export.
(define-php-macro %vec (v i)
  `(%transpiler-native "$" ,v "[" ,(php-dollarize i) "]"))

;; Experimental for lambda-export.
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
	  (transpiler-add-obfuscation-exceptions tre op replacement-op)
	  (transpiler-add-inline-exception tre op)
	  (transpiler-add-plain-arg-fun tre op)
	  `(define-expander-macro
	       ,(transpiler-macro-expander tre)
	       ,op
	       (&rest args)
	     `(%transpiler-native
			,,@(transpiler-binary-expand ,replacement-op
				   (mapcar #'php-dollarize args))))))

(define-php-binary %%%+ "+")
(define-php-binary %%%- "-")
(define-php-binary %%%= "==")
(define-php-binary %%%< "<")
(define-php-binary %%%> ">")
(define-php-binary %%%eq "===")

;;;; ARRAYS

(define-php-macro make-array (&rest elements)
  `(%transpiler-native "" ; Tell %SETQ not to make reference assignment.
					   "Array ()"))

(define-php-macro aref (arr &rest idx)
  `(%transpiler-native "$" ,arr
     ,@(mapcar (fn `("[" ,(php-dollarize _) "]"))
               idx)))

(define-php-macro %%usetf-aref (val &rest x)
  `(%transpiler-native "$" ,val ,*php-separator*
  					   (aref ,@x)
					   ,(php-assignment-operator val)
					   "$" ,val))

;;;; HASH TABLE

(define-php-macro href (arr &rest idx)
  `(%transpiler-native "$" ,arr
     ,@(mapcar (fn `("[" ,(php-dollarize _) "]"))
               idx)))

(define-php-macro %%usetf-href (val &rest x)
  `(%transpiler-native "$" ,val ,*php-separator*
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
  (if (consp x)
	  (if (eq '%transpiler-native x.)
		  `(%transpiler-native ,(php-dollarize x) "->" ,y)
		  (error "%TRANSPILER-NATIVE expected"))
	  `(%transpiler-native "$" ,x "->" ,y)))

;;;; MISCELLANEOUS

(define-php-macro %quote (x)
  (php-compiled-symbol x))
