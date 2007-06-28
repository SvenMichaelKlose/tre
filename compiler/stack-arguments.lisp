;;;; nix operating system project
;;;; lisp compiler
;;;; Copyright (c) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Stack arguments
;;;;
;;;; Translates argument definitions for compiled functions.

;; Expand &REST keyword.
(defun %stackarg-expand-rest (args)
  (%remove-keyword! args)
  (list nil))

;; Expand &OPTIONAL keyword.
(defun %stackarg-expansion-optional-r (args)
  (if args
    (prog1
      (cons (%argument-init (car args))
	    (%stackarg-expansion-optional-r (cdr args)))
      ; Remove default value from argument list.
      (if (consp (car args))
        (rplaca args (caar args))))))

;; Expand &OPTIONAL keyword.
(defun %stackarg-expansion-optional (args)
  (%remove-keyword! args)
  (%stackarg-expansion-optional-r args))

;;; &KEY expansion

;; Returns list of init forms in argument list.
(define-mapcar-fun %stackarg-keyword-inits (a)
  (%argument-init a))

; Returns argument list without init forms.
(define-mapcar-fun %stackarg-keyword-init-forms (a)
  (make-symbol (symbol-name (if (consp a) (first a) a))))

;; Expand &KEY keyword.
(defun %stackarg-expand-key (args)
  (%remove-keyword! args)
  (let* ((forms (%stackarg-keyword-init-forms args))
         (inits (pairlis forms (%stackarg-keyword-inits args))))
    (rplac-cons args (carlist inits))
    (cdrlist inits)))

;; Expand keyword argument.
(defun %stackarg-expand-keyword (args)
  (case (car args)
    ('&rest      (%stackarg-expand-rest args))
    ('&optional  (%stackarg-expansion-optional args))
    ('&key       (%stackarg-expand-key args))))

(defun %stackarg-expand-sublevel (args)
  (let ((a (car args)))
    (cons (%stackarg-expansion-r a)
          (%stackarg-expansion-r (cdr args)))))

;; Expand argument keywords.
(defun %stackarg-expansion-r (args)
  (if args
    (let ((arg (car args)))
      (if (listp arg)
        (%stackarg-expand-sublevel args)
        (if (%arg-keyword-p arg)
          (%stackarg-expand-keyword args)
          (cons nil (%stackarg-expansion-r (cdr args))))))))

(defun %stackarg-expansion! (args)
  "Map expand argument form into flat list."
  (let* ((a (copy-tree args))
         (v (%stackarg-expansion-r a)))
    (flatten-trees-sync! a v)
    (values a v)))

;;; Tests

(define-test "argument expansion basically works"
  ((equal (%stackarg-expansion! '(a b))
	  '(values (a b) (nil nil))))
  t)

(define-test "argument expansion can handle nested lists"
  ((and
     (equal (%stackarg-expansion! '(a (b c) d))
	    '(values (a b c d) (nil nil nil nil)))
     (equal (%stackarg-expansion! '(a b))
	    '(values (a b) (nil nil)))
     ))
  t)

(define-test "argument expansion can handle &REST keyword"
  ((equal (%stackarg-expansion! '(a b &rest c))
	  '(values (a b c) (nil nil nil))))
  t)

(define-test "argument expansion can handle &OPTIONAL keyword"
  ((equal (%stackarg-expansion! '(a b &optional c d))
	  '(values (a b c d) (nil nil nil nil))))
  t)

(define-test "argument expansion can handle &OPTIONAL keyword with init forms"
  ((equal (%stackarg-expansion! '(a b &optional (c 3) (d 42)))
	  '(values (a b c d) (nil nil 3 42))))
  t)

(define-test "argument expansion can handle &KEY keyword"
  ((equal (%stackarg-expansion! '(a b &key c d))
          '(values (a b c d) (nil nil nil nil))))
  t)
(define-test "argument expansion can handle &KEY keyword with init forms"
  ((equal (%stackarg-expansion! '(a b &key (c 3) (d 42)))
          '(values (a b c d) (nil nil 3 42))))
  t)
