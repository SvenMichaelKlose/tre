;;;;; TRE to C transpiler
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Code generation

;;;; TRANSPILER-MACRO EXPANDER

(defmacro define-c-macro (name args body)
  `(define-transpiler-macro *c-transpiler* ,name ,args ,body))

(define-c-macro function (x)
  (if (atom x)
	  x
      `("treptr " ,id "(" ,@(transpiler-binary-expand ","
				              (mapcar #'((x)
									       `("treptr " ,x))
								      (argument-expand 'unnamed-c-function
									      		       (lambda-args x) nil nil)))
					  ")" ,(code-char 10)
	      "{treptr " ,'~%ret ,*c-separator*
            ,@(lambda-body x)
          ("return " ,'~%ret ,*c-separator*)
	    "}}")))

(define-c-macro %setq (dest val)
  `((%transpiler-native ,dest) "=" ,val))

(define-c-macro %var (name)
  `(%transpiler-native "treptr " ,name))

;;; TYPE PREDICATES

(defmacro define-c-infix (name)
  `(define-transpiler-infix *c-transpiler* ,name))

(define-c-infix instanceof)

;;;; Symbol replacement definitions.

(transpiler-translate-symbol *c-transpiler* nil "null")
(transpiler-translate-symbol *c-transpiler* t "true")

;;; Numbers, arithmetic and comparison.

(defmacro define-c-binary (op repl-op)
  `(define-transpiler-binary *c-transpiler* ,op ,repl-op))

(define-c-binary + "+")
(define-c-binary - "-")
(define-c-binary / "/")
(define-c-binary * "*")
(define-c-binary = "==")
(define-c-binary < "<")
(define-c-binary > ">")
(define-c-binary >> ">>")
(define-c-binary << "<<")
(define-c-binary mod "%")
(define-c-binary logxor "^")
(define-c-binary eq "===")
(define-c-binary eql "==")
(define-c-binary bit-and "&")
(define-c-binary bit-or "|")

(define-c-macro instance? (name typestring)
  `(%transpiler-native ,name instanceof ,typestring))

(define-c-macro make-array (&rest elements)
  `(%transpiler-native "[" ,@(transpiler-binary-expand "," elements) "]"))

(define-c-macro aref (arr &rest idx)
  `(%transpiler-native ,arr
    ,@(mapcar #'(lambda (x)
                  `("[" ,x "]"))
              idx)))

(define-c-macro %%usetf-aref (val &rest x)
  `(%transpiler-native (aref ,@x) "=" ,val))

(define-c-macro make-string (&optional size)
  `(%transpiler-string ""))

(define-c-macro make-hash-table (&rest args)
  `("{"
    ,@(when args
	    (mapcan #'((x)
					 (list (first x) ":" (second x) ","))
			    (butlast (group args 2))))
    ,@(when args
		(with (x (car (last (group args 2))))
		  (list (first x) ":" (second x))))
   "}"))

(define-c-macro %new (&rest x)
  `(%transpiler-native "new "
				       ,(first x)
					   "(" ,@(transpiler-binary-expand "," (cdr x))
 					   ")"))

(define-c-macro vm-go (tag)
  `("goto " ,(transpiler-symbol-string *c-transpiler* tag)))

(define-c-macro vm-go-nil (val tag)
  `("if (" ,val " == treptr_nil) goto " ,(transpiler-symbol-string *c-transpiler* tag)))

(define-c-macro identity (x)
  x)

(defun c-stack (x)
  ($ '__S x))

(define-c-macro %stack (x)
  (c-stack x))

(define-c-macro %quote (x)
  `("T37quote(\"" ,(symbol-name x) "\")"))

(define-c-macro %set-atom-fun (plc val)
  `(%transpiler-native ,plc "=" ,val))

(define-c-macro %slot-value (x y)
  ($ x "." y))
