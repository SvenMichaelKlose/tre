;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code generation

;;;; TRANSPILER-MACRO EXPANDER

(defmacro define-c-macro (&rest x)
  `(define-transpiler-macro *c-transpiler* ,@x))

(defun c-transpiler-function-name (name)
  name)

(define-c-macro function (name x)
  (if (atom x)
	  x
	  (let args (argument-expand-names 'unnamed-c-function
			      		     	       (lambda-args x))
	    (push! (transpiler-concat-string-tree
				   "extern treptr "
				   (transpiler-symbol-string *c-transpiler*
					   (c-transpiler-function-name name))
				   "("
				   (if args
				       (transpiler-concat-string-tree
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
		     "   treptr " ,'~%ret ,*c-separator*
             ,@(lambda-body x)
          ("    return " ,'~%ret ,*c-separator*)
	      "}"))))

(define-c-macro %setq (dest val)
  `((%transpiler-native "    " ,dest) "=" ,val))

(define-c-macro %setq-atom (dest val)
  `(%transpiler-native "    treatom_sym_set_value (" ,dest " ,"
		,val
		")"))

(define-c-macro %var (name)
  `(%transpiler-native "    treptr " ,name))

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
  `("    goto l" ,(transpiler-symbol-string *c-transpiler* tag)))

(define-c-macro vm-go-nil (val tag)
  `("    if (" ,val " == treptr_nil)" ,(code-char 10)
	"        goto l" ,(transpiler-symbol-string *c-transpiler* tag)))

(defun c-stack (x)
  ($ '__S x))

(define-c-macro %stack (x)
  (c-stack x))

(define-c-macro %quote (x)
  (c-compiled-symbol x))

(define-c-macro %set-vec (vec index value)
  `("((treptr *)" ,vec ")[(unsigned long)" ,index "] = " ,value))

(define-c-macro %vec (vec index)
  `("((treptr *)" ,vec ")[(unsigned long)" ,index "]"))
