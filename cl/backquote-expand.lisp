;;;;; tré – Copyright (c) 2006–2014 Sven Michael Klose <pixel@copei.de>

(defun quote? (x)
  (and (consp x)
       (eq 'quote (car x))))

(defun backquote? (x)
  (and (consp x)
       (eq 'tre:backquote (car x))))

(defun quasiquote? (x)
  (and (consp x)
       (eq 'tre:quasiquote (car x))))

(defun quasiquote-splice? (x)
  (and (consp x)
       (eq 'tre:quasiquote-splice (car x))))

(defun any-quasiquote? (x)
  (or (quasiquote? x)
      (quasiquote-splice? x)))

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

(defun backquote-1 (x)
  (?
    (atom x)                (quote-literal x)
    (atom (car x))           `(cons ,(quote-literal (car x))
                                    ,(backquote-1 (cdr x)))
    (quasiquote? (car x))        (backquote-quasiquote x)
    (quasiquote-splice? (car x)) (backquote-quasiquote-splice x)
    `(cons ,(backquote-1 (car x))
           ,(backquote-1 (cdr x)))))

(defun simple-quote-expand (x)
  (? (atom x)
     (quote-literal x)
     `(cons ,(simple-quote-expand (car x))
            ,(simple-quote-expand (cdr x)))))

(defun backquote-expand (x)
  (tree-walk x
	  :ascending #'(lambda (_)
                     (?
                       (quote? _)     (simple-quote-expand (cadr _))
                       (backquote? _) (backquote-1 (cadr _))
                       _))))
