;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; This are the low-level transpiler definitions of
;;;;; basic functions to simulate basic data types.

(defvar *js-base* `(

(defvar ~%ret nil)

;;; Symbols
;;;
;;; These are string encapsulated in an object to make
;;; them a distinguished type.

(defvar *symbols* (make-hash-table))

(defun eql (x y)
  (unless x			; Convert falsity to 'null'.
	(setq x nil))
  (unless y
	(setq y nil))
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
  (or (aref *symbols* x)
  	  (setf this.n x
        	this.v nil
        	this.f nil
			(aref *symbols* x) this)))

(defun symbol-name (x) x.n)
(defun symbol-value (x) x.v)
(defun symbol-function (x) x.f)
(defun make-symbol (x &optional pkg) (symbol x))

(defun %quote (s)
  (or (aref *symbols* s)
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
(defun list (&rest x) x)
(defun car (x) (when x x._))
(defun cdr (x) (when x x.__))

(defun rplaca (x val)
  (setf x._ val)
  x)

(defun rplacd (x val)
  (setf x.__ val)
  x)

(js-type-predicate symbolp symbol)
(js-type-predicate %numberp number)
(js-type-predicate stringp string)
(js-type-predicate functionp function)
(js-type-predicate objectp object)

(defun consp (x)
  (and (objectp x)
	   x.__class
	   (= "cons" x.__class)))

(defun atom (x) (or (not x) (not (consp x))))
(defun arrayp (x) (instanceof x -array))

;,(when *assert*
;  `(progn
;(defun js-core-test ()
; (unless (arrayp (new *array))
;(alert "ARRAYP test"))
; (unless (consp (cons nil nil))
;(alert "CONSP test"))
; (unless (numberp 23)
;(alert "NUMBERP test"))
; (unless (stringp "23")
;(alert "STRINGP test"))
; (unless (functionp #'(()))
;(alert "FUNCTIONP test"))
; (unless (objectp (new *object))
;(alert "OBJECTP test")))
;(js-core-test)

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

(dont-obfuscate fun hash)

(defun map (fun hash)
  (%transpiler-native "null;for (i in hash) fun (i)"))

;; Bind function to an object.
;; See also macro BIND in 'expand.lisp'.
(defun %bind (obj fun)
  (assert (functionp fun) "BIND requires a function")
  #'(()
      (fun.apply obj arguments)))

(defvar *characters* (make-hash-table))

(defun %character (x)
  (or (aref *characters* x)
  	  (setf this.magic '%CHARACTER
  		    this.v x
		    (aref *characters* x) this)))

(defun code-char (x) (new %character x))
(defun char-code (x) x.v)

(defun characterp (x)
  (and (objectp x)
	   x.magic
	   (eq '%CHARACTER x.magic)))

(defun numberp (x)
  (or (%numberp x)
	  (characterp x)))

(defun elt (seq idx) (aref seq idx))
(defun (setf elt) (val seq idx) (setf (aref seq idx) val))

(defun string-concat (&rest strings)
  (let ret (make-string)
	(dolist (i strings)
	  (setf ret (+ ret i)))))

,(read-file "environment/stage4/null-stream.lisp")

(defvar *standard-output* (make-null-stream))
(defvar *standard-input* (make-null-stream))

(defun environment-tests ()
  ,@(mapcar (fn `(progn
				   (document.writeln (+ ,(first _) "</br>"))
(unless (equal ,(third _) ,(second _))
				   (alert (+ "Test '" ,(first _) "' failed")))))
		  (reverse *tests*)))
(environment-tests)

))
