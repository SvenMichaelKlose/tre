;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Generating code

;;;; TRANSPILER-MACRO EXPANDER

(defmacro define-js-macro (&rest x)
  (when *show-definitions*
    (print `(define-js-macro ,x.)))
  `(progn
	 (transpiler-add-obfuscation-exceptions *js-transpiler* ',x.)
	 (define-transpiler-macro *js-transpiler* ,@x)))

(define-js-macro vm-go (tag)
  `(,*js-indent* "_I_=" ,tag "; continue" ,*js-separator*))

(define-js-macro vm-go-nil (val tag)
  `(,*js-indent* "if (!" ,val "&&" ,val "!==0) {_I_=" ,tag "; continue;}" ,*js-newline*))

(define-js-macro %set-atom-fun (plc val)
  `(%transpiler-native ,*js-indent* ,plc "=" ,val ,*js-separator*))

(defvar *js-codegen-funinfo* nil)

(define-js-macro function (x)
  (if (or (atom x)
		  (%stack? x))
	  x
      (with (args (argument-expand-names 'unnamed-js-function
										 (lambda-args x))
			 ret (transpiler-obfuscate *js-transpiler* '~%ret)
			 fi (get-lambda-funinfo x)
			 no-tags (when fi
					   (= 0 (funinfo-num-tags fi))))
		(setf *js-codegen-funinfo* fi)
        `("function (" ,@(transpiler-binary-expand
				            ","
						    args) ")"
	      ,(code-char 10)
	        "{"
			,*js-indent* "var " ,ret ,*js-separator*
			,@(when (transpiler-stack-locals? *js-transpiler*)
				`(,*js-indent* "var _locals = []" ,*js-separator*))
			,@(if no-tags
				  `(,@(lambda-body x)
                    (,*js-indent* "return " ,ret ,*js-separator*))
	        	  `(,*js-indent* "var _I_ = 0" ,*js-separator*
					,*js-indent* "while (1) {" ,*js-separator*
					,*js-indent* "switch (_I_) {case 0:" ,*js-separator*
                    ,@(lambda-body x)
                    (,*js-indent* "}" ,*js-separator*
					 ,*js-indent* "return " ,ret ,*js-separator*)
	        	     ,*js-indent* "}"))
			"}"))))

(define-js-macro %setq (dest val)
  `(,*js-indent* (%transpiler-native ,dest) "="
        ,(if (and (consp val)
	   			  (not (stringp val.))
	   			  (not (in? val.
							'%transpiler-string '%transpiler-native)))
			 `(,val. ,@(parenthized-comma-separated-list .val))
			 val)
    ,*js-separator*))

(define-js-macro %var (name)
  `(%transpiler-native ,*js-indent* "var " ,name ,*js-separator*))

;;; TYPE PREDICATES

(defmacro define-js-infix (name)
  `(define-transpiler-infix *js-transpiler* ,name))

(define-js-infix instanceof)

;;;; Symbol replacement definitions.

(transpiler-translate-symbol *js-transpiler* nil "null")
(transpiler-translate-symbol *js-transpiler* t "true")

;;; Numbers, arithmetic and comparison.

(defmacro define-js-binary (op repl-op)
  `(define-transpiler-binary *js-transpiler* ,op ,repl-op))

(define-js-binary %%%+ "+")
(define-js-binary %%%- "-")
(define-js-binary %%%= "==")
(define-js-binary %%%< "<")
(define-js-binary %%%> ">")
(define-js-binary %%%<= "<=")
(define-js-binary %%%>= ">=")
(define-js-binary %%%eq "===")

(define-js-macro make-array (&rest elements)
  `(%transpiler-native "[" ,@(transpiler-binary-expand "," elements) "]"))

(define-js-macro aref (arr &rest idx)
  `(%transpiler-native ,arr
     ,@(mapcar (fn `("[" ,_ "]"))
               idx)))

(define-js-macro href (arr &rest idx)
  `(%transpiler-native ,arr
     ,@(mapcar (fn `("[" ,_ "]"))
               idx)))

(define-js-macro %%usetf-aref (val &rest x)
  `(%transpiler-native (aref ,@x) "=" ,val))

(define-js-macro %%usetf-href (val &rest x)
  `(%transpiler-native (aref ,@x) "=" ,val))

(define-js-macro hremove (h key)
  `(%transpiler-native "delete " ,h "[" ,key "]"))

;; Experimental for lambda-export.
(define-js-macro %vec (v i)
  `(%transpiler-native ,v "[" ,i "]"))

;; Experimental for lambda-export.
(define-js-macro %set-vec (v i x)
  `(%transpiler-native (aref ,v ,i) "=" ,x ,*js-separator*))

(define-js-macro make-hash-table (&rest args)
  (let pairs (group args 2)
    `("{"
      ,@(when args
	      (mapcan (fn (list (first _) ":" (second _) ","))
			      (butlast pairs)))
      ,@(when args
		  (with (x (car (last pairs)))
		    (list x. ":" (second x))))
     "}")))

(define-js-macro %new (&rest x)
  `(%transpiler-native "new "
				       ,x.
					   "(" ,@(transpiler-binary-expand "," .x)
 					   ")"))

(define-js-macro delete-object (x)
  `(%transpiler-native "delete " ,x))

(defun js-stack (x)
  ($ '_I_S x))

(define-js-macro %stack (x)
  (if (transpiler-stack-locals? *js-transpiler*)
  	  `(%transpiler-native "_locals[" ,x "]")
      (js-stack x)))

(defun js-codegen-symbol-constructor (tr x)
  `(,(transpiler-symbol-string tr (transpiler-obfuscate tr 'symbol))
        "(\"" ,(symbol-name x) "\", " ,(when (keywordp x) "true") ")"))

(define-js-macro %quote (x)
  (if (not (string= "" (symbol-name x)))
	  (js-codegen-symbol-constructor *js-transpiler* x)
	  x))

(define-js-macro %slot-value (x y)
  (if (consp x)
	  (if (eq '%transpiler-native x.)
		  `(%transpiler-native ,x "." ,y)
		  (progn
			(print x)
			(error "%TRANSPILER-NATIVE expected")))
  	  ($ x "." y)))

(define-js-macro %js-typeof (x)
  `(%transpiler-native "typeof " ,x))

(define-js-macro %%funref (name fi-sym)
  (let fi (get-lambda-funinfo-by-sym fi-sym)
    (if (funinfo-ghost fi)
	    (aif (funinfo-lexical (funinfo-parent fi))
  	  		 `(%funref ,name ,!)
			 (error "no lexical for ghost"))
	    name)))

(define-js-macro %unobfuscated-lookup-symbol (name pkg)
  `(,(transpiler-obfuscate-symbol *js-transpiler*
								  'symbol)
	   (%transpiler-string
		   ,(symbol-name (transpiler-obfuscate-symbol
						 *js-transpiler* (make-symbol .name.))))
		   ,pkg))

(define-js-macro %assign-function-arguments (name args)
  `(%transpiler-native
	   ,name "." ,(transpiler-obfuscate-symbol *js-transpiler* 'tre-args) "=" ,args))
