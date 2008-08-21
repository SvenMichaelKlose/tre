;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; This are the low-level transpiler definitions of
;;;;; basic functions to simulate basic data types.

(defun def-js-type-predicate (name typestring)
  `(defun ,name (x)
     (instanceof x (%no-expex (%transpiler-native ,typestring)))))

(defvar *js-base* `(
; IDENTITY - use native

;;; Symbols
;;;
;;; These are string encapsulated in an object to make
;;; them a distinguished type.

(defvar *symbols* (make-hash-table))

(defun not (x)
  (if x
	  nil
	  t))

(defun symbol (x)
  (setf this.n x
        this.v nil
        this.f nil
		(aref *symbols* s) this)
  this)

(defun symbol-name (x)
  x.n)

(defun symbol-value (x)
  x.v)

(defun symbol-function (x)
  x.f)

(defun make-symbol (x)
  (symbol x))

(defun %quote (s)
  (aif (aref *symbols* s)
	   !
	   (symbol s)))

;;; CONSES
;;;
;;; Conses are objects containing a pair.

(defun %cons (x y)
  (setf this._ x)
  (setf this.__ y)
  this)

(defun cons (x y)
  (new %cons x y))

(defun car (x)
  x._)

(defun cdr (x)
  x.__)

(defun rplaca (x val)
  (setf x._ val))

(defun rplacd (x val)
  (setf x.__ val))

(defun list (&rest x)
  x)

,(def-js-type-predicate symbolp "symbol")
,(def-js-type-predicate consp '%cons)
,(def-js-type-predicate numberp "Number")
,(def-js-type-predicate arrayp "Array")
,(def-js-type-predicate stringp "String")
,(def-js-type-predicate functionp "Function")

(defun atom (x)
  (not (consp x)))

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

(defun map (fun hash)
  (%transpiler-native "null;for (i in hash) fun (i)"))
))
