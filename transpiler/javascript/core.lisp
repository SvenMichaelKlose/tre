;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; This are the low-level transpiler definitions of
;;;;; basic functions to simulate basic data types.

(defvar *js-base* `(

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

(defun symbol-name (x) x.n)
(defun symbol-value (x) x.v)
(defun symbol-function (x) x.f)
(defun make-symbol (x) (symbol x))

(defun %quote (s)
  (aif (aref *symbols* s)
	   !
	   (symbol s)))

;;; CONSES
;;;
;;; Conses are objects containing a pair.

(defun %cons (x y)
  (setf this.__class "cons")
  (setf this._ x)
  (setf this.__ y)
  this)

(defun cons (x y) (new %cons x y))
(defun car (x) x._)
(defun cdr (x) x.__)

(defun rplaca (x val) (setf x._ val))
(defun rplacd (x val) (setf x.__ val))

(defun list (&rest x) x)

(js-type-predicate symbolp symbol)
(js-type-predicate numberp number)
(js-type-predicate stringp string)
(js-type-predicate functionp function)
(js-type-predicate objectp object)

(defun consp (x)
  (and (objectp x)
	   x.__class
	   (= "cons" x.__class)))

(defun arrayp (x)
  (instanceof x -array))

(when-debug
  (defun js-core-test ()
    (unless (arrayp (new *array))
	  (alert "ARRAYP test"))
    (unless (consp (cons nil nil))
	  (alert "CONSP test"))
    (unless (numberp 23)
	  (alert "NUMBERP test"))
    (unless (stringp "23")
	  (alert "STRINGP test"))
    (unless (functionp #'(()))
	  (alert "FUNCTIONP test"))
    (unless (objectp (new *object))
	  (alert "FUNCTIONP test")))
  (js-core-test))

(defun atom (x) (not (consp x)))

(defun %apply (fun &rest lst)
  (assert (< 0 arguments.length) "apply requires arguments")
  (with (last-arg nil
		 args (make-array)
		 last-args (make-array))
    (do ((i args .i))
		((not .i)
		 (setf last-args i.))
      (args.push (aref arguments i)))

    (dolist (i last-args)
      (args.push (aref last-args i)))
	(fun.apply nil args)))

(defun %list-length (x &optional (n 0))
  (if (consp x)
	  (%list-length .x (1+ n))
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
  (setf this.magic '%CHARACTER
  		this.v x)
  this)

(defun code-char (x) (new %character x))
(defun char-code (x) x.v)

(defun characterp (x)
  (and (objectp x)
	   (eq x.magic '%CHARACTER)))

(defun elt (seq idx) (aref seq idx))
(defun (setf elt) (val seq idx) (setf (aref seq idx) val))

(defun numberp (x) (not (stringp x))) ; XXX fscks up on FF3.

;,(read-file "environment/stage4/null-stream.lisp")

;(defvar *standard-output* (make-null-stream))
;(defvar *standard-input* (make-null-stream))
))
