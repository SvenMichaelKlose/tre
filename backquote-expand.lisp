;;;;; tré – Copyright (c) 2006–2014 Sven Michael Klose <pixel@copei.de>

(defmacro !? (x &rest y)
  `(let ((! ,x))
     (? !
        ,@y)))

(defun quote? (x)
  (and (consp x)
       (eq 'quote (car x))))

(defun backquote? (x)
  (and (consp x)
       (eq 'backquote (car x))))

(defun quasiquote? (x)
  (and (consp x)
       (eq 'quasiquote (car x))))

(defun quasiquote-splice? (x)
  (and (consp x)
       (eq 'quasiquote-splice (car x))))

(defun any-quasiquote? (x)
  (and (consp x)
       (or (quasiquote (car x))
           (quasiquote-splice (car x)))))

(defun constant-literal? (x)
  (or (not x)
      (eq t x)
      (numberp x)
      (stringp x)
      (arrayp x)
      (hash-table-p x)))

(defun backquote-quasiquote (x)
  (? (any-quasiquote? (cadar x))
     `(cons ,(backquote-1 (cadar x))
            ,(backquote-1 (cdr x)))
     `(cons ,(cadar x)
            ,(backquote-1 (cdr x)))))

(defun backquote-quasiquote-splice (x)
  (? (any-quasiquote? (cadar x))
     (error "~A in QUASIQUOTE-SPLICE (or ',@' for short)." (cadar x))
     (!? (backquote-1 (cdr x))
         `(append ,(cadar x) ,(backquote-1 (cdr x)))
         (cadar x))))

(defun quote-literal (x)
  (? (constant-literal? x)
     x
     `(quote ,x)))

(defun backquote-2 (x)
  (?
    (atom x)        x
    (quasiquote? x) (cadr x)
    (backquote-1 x)))

(defun backquote-1 (x)
  (?
    (atom x)                (quote-literal x)
    (atom (car x))           `(cons ,(quote-literal (car x))
                                    ,(backquote-2 (cdr x)))
    (quasiquote? (car x))        (backquote-quasiquote x)
    (quasiquote-splice? (car x)) (backquote-quasiquote-splice x)
    `(cons ,(backquote-1 (car x))
           ,(backquote-2 (cdr x)))))

(defun simple-quote-expand (x)
  (? (atom x)
     (quote-literal x)
     `(cons ,(simple-quote-expand (car x))
            ,(simple-quote-expand (cdr x)))))

(defun backquote-expand (l)
  (tree-walk l
	  :ascending #'(lambda (_)
                     (?
                       (quote? _)     (simple-quote-expand (cadr _))
                       (backquote? _) (backquote-1 (cadr _))
                       _))))
