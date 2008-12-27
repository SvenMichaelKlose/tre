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

(defun eql (x y)
  (or (eq x y)
	  (= x y)))

;(defun + (&rest x)
;  (apply #'%%%+ x))

;(defun - (&rest x)
;  (apply #'%%%- x))

;(defun * (&rest x)
;  (apply #'%%%* x))

;(defun / (&rest x)
;  (apply #'%%%/ x))

;(defun = (&rest x)
;  (apply #'%%%= x))

;(defun < (&rest x)
;  (apply #'%%%< x))

(defun symbol (x)
  (aif (aref *symbols* x)
	   !
  	   (setf this.n x
        	 this.v nil
        	 this.f nil
			 (aref *symbols* x) this)))

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
,(def-js-type-predicate objectp "Object")

(defun atom (x)
  (not (consp x)))

(defun %apply (fun &rest lst)
  (assert (%%%< 0 arguments.length) "apply requires arguments")
  (with (last-arg nil
		 args (make-array)
		 last-args (make-array))
    (do ((i args (cdr i)))
		((not (cdr i))
		 (setf last-args (car i)))
      (args.push (aref arguments i)))

    (dolist (i last-args)
      (args.push (aref last-args i)))
	(fun.apply nil args)))

(defun %list-length (x &optional (n 0))
  (if (consp x)
	  (%list-length (cdr x) (1+ n))
	  n))
  
(defun length (x)
  (when x
    (if (consp x)
	    (%list-length x)
	    x.length)))

(defun map (fun hash)
  (%transpiler-native "null;for (i in hash) fun (i)"))

;; Bind function to an object.
;; See also macro BIND in 'core.lisp'.
(defun %bind (obj fun)
  (assert (functionp fun) "BIND requires a function")
  #'(()
      (fun.apply obj arguments)))

(defun %character (x)
  (setf this.magic '%CHARACTER)
  (setf this.v x)
  this)

(defun code-char (x)
  (new %character x))

(defun char-code (x)
  x.v)

(defun characterp (x)
  (and (objectp x)
	   (eq x.magic '%CHARACTER)))

(defun elt (seq idx)
  (aref seq idx))

(defun (setf elt) (val seq idx)
  (setf (aref seq idx) val))

;,(read-file "environment/stage4/null-stream.lisp")

;(defvar *standard-output* (make-null-stream))
;(defvar *standard-input* (make-null-stream))
))
