;;;;; Transpiler: TRE to JavaScript
;;;;;
;;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>

(defun make-javascript-transpiler ()
  (create-transpiler
	:std-macro-expander 'js-alternate-std
	:macro-expander 'javascript
	:separator (format nil ";~%")
	:unwanted-functions '($ cons car cdr list make-hash-table maphash)
	:identifier-char?
	  #'(lambda (x)
		  (or (and (>= x #\a) (<= x #\z))
		  	  (and (>= x #\A) (<= x #\Z))
		  	  (and (>= x #\0) (<= x #\9))
			  (in=? x #\_ #\. #\$ #\#)))))

(defvar *js-transpiler* (make-javascript-transpiler))
(defvar *js-separator* (transpiler-separator *js-transpiler*))

;;;; EXPANSION OF ALTERNATE STANDARD MACROS

(defmacro define-js-std-macro (name args body)
  `(define-transpiler-std-macro *js-transpiler* ,name ,args ,body))

;;;; TRANSPILER-MACRO EXPANDER

(defmacro define-js-macro (name args body)
  `(define-transpiler-macro *js-transpiler* ,name ,args ,body))

;;;; TOPLEVEL

(defun read-many (str)
  (with (x nil)
	(while (not (end-of-file str)) (reverse x)
	  (awhen (read str)
		(push ! x)))))
	
(defun js-transpile (outfile infiles)
  (with (x nil)
	(dolist (file infiles)
	  (format t "Reading file '~A'.~%" file)
  	  (with-open-file f (open file :direction 'input)
	    (setf x (append x (read-many f)))))
    (with-open-file f (open outfile :direction 'output)
	  (with (base (or (format t "Compiling JavaScript core...~%")
      				  (transpiler-pass2 *js-transpiler* *js-base*))
	  		 user (or (format t "Compiling user code...~%")
      				  (transpiler-transpile *js-transpiler* x)))
	    (format t "Emitting code.~%")
		(format f "~A~A" base user)))))

(defun js-machine (outfile)
  (with-open-file f (open outfile :direction 'output)
    (format f "~A"
			(transpiler-concat-strings
			  (transpiler-wanted *js-transpiler* #'transpiler-pass2 (reverse *UNIVERSE*))))))

;;;; EXPANSION OF ALTERNATE STANDARD MACROS

(define-js-std-macro defun (name args &rest body)
  (progn
	 (unless (in? name 'apply 'list)
	   (acons! name args (transpiler-function-args tr)))
    `(%setq ,name
		    #'(lambda ,args
    		    ,@body))))

(define-js-std-macro defvar (name val)
  `(%setq ,name  ,val))

(define-js-std-macro slot-value (x y)
  `(%slot-value ,x ,(second y)))

(define-js-macro function (x)
  (if (atom x)
	  x
      `("function (" ,@(transpiler-binary-expand
				      ","
				      (argument-expand 'unnamed-js-function
									   (lambda-args x) nil nil)) ")"
	  ,(code-char 10)
	  "{var " ,'~%ret ,*js-separator*
	  "var __l = \"\"" ,*js-separator*
	  "while (1) {"
	  "switch (__l) {case \"\":"
      ,@(lambda-body x)
      ("}return " ,'~%ret ,*js-separator*)
	  "}}")))

(define-js-macro get-slot (slot obj)
  ($ obj "." slot))

(define-js-macro %setq (dest val)
  `((%transpiler-native ,dest) "=" ,val))

(define-js-macro %var (name)
  `(%transpiler-native "var " ,name))

;;; TYPE PREDICATES

(defmacro define-js-infix (name)
  `(define-transpiler-infix *js-transpiler* ,name))

(define-js-infix instanceof)

(defun def-js-type-predicate (name typestring)
  `(defun ,name (x)
     (instanceof x (%no-expex (%transpiler-native ,typestring)))))

;;;; Symbol replacement definitions.

(transpiler-translate-symbol *js-transpiler* nil "null")
(transpiler-translate-symbol *js-transpiler* t "true")

;;; Numbers, arithmetic and comparison.

(defmacro define-js-binary (op repl-op)
  `(define-transpiler-binary *js-transpiler* ,op ,repl-op))

(define-js-binary + "+")
(define-js-binary - "-")
(define-js-binary / "/")
(define-js-binary = "==")
(define-js-binary < "<")
(define-js-binary > ">")
(define-js-binary >> ">>")
(define-js-binary << "<<")
(define-js-binary mod "%")
(define-js-binary logxor "^")
(define-js-binary eq "===")
(define-js-binary eql "==")
(define-js-binary bit-and "&")
(define-js-binary bit-or "|")

(define-js-macro make-array (&rest elements)
  `(%transpiler-native "[" ,@(transpiler-binary-expand "," elements) "]"))

(define-js-macro aref (arr &rest idx)
  `(%transpiler-native ,arr
    ,@(mapcar #'(lambda (x)
                  `("[" ,x "]"))
              idx)))

(define-js-macro %%usetf-aref (val &rest x)
  `(%transpiler-native (aref ,@x) "=" ,val))

(define-js-macro make-string (&optional size)
  `(%transpiler-string ""))

(define-js-macro make-hash-table (&rest args)
  `("{"
    ,@(when args
	    (mapcan #'((x)
					 (list (first x) ":" (second x) ","))
			    (butlast (group args 2))))
    ,@(when args
		(with (x (car (last (group args 2))))
		  (list (first x) ":" (second x))))
   "}"))

(define-js-macro %new (&rest x)
  `(%transpiler-native "new " ,(first x) "(" ,@(transpiler-binary-expand "," (cdr x)) ")"))

;; Make object if first argument is not a keyword, or string.
(define-js-std-macro new (&rest x)
  (if (and (consp x)
		   (or (keywordp (first x))
			   (stringp (first x))))
	  `(make-hash-table ,@x)
	  `(%new ,@x)))

(define-js-macro vm-go (tag)
  `("__l=\"" ,(transpiler-symbol-string *js-transpiler* tag) "\"; continue"))

(define-js-macro vm-go-nil (val tag)
  `("if (!" ,val ") {__l=\"" ,(transpiler-symbol-string *js-transpiler* tag) "\"; continue;}"))

(define-js-macro identity (x)
  x)

(defun js-stack (x)
  ($ '__S x))

(define-js-macro %stack (x)
  (js-stack x))

(define-js-macro %quote (x)
  `("T37quote(\"" ,(symbol-name x) "\")"))

(define-js-macro %set-atom-fun (plc val)
  `(%transpiler-native ,plc "=" ,val))

(define-js-macro not (x)
  `(%transpiler-native "!" ,x))

(define-js-macro %slot-value (x y)
  ($ x "." y))

;    "ELT", "%SET-ELT", "LENGTH",
;    "CODE-CHAR", "INTEGER",
;    "CHARACTERP",
;    "STRING-CONCAT", "STRING"

;;;; This are the low-level transpiler definitions of
;;;; basic functions to simulate basic data types.

(defvar *js-base* `(
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

(defun %cons (a d)
  (setf this._a a)
  (setf this._d d)
  this)

(defun cons (a d)
  (new %cons a d))

(defun car (x)
  x._a)

(defun cdr (x)
  x._d)

(defun rplaca (x val)
  (setf x._a val))

(defun rplacd (x val)
  (setf x._d val))

(defun list ()
  (labels ((rec (x)
             (unless (= x.length 0)
               (with (a (aref x 0))
				 (x.shift) ; pop off first element from array.
                 (cons a (rec x))))))
    (rec arguments)))

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

(%transpiler-native "function maphash (fun, hash) { for (i in hash) fun (i); return null; }")
))
