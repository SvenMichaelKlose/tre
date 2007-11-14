;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Argument expansion

(defun %remove-keyword! (l)
  (pop! l))

;; Returns argument init form or NIL.
(defun %argument-init (a)
  (when (consp a)
    (second a)))

;; Check if an expression has arguments (more than 1 element).
(defun %expr-has-args-p (expr)
  (and (consp expr) (consp (cdr expr))))

;; Expand &REST keyword.
(defun %argument-expand-rest (args vals)
  (%remove-keyword! args)
  (list vals))

(defun %argument-expand-optional-r (args vals)
  (if args
    (prog1
      (cons (if vals
	      (car vals)
	      (%argument-init (car args)))
	    (%argument-expand-optional-r (cdr args) (cdr vals)))
      ; Remove default value from argument list.
      (if (consp (car args))
        (rplaca args (caar args))))
    (if vals
      (error "too many optional arguments"))))

;; Expand &OPTIONAL keyword.
(defun %argument-expand-optional (args vals)
  (%remove-keyword! args)
  (%argument-expand-optional-r args vals))

;; Returns list of init forms in argument list.
(define-mapcar-fun %argument-expand-key-inits (a)
  (%argument-init a))

;; Returns argument list without init forms.
(define-mapcar-fun %argument-expand-key-init-forms (a)
  (if (consp a)
    (first a)
    a))

(defun %argument-expand-key-r! (keyinits vals)
  "Replace value in init-list by user value."
  (when vals
    (aif (assoc-cons (make-symbol (symbol-name (first vals))) keyinits)
      (progn
        (rplacd ! (second vals))
        (%argument-expand-key-r! keyinits (cddr vals)))
      (error "keyword argument not defined"))))

;; Expand &KEY keyword.
(defun %argument-expand-key (args vals)
  (%remove-keyword! args)
  (let* ((forms (%argument-expand-key-init-forms args))
         (inits (pairlis forms (%argument-expand-key-inits args))))
    (%argument-expand-key-r! inits vals)
    (rplac-cons args (carlist inits))
    (cdrlist inits)))

(defun %argument-expand-keyword (args vals)
  (case (car args)
    ('&rest      (%argument-expand-rest args vals))
    ('&optional  (%argument-expand-optional args vals))
    ('&key       (%argument-expand-key args vals))))

(defun %argument-expand-sublevel (args vals)
  (let ((a (car args))
        (v (car vals)))
    (if (listp v)
      (cons (%argument-expand-r a v)
            (%argument-expand-r (cdr args) (cdr vals)))
      (error "list expected"))))

(defun %argument-expand-r (args vals)
  (if (endp args)
     (when vals
       (error "too many arguments"))
     (let ((arg (car args)))
       (if (listp arg)
         (%argument-expand-sublevel args vals)
         (if (%arg-keyword-p arg)
	   (%argument-expand-keyword args vals)
	   (cons (car vals)
                 (%argument-expand-r (cdr args) (cdr vals))))))))

(defun argument-expand (args vals)
  "Map values against arguments and flatten tree to pure list."
  (let* ((a (copy-tree args))
         (v (%argument-expand-r a (copy-tree vals))))
    (flatten-trees-sync! a v)
    (values (mapcar #'((x)
                        (make-symbol (symbol-name x))) a)
            v)))

;;; Tests

(define-test "argument expansion basically works"
  ((equal (argument-expand '(a b) '(2 3))
	  '(values (a b) (2 3))))
  t)

(define-test "argument expansion can handle nested lists"
  ((and
     (equal (argument-expand '(a (b c) d) '(23 (2 3) 42))
	    '(values (a b c d) (23 2 3 42)))
     (equal (argument-expand '(a b) '(2 3))
	    '(values (a b) (2 3)))
     ))
  t)

(define-test "argument expansion can handle &REST keyword"
  ((equal (argument-expand '(a b &rest c) '(23 5 42 65))
	  '(values (a b c) (23 5 (42 65)))))
  t)

(define-test "argument expansion can handle &OPTIONAL keyword"
  ((equal (argument-expand '(a b &optional c d) '(23 2 3 42))
	  '(values (a b c d) (23 2 3 42))))
  t)

(define-test "argument expansion can handle &OPTIONAL keyword with init forms"
  ((equal (argument-expand '(a b &optional (c 3) (d 42)) '(23 2))
	  '(values (a b c d) (23 2 3 42))))
  t)

(define-test "argument expansion can handle &KEY keyword"
  ((equal (argument-expand '(a b &key c d) '(23 2 :c 3 :d 42))
          '(values (a b c d) (23 2 3 42))))
  t)
(define-test "argument expansion can handle &KEY keyword with init forms"
  ((equal (argument-expand '(a b &key (c 3) (d 42)) '(23 2))
          '(values (a b c d) (23 2 3 42))))
  t)
