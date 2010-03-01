;;;;; Transpiler: TRE to PHP
;;;;; Copyright (c) 2008-2010 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code generation macros

(defun php-codegen-symbol-constructor (tr x)
    `(,(transpiler-symbol-string tr
	       (transpiler-obfuscate tr (compiled-function-name 'symbol)))
	       "(\"" ,(symbol-name x) "\", " ,(when (keywordp x) "true") ")"))

(defun php-dollarize (x)
  (if (and (atom x)
		   (symbolp x))
	  `("$" ,x)
	  x))

(defmacro define-php-macro (&rest x)
  `(progn
	 (transpiler-add-obfuscation-exceptions *php-transpiler* ',x.)
	 (define-transpiler-macro *php-transpiler* ,@x)))

(define-php-macro %%tag (tag)
  `(%transpiler-native 
	   ,(if (< *php-version* 503)
	        "case "
	        "")
       "_I_" ,tag ":" ,*php-separator*))

(define-php-macro vm-go (tag)
  (if (<= 503 *php-version*)
      `(, *php-indent* "goto _I_" ,tag ,*php-separator*)
      `(, *php-indent* "$_I_=" ,tag ,*php-separator* "continue" ,*php-separator*)))

(define-php-macro vm-go-nil (val tag)
  (if (<= 503 *php-version*)
      `(, *php-indent* "if (!$" ,val "&&$" ,val "!==0) goto _I_" ,tag ,*php-separator*)
      `(, *php-indent* "if (!$" ,val "&&$" ,val "!==0) { $_I_=" ,tag "; continue; }" ,*php-newline*)))

(define-php-macro %set-atom-fun (plc val)
  `(%transpiler-native "$" ,val ,*php-separator*
  					   ,(php-dollarize plc) "=&$" ,val ,*php-separator*))

(defvar *php-codegen-funinfo* nil)

(defun codegen-php-function (name x)
  (with (args (argument-expand-names 'unnamed-c-function
		      		     	         (lambda-args x))
		 fi (get-lambda-funinfo x)
		 num-locals (length (funinfo-env fi)))
    `(,(code-char 10)
	  "function &" ,(compiled-function-name name) "("
  	      ,@(transpiler-binary-expand ","
                (mapcar (fn `("&$" ,_))
					    args))
	      ")" ,(code-char 10)
      "{" ,(code-char 10)
	     ,@(when (< *php-version* 503)
			 `(,*php-indent* "$_I_=0; while (1) { switch ($_I_) { case 0:" ,*php-separator*))
		 ,@(when (< 0 num-locals)
		     `(,*php-indent* ,"$_local_array = Array ()" ,*php-separator*))
         ,@(lambda-body x)
	     ,@(when (< *php-version* 503)
			 `(,*php-indent* "}" ,*php-newline*))
       	 (,*php-indent* "return $" ,'~%ret ,*php-separator*)
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

(defun php-%setq-0 (dest val)
  `((%transpiler-native
	    ,*php-indent*
	    ,@(if (transpiler-not dest)
	          '("")
			  (if (and (atom val)
				  	   (symbolp val))
	              `("$" ,dest "=&")
	           	  `("$" ,dest "=")))
        ,@(if
			(atom val)
		      (list "$" val)
			(codegen-expr? val)
		      (list val)
		    `((,val. ,@(parenthized-comma-separated-list
					       (mapcar #'php-codegen-argument-filter .val)))))
    ,*php-separator*)))

(define-php-macro %setq (dest val)
  (if (and (transpiler-not dest)
		   (atom val))
  	  '(%transpiler-native "")
	  (php-%setq-0 dest val)))

(define-php-macro %var (name)
  '(%transpiler-native ""))

;;; TYPE PREDICATES

(defmacro define-php-infix (name)
  `(define-transpiler-infix *php-transpiler* ,name))

;;;; Symbol replacement definitions.

(transpiler-translate-symbol *php-transpiler* nil "NULL")
(transpiler-translate-symbol *php-transpiler* t "true")

;;; Numbers, arithmetic and comparison.

(defmacro define-php-binary (op repl-op)
  `(define-transpiler-binary *php-transpiler* ,op ,repl-op))

(define-php-binary %%%+ "+")
(define-php-binary %%%- "-")
(define-php-binary %%%= "==")
(define-php-binary %%%< "<")
(define-php-binary %%%> ">")
(define-php-binary %%%eq "===")

(define-php-macro make-array (&rest elements)
  `("Array (" ,@(transpiler-binary-expand ","
					(mapcar #'php-dollarize elements)) ")"))

(define-php-macro aref (arr &rest idx)
  `(%transpiler-native "$" ,arr
     ,@(mapcar (fn `("[" ,(php-dollarize _) "]"))
               idx)))

(define-php-macro href (arr &rest idx)
  `(%transpiler-native "$" ,arr
     ,@(mapcar (fn `("[" ,(php-dollarize _) "]"))
               idx)))

(define-php-macro %%usetf-aref (val &rest x)
  `(%transpiler-native "$" ,val ,*php-separator*
  					   (aref ,@x) "=&$" ,val))

(define-php-macro %%usetf-href (val &rest x)
  `(%transpiler-native "$" ,val ,*php-separator*
  					   (aref ,@x) "=&$" ,val))

(define-php-macro hremove (h key)
  `(%transpiler-native "unset $" ,h "[" ,(php-dollarize key) "]"))

;; Experimental for lambda-export.
(define-php-macro %vec (v i)
  `(%transpiler-native "$" ,v "[" ,(php-dollarize i) "]"))

;; Experimental for lambda-export.
(define-php-macro %set-vec (v i x)
  `(%transpiler-native "$" ,x ,*php-separator*
					   (aref ,v ,i) "=&$" ,x ,*php-separator*))

(define-php-macro make-hash-table (&rest args)
  (let pairs (group args 2)
    `("Array ("
          ,@(when args
	          (mapcan (fn (list (first _) "=>" (second _) ","))
			          (butlast pairs)))
          ,@(when args
		      (with (x (car (last pairs)))
		        (list x. "=>" (second x))))
         ")")))

(define-php-macro %new (&rest x)
  `(%transpiler-native "new "
				       ,x.
					   "(" ,@(transpiler-binary-expand "," (mapcar #'php-dollarize .x))
 					   ")"))

(define-php-macro delete-object (x)
  `(%transpiler-native "unset " ,x))

(defun php-stack (x)
  ($ '_I_S x))

(define-php-macro %stack (x)
  (if (transpiler-stack-locals? *php-transpiler*)
  	  `(%transpiler-native "_locals[" ,x "]")
      (php-stack x)))

(define-php-macro %quote (x)
  (php-compiled-symbol x))

(define-php-macro %slot-value (x y)
  (if (consp x)
	  (if (eq '%transpiler-native x.)
		  `(%transpiler-native "$" ,x "->" ,y)
		  (error "%TRANSPILER-NATIVE expected"))
	  `(%transpiler-native "$" ,x "->" ,y)))

(define-php-macro %%funref (name fi-sym)
  (let fi (get-lambda-funinfo-by-sym fi-sym)
    (if (funinfo-ghost fi)
	    (aif (funinfo-lexical (funinfo-parent fi))
  	  		 `(%funref ,name ,!)
			 (error "no lexical for ghost"))
	    name)))

(define-php-macro %unobfuscated-lookup-symbol (name pkg)
  `(,(transpiler-obfuscate-symbol *php-transpiler*
								  '%lookup-symbol)
	   (%transpiler-string
		   ,(symbol-name (transpiler-obfuscate-symbol
						 *php-transpiler* (make-symbol .name.))))
		   ,pkg))

(define-php-macro %assign-function-arguments (name args)
  `(%transpiler-native
	   "$" ,args ,*php-separator*
       "$" ,(transpiler-obfuscate-symbol *php-transpiler* '__tre-args)
	       "[\"" ,name "\"]=&$" ,args))
