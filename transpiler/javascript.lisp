;;;;; Transpiler: TRE to JavaScript
;;;;;
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun make-javascript-transpiler ()
  (create-transpiler
	:preprocessor 'js-preprocessor
	:rename-prefix "_jst%"
	:std-macro-renamer 'js-std-rename
	:std-macro-expander 'js-renamed-std
	:macro-expander 'javascript
	:separator (format nil ";~%")
	:function-args nil))

(defvar *js-transpiler* (make-javascript-transpiler))
(defvar *js-separator* (transpiler-separator *js-transpiler*))

;;;; PREPROCESSING MACROS

(defmacro define-js-preprocessor (name args body)
  `(define-transpiler-preprocessor *js-transpiler* ,name ,args ,body))

(define-js-preprocessor defun (args &rest body)
  (block nil
	(acons! name args (transpiler-function-args *js-transpiler*))))

;;;; STANDARD MACRO RENAMING

(defmacro define-js-rename (name)
  `(define-transpiler-rename *js-transpiler* ,name))

;;;; EXPANSION OF RENAMED STANDARD MACROS

(defmacro define-js-std-macro (name args body)
  `(define-transpiler-std-macro *js-transpiler* ,name ,args ,body))

;;;; TRANSPILER-MACRO EXPANDER

(defmacro define-js-macro (name args body)
  `(define-transpiler-macro *js-transpiler* ,name ,args ,body))

;;;; TOPLEVEL

(defun js-transpile (x)
  (transpiler-transpile *js-transpiler* x))

;;;; EXPANSION OF ALTERNATE STANDARD MACROS

(define-js-std-macro defun (name args &rest body)
  `(%setq ,name
		  #'(lambda ,args
    		  ,@body)))

(define-js-macro function (x)
  `("function ",@(transpiler-binary-expand
				   ","
				   (argument-expand (lambda-args x) nil nil))
	,(code-char 10)
	"{"
	(~%ret "=" nil) ,*js-separator*
    ,@(lambda-body x)
    ("return " ~%ret ,*js-separator*)
	"}"))

(define-js-macro defvar (name val)
  `("var " ,name " = " ,val))

(define-js-macro %setq (dest val)
  `(,dest "=" ,val))

;;; TYPE PREDICATES

(defmacro def-js-type-predicate (name typestring)
  `(define-js-macro ,name (x)
     `(== (instanceof ,,x ,typestring))))

(def-js-type-predicate symbolp "symbol")
(def-js-type-predicate consp "cons")
(def-js-type-predicate numberp "Number")
(def-js-type-predicate arrayp "Array")
(def-js-type-predicate stringp "String")
(def-js-type-predicate functionp "Function")

(defmacro define-js-infix (name)
  `(define-transpiler-infix *js-transpiler* ,name))

(define-js-infix instanceof)
(define-js-infix typeof)

;;;; Symbol replacement definitions.

;(transpiler-rename-symbol 'nil  "null")
;(transpiler-rename-symbol 't    "true")

;;; Numbers, arithmetic and comparison.

(defmacro define-js-binary (op repl-op)
  `(define-transpiler-binary *js-transpiler* ,op ,repl-op))

(define-js-binary + "+")
(define-js-binary - "-")
(define-js-binary / "/")
(define-js-binary = "==")
(define-js-binary < "<")
(define-js-binary > ">")
(define-js-binary mod "%")
(define-js-binary logxor "^")
(define-js-binary not "!")
(define-js-binary eq "===")
(define-js-binary eql "==")

(define-js-macro make-array ()
  "[]")
(define-js-macro aref (arr &rest idx)
  `(%transpiler-native ,arr
    ,@(mapcar #'(lambda (x)
                  `("[" ,x "]"))
              idx)))

(define-js-macro %%usetf-aref (val &rest x)
  `((aref ,@x) "=" ,val))

(define-js-macro make-string (&optional size)
  `(%transpiler-string ""))

(define-js-macro make-hash-table ()
  "{}")

(define-js-macro vm-go (tag)
  `("goto " ,tag))

(define-js-macro vm-go-nil (val tag)
  `("if (!" ,val ") goto " ,tag))

(define-js-macro identity (x)
  x)

(defun js-stack (x)
  ($ '__S x))

(define-js-macro %stack (x)
  (js-stack x))

(define-js-macro %set-atom-fun (plc val)
  `(%setq ,plc ,val))

;    "ELT", "%SET-ELT", "LENGTH",
;    "CODE-CHAR", "INTEGER",
;    "CHARACTERP",
;    "STRING-CONCAT", "STRING"

;;;; This are the low-level transpiler definitions of
;;;; basic functions to simulate basic data types.

(defun js-base ()
  (map #'((x)
			(print (js-transpile (list x))))
'(
; IDENTITY - use native

;;; Symbols
;;;
;;; These are string encapsulated in an object to make
;;; them a distinguished type.

(defvar *symbols* (make-hash-table))

(defun symbol (x)
  (setf this.n x
        this.v nil
        this.f nil)
  this)

(defun symbol-name (x)
  x.n)

(defun symbol-value (x)
  x.v)

(defun symbol-function (x)
  x.f)

(defun make-symbol (x)
  (symbol x))

;;; CONSES
;;;
;;; Conses are objects containing a pair.

(defun cons (a d)
  (setf this._car a)
  (setf this._cdr d))

(defun car (x)
  x._car)

(defun cdr (x)
  x._cdr)

(defun rplaca (x val)
  (setf x._car val))

(defun rplacd (x val)
  (setf x._car val))

(defun list ()
  (labels ((rec (x)
             (unless (= x.length 0)
               (with (a (aref x 0))
				 (x.shift) ; pop off first element from array.
                 (cons a (rec x))))))
    (rec arguments)))

(defun apply ()
  (when (= 0 arguments.length)
    (alert "apply requires a function arguments"))
  (with (fun (aref arguments 0)
		 args (make-string)
		 last-arg (aref arguments (1- arguments.length))
		 last-args (make-array))
    (do ((i 1 (1+ i)))
		((= i (1- arguments.length)))
      (setf args (+ args "arguments[" i "]" (if (< i (1- arguments.length))
											    ","
											    ""))))
    (do ((i 0 (1+ i))
		 (x last-arg (cdr x)))
		((= i (1- last-args.length)))
      (push last-args (car x))
      (setf args (+ args "last-args[" i "]" (if (cdr x)
											","
											""))))
	(eval (+ "fun (" args ")"))
	(x.shift)))

)))
