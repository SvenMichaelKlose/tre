;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code generation

;;;; TRANSPILER-MACRO EXPANDER

(defmacro define-c-macro (&rest x)
  `(define-transpiler-macro *c-transpiler* ,@x))

(defun c-transpiler-function-name (x)
  ($ 'compiled_ x))

(defun c-atomic-function (x)
  (c-transpiler-function-name (second x)))

(define-c-macro function (name x)
  (if (atom x)
	  (error "codegen: arguments and body expected: ~A" x)
	  (let args (argument-expand-names 'unnamed-c-function
			      		     	       (lambda-args x))
	    (push! (concat-stringtree
				   "extern treptr "
				   (transpiler-symbol-string *c-transpiler*
					   (c-transpiler-function-name name))
				   "("
				   (if args
				       (concat-stringtree
	  	    		       (transpiler-binary-expand ","
	               			   (mapcar (fn `("treptr " ,(transpiler-symbol-string *c-transpiler* _)))
				    				   args)))
					  "")
				   ");" (string (code-char 10)))
			   *c-declarations*)
        `(,(code-char 10)
		  "treptr " ,(c-transpiler-function-name name) "("
	  	    ,@(transpiler-binary-expand ","
	                (mapcar (fn `("treptr " ,_))
						    args))
		  ")" ,(code-char 10)
	      "{" ,(code-char 10)
		     ,*c-indent* "treptr " ,'~%ret ,*c-separator*
             ,@(lambda-body x)
          	 (,*c-indent* "return " ,'~%ret ,*c-separator*)
	      "}" ,*c-newline*))))

;; XXX same in js-transpiler
(define-c-macro %setq (dest val)
  `("    "
	(%transpiler-native ,dest) "="
        ,(if (and (consp val)
                  (not (stringp val.))
                  (not (in? val.
                            '%transpiler-string '%transpiler-native)))
             `(,val. ,@(parenthized-comma-separated-list .val))
             val)
    ,*c-separator*))

(define-c-macro %setq-atom (dest val)
  `(%transpiler-native ,*c-indent* "treatom_set_value (" ,(c-compiled-symbol dest) " ,"
		,val
		")" ,*c-separator*))

(define-c-macro %set-atom-fun (dest val)
  `(%transpiler-native ,*c-indent* "treatom_set_function (" ,dest " ,"
		,val
		")" ,*c-separator*))

(define-c-macro %var (name)
  `(%transpiler-native ,*c-indent* "treptr " ,name ,*c-separator*))

;;; TYPE PREDICATES

(defmacro define-c-infix (name)
  `(define-transpiler-infix *c-transpiler* ,name))

;(define-c-infix instanceof)

;;;; Symbol replacement definitions.

(transpiler-translate-symbol *c-transpiler* nil "treptr_nil")
(transpiler-translate-symbol *c-transpiler* t "treptr_t")

;;; Numbers, arithmetic and comparison.

(defmacro define-c-binary (op repl-op)
  `(define-transpiler-binary *c-transpiler* ,op ,repl-op))

(define-c-binary eq "=")

(define-c-macro vm-go (tag)
  `(,*c-indent* "goto l" ,(transpiler-symbol-string *c-transpiler* tag)
	,*c-separator*))

(define-c-macro vm-go-nil (val tag)
  `(,*c-indent* "if (" ,val " == treptr_nil)" ,(code-char 10)
	,*c-indent* ,*c-indent*
		"goto l" ,(transpiler-symbol-string *c-transpiler* tag)
	,*c-separator*))

(defun c-stack (x)
  ($ '__S x))

(define-c-macro %stack (x)
  (c-stack x))

(define-c-macro quote (x)
  (c-compiled-symbol x))

(define-c-macro %quote (x)
  (c-compiled-symbol x))

(define-c-macro %set-vec (vec index value)
  `("((treptr *)" ,vec ")[(unsigned long)" ,index "] = " ,value))

(define-c-macro %vec (vec index)
  `("((treptr *)" ,vec ")[(unsigned long)" ,index "]"))

(define-c-macro cons (a d)
  `("_trelist_get (" ,a "," ,d ")"))

(define-c-macro %funref (fun lex)
  `("_trelist_get (" ,(c-compiled-symbol '%%funref) ", "
		"_trelist_get (" ,(c-compiled-symbol fun) "," ,lex "))"))

;; Lexical scope
(define-c-macro make-array (size)
  `("trearray_get (_trelist_get (" ,(c-compiled-number size) ", treptr_nil))"))
