;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Generating code

;;;; TRANSPILER-MACRO EXPANDER

(defmacro define-php-macro (&rest x)
  `(progn
	 (transpiler-add-obfuscation-exceptions *php-transpiler* ',x.)
	 (define-transpiler-macro *php-transpiler* ,@x)))

(define-php-macro vm-go (tag)
  `("goto _I_" ,tag ,*php-separator*))

(define-php-macro vm-go-nil (val tag)
  `("if (!" ,val "&&" ,val "!==0) goto _I_" ,tag ,*php-separator* ,*php-newline*))

(define-php-macro %set-atom-fun (plc val)
  `(%transpiler-native ,plc "=" ,val ,*php-separator*))

(defvar *php-codegen-funinfo* nil)

(defun codegen-php-function (name x)
  (with (args (argument-expand-names 'unnamed-c-function
		      		     	         (lambda-args x))
		 fi (get-lambda-funinfo x)
		 num-locals (length (funinfo-env fi)))
    `(,(code-char 10)
	  "function " ,(c-transpiler-function-name name) "("
  	      ,@(transpiler-binary-expand ","
                (mapcar (fn `("&$" ,_))
					    args))
	      ")" ,(code-char 10)
      "{" ,(code-char 10)
		 ,@(when (< 0 num-locals)
		     `(,*c-indent* ,"$_local_array = Array" ,*c-separator*))
         ,@(lambda-body x)
       	 (,*c-indent* "return $" ,'~%ret ,*c-separator*)
      "}" ,*c-newline*)))

(define-php-macro function (name &optional (x 'only-name))
  (if (eq 'only-name x)
      `("symbol_function (" ,name ")")
  	  (if (atom x)
		  (error "codegen: arguments and body expected: ~A" x)
	  	  (codegen-php-function name x))))

(define-php-macro %setq (dest val)
  `((%transpiler-native "$" ,dest) "&="
        ,(if
		   (and (consp val)
	   			(not (stringp val.))
	   			(not (in? val.
						  '%transpiler-string '%transpiler-native)))
			 `(,val. ,@(parenthized-comma-separated-list
						   (mapcar (fn if (and _ (symbolp _))
									   	  ($ '$ _)
										  _)
								    .val)))
		   (and val
				(atom val)
				(symbolp val))
			   ($ '$ val)
		   val)
    ,*php-separator*))

(define-php-macro %var (name)
  *php-separator*)

;;; TYPE PREDICATES

(defmacro define-php-infix (name)
  `(define-transpiler-infix *php-transpiler* ,name))

(define-php-infix instanceof)

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
  `(%transpiler-native "[" ,@(transpiler-binary-expand "," elements) "]"))

(define-php-macro aref (arr &rest idx)
  `(%transpiler-native ,arr
     ,@(mapcar (fn `("[" ,_ "]"))
               idx)))

(define-php-macro href (arr &rest idx)
  `(%transpiler-native ,arr
     ,@(mapcar (fn `("[" ,_ "]"))
               idx)))

(define-php-macro %%usetf-aref (val &rest x)
  `(%transpiler-native (aref ,@x) "=" ,val))

(define-php-macro %%usetf-href (val &rest x)
  `(%transpiler-native (aref ,@x) "=" ,val))

(define-php-macro hremove (h key)
  `(%transpiler-native "unset " ,h "[" ,key "]"))

;; Experimental for lambda-export.
(define-php-macro %vec (v i)
  `(%transpiler-native ,v "[" ,i "]"))

;; Experimental for lambda-export.
(define-php-macro %set-vec (v i x)
  `(%transpiler-native (aref ,v ,i) "=" ,x ,*php-separator*))

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
					   "(" ,@(transpiler-binary-expand "," .x)
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
  (if (not (string= "" (symbol-name x)))
	  (codegen-symbol-constructor *php-transpiler* x)
	  x))

(define-php-macro %slot-value (x y)
  (if (consp x)
	  (if (eq '%transpiler-native x.)
		  `(%transpiler-native ,x "." ,y)
		  (error "%TRANSPILER-NATIVE expected"))
  	  ($ x "." y)))

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
