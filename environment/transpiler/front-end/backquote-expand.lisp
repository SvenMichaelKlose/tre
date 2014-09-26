;;;;; tré – Copyright (c) 2006–2014 Sven Michael Klose <pixel@copei.de>

(defun backquote-quasiquote (x)
  (? (any-quasiquote? (cadr x.))
     `(. ,(backquote-1 (cadr x.))
         ,(backquote-1 .x))
     `(. ,(cadr x.)
         ,(backquote-1 .x))))

(defun backquote-quasiquote-splice (x)
  (? (any-quasiquote? (cadr x.))
     (error "~A in QUASIQUOTE-SPLICE (or ',@' for short)." (cadr x.))
     (!? (backquote-1 .x)
         `(append ,(cadr x.) ,(backquote-1 .x))
         (cadr x.))))

(defun quote-literal (x)
  (? (constant-literal? x)
     x
     `(%quote ,x)))

(defun backquote-2 (x)
  (?
    (atom x)        x
    (quasiquote? x) .x.
    (backquote-1 x)))

(defun backquote-1 (x)
  (?
    (atom x)                (quote-literal x)
    (atom x.)               `(. ,(quote-literal x.)
                                ,(backquote-2 .x))
    (quasiquote? x.)        (backquote-quasiquote x)
    (quasiquote-splice? x.) (backquote-quasiquote-splice x)
    `(. ,(backquote-1 x.)
        ,(backquote-2 .x))))

(defun simple-quote-expand (x)
  (? (atom x)
     (quote-literal x)
     `(. ,(simple-quote-expand x.)
         ,(simple-quote-expand .x))))

(defun backquote-expand (l)
  (tree-walk l
	  :ascending [?
                   (quote? _)     (simple-quote-expand ._.)
                   (backquote? _) (backquote-1 ._.)
                   _]))
