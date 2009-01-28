;;;;; Transpiler: TRE to JavaScript
;;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;;
;;;;; This are the low-level transpiler definitions of
;;;;; basic functions to simulate basic data types.

;;;; First part of the core functions
;;;;
;;;; It contains the essential functions needed to store argument
;;;; definitions for APPLY.
(defvar *js-base* `(

;; The global variable for return values of expressions.
(defvar ~%ret nil)

;;; Symbols

;; All symbols are stored in this array for reuse.
(defvar *symbols* (make-array))

(defun not (x)
  no-args
  (if x
	  nil
	  t))

;; Cell object constructor.
(defun %cons (a d)
  no-args
  (setf this.__class "cons"
        this._ a
  		this.__ d)
  this)

;; Cell constructor
;;
;; Wraps the 'new'-operator.
(defun cons (x y)
  no-args
  (new %cons x y))

;; Symbol constructor
;;
;; It has a function field but that isn't used yet.
(defun %symbol (name pkg)
  no-args
  (setf this.__class "symbol"
		this.n name	; name
     	this.v nil	; value
      	this.f nil	; function
		this.p (or pkg nil))	; package
  this)

;; Find symbol by name or create a new one.
;;
;; Wraps the 'new'-operator.
;; XXX rename to %QUOTE ?
(defun %lookup-symbol (name pkg)
  no-args
  ; Make package if missing.
  (or (aref *symbols* pkg)
	  (setf (aref *symbols* pkg) (make-array)))
  ; Get or make symbol.
  (or (aref (aref *symbols* pkg) name)
	  (setf (aref (aref *symbols* pkg) name) (new %symbol name pkg))))

(defun symbol (name pkg)
  no-args
  (%lookup-symbol name pkg))
))

;;;; Second part of the core functions
;;;;
;;;; Functions required by imported environment functions.
(defvar *js-base2* `(

;; Set argument definitions for functions in the first part.
(setf not.tre-args '(x))
(setf cons.tre-args '(x y))
(setf symbol.tre-args '(name))

(defvar *keyword-package* t)

;; XXX a workaround because we cannot import DEFVARs from the
;; environment yet.
(defvar argument-exp-sort-key nil)

;; Make symbol in particular package.
(defun make-symbol (x &optional (pkg nil))
  (%lookup-symbol x pkg ))

(defun symbol-name (x)
  (if x
  	  x.n
	  "NIL"))

(defun symbol-value (x) (when x x.v))
(defun symbol-function (x) (when x x.f))
(defun symbol-package (x) (when x x.p))

(defun identity (x) x)

;;; CONSES
;;;
;;; Conses are objects containing a pair.

(defun list (&rest x) x)
(defun car (x) (when x x._))
(defun cdr (x) (when x x.__))

(defun rplaca (x val)
  (setf x._ val)
  x)

(defun rplacd (x val)
  (setf x.__ val)
  x)

(js-type-predicate %numberp number)
(js-type-predicate stringp string)
(js-type-predicate functionp function)
(js-type-predicate objectp object)

(defun symbolp (x)
  (and (objectp x)
	   x.__class
	   (%%%= x.__class "symbol")))

(defun consp (x)
  (and (objectp x)
	   x.__class
	   (%%%= x.__class "cons")))

(defun atom (x)
  (or (not x) ; XXX needed?
	  (not (consp x))))

(defun arrayp (x) (instanceof x *array))

(defun eq (x y)
  (%%%eq x y))

(defun %wrap-char-number (x)
  (if (characterp x)
	  (char-code x)
	  x))

(defun number+ (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
	  (setf n (%%%+ n (%wrap-char-number i))))))

(defun + (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
	  (setf n (%%%+ n (%wrap-char-number i))))))

(defun number- (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
	  (setf n (%%%- n (%wrap-char-number i))))))

(defun - (&rest x)
  (let n (%wrap-char-number x.)
	(dolist (i .x n)
	  (setf n (%%%- n (%wrap-char-number i))))))

(defun = (x y)
  (with (xn (%wrap-char-number x)
		 yn (%wrap-char-number y))
	(%%%= xn yn)))

(defun < (x y)
  (with (xn (%wrap-char-number x)
		 yn (%wrap-char-number y))
	(%%%< xn yn)))

(defun > (x y)
  (with (xn (%wrap-char-number x)
		 yn (%wrap-char-number y))
	(%%%> xn yn)))

(defun eql (x y)
  (unless x			; Convert falsity to 'null'.
	(setq x nil))
  (unless y
	(setq y nil))
  (or (eq x y)
	  (%%%= x y)))

(defun string-concat (&rest x)
  (apply #'+ x))

(defun js-print-cons-r (x)
  (when x
    (js-print x.)
    (if (consp .x)
	    (js-print-cons-r .x)
	    (when .x
		  (document.write " . ")
		  (document.write .x)))))

(defun js-print-cons (x)
  (document.write "(")
  (js-print-cons-r x)
  (document.write ")"))

(defun js-print (x)
  (if
	(consp x)
	  (js-print-cons x)
	(document.write
	  (+ (if
		   (symbolp x)
	         (symbol-name x)
	       (characterp x)
		     (+ "#\\\\" (*string.from-char-code (char-code x)))
	       (arrayp x)
	         "{array}"
	       (stringp x)
	         (+ "\\\"" x "\\\"")
		   (when x
			 (string x)))
		 " ")))
  x)

(defun list-array (x)
  (let a (make-array)
    (dolist (i x a)
      (a.push i))))

(defun array-list (x &optional (n 0))
  (when (< n x.length)
    (cons (aref x n)
		  (array-list x (1+ n)))))

(defvar *apply-counter* 0)

(defun apply (fun &rest lst)
  (setq *apply-counter* (%%%+ *apply-counter* 1))
  (when (%%%< 20 *apply-counter*)
	(toomuchapplications))
  (let args (%nconc (butlast lst)
				    (car (last lst)))
    (prog1
      (fun.apply nil
	    (list-array
	      (aif fun.tre-args
               (argument-expand-values fun ! args)
			   args)))
	  (setq *apply-counter* (%%%- *apply-counter* 1)))))

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

(defvar *characters* (make-array))

(defun %character (x)
  (or (aref *characters* x)
  	  (setf this.__class "%character"
  		    this.v x
		    (aref *characters* x) this)))

(defun characterp (x)
  (and (objectp x)
	   x.__class
	   (%%%= x.__class "%character")))

(defun code-char (x)
  (if (characterp x)
	  x
	  (new %character x)))

(defun char-code (x) x.v)
(defun char-string (x) (*string.from-char-code (char-code x)))

(defun numberp (x)
  (or (%numberp x)
	  (characterp x)))

(defun %elt-string (seq idx)
  (code-char (seq.char-code-at idx)))

(defun elt (seq idx)
  (if
    (stringp seq)
	  (%elt-string seq idx)
    (consp seq)
	  (nth idx seq)
  	(aref seq idx)))

(defun %setf-elt-string (val seq idx)
  (assert (characterp val)
    (error "can only write CHARACTER to string"))
  (setf (aref seq idx) (*string.from-char-code (char-code val))))

(defun (setf elt) (val seq idx)
  (if (stringp seq)
	  (error "strings cannot be modified")
  	  (setf (aref seq idx) val)))

(defun string (x)
  (if
	(stringp x)
	  x
	(characterp x)
      (char-string x)
    (symbolp x)
	  (symbol-name x)
   	(x.to-string)))

(defun %force-output (&optional strm))

(defun %error (msg)
  (log msg))

(defun integer (x)
  (assert (numberp x)
	(error "number expected"))
  (if (characterp x)
	  (char-code x)
	  x))

(defun list-string (lst)
  "Convert list of characters to string."
  (when lst
    (let* ((n (length lst))
           (s (make-string 0)))
      (do ((i 0 (1+ i))
           (l lst (cdr l)))
          ((>= i n) s)
        (setf s (+ s (string (car l))))))))

;,(read-file "environment/stage4/null-stream.lisp")

;(defvar *standard-output* (make-null-stream))
;(defvar *standard-input* (make-null-stream))

))

(defun make-environment-tests ()
  (with (names nil
		 num 0
  		 funs (mapcar
				(fn
				  (setf num (1+ num))
				  (let n ($ 'test- num)
					(setf names (push n names))
				    `(defun ,n ()
				       (document.writeln (+ "Test " (string ,num) ": "
											,(first _) "</br>"))
				       (unless (equal ,(third _) ,(second _))
				         (document.writeln (+ "Test '"
											  ,(first _)
											  "' failed</br>"))
						 (js-print ,(second _))
						 (document.writeln "</br>")))))
		    	(reverse *tests*)))
	`(,@funs
	    (defun environment-tests ()
		  ,@(mapcar #'list (reverse names))))))
