;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code generation

;;;; TRANSPILER-MACRO EXPANDER

(defmacro define-c-macro (name args body)
  `(define-transpiler-macro *c-transpiler* ,name ,args ,body))

(define-c-macro function (name x)
  (if (atom x)
	  x
      `("treptr "
		,name "(" ,@(transpiler-binary-expand ","
	                (mapcar (fn `("treptr " ,_))
						    (argument-expand 'unnamed-c-function
							      		     (lambda-args x) nil nil)))
		")" ,(code-char 10)
	    "{treptr " ,'~%ret ,*c-separator*
           ,@(lambda-body x)
        ("return " ,'~%ret ,*c-separator*)
	    "}")))

(define-c-macro %setq (dest val)
  `((%transpiler-native ,dest) "=" ,val))

(define-c-macro %var (name)
  `(%transpiler-native "treptr " ,name))

;;; TYPE PREDICATES

(defmacro define-c-infix (name)
  `(define-transpiler-infix *c-transpiler* ,name))

;(define-c-infix instanceof)

;;;; Symbol replacement definitions.

;(transpiler-translate-symbol *c-transpiler* nil "null")
;(transpiler-translate-symbol *c-transpiler* t "true")

;;; Numbers, arithmetic and comparison.

(defmacro define-c-binary (op repl-op)
  `(define-transpiler-binary *c-transpiler* ,op ,repl-op))

(define-c-binary eq "=")

(define-c-macro vm-go (tag)
  `("goto l" ,(transpiler-symbol-string *c-transpiler* tag)))

(define-c-macro vm-go-nil (val tag)
  `("if (" ,val " == treptr_nil) goto l" ,(transpiler-symbol-string *c-transpiler* tag)))

(defun c-stack (x)
  ($ '__S x))

(define-c-macro %stack (x)
  (c-stack x))

(define-c-macro %quote (x)
  `("T37quote(\"" ,(symbol-name x) "\")"))
