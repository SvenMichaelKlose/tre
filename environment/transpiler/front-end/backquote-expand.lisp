;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(defun backquote-quasiquote (x)
  (? (any-quasiquote? (cadr x.))
     `(cons ,(backquote-1 (cadr x.))
            ,(backquote-1 .x))
     `(cons ,(cadr x.)
            ,(backquote-1 .x))))

(defun backquote-quasiquote-splice (x)
  (? (any-quasiquote? (cadr x.))
     (error "~A in QUASIQUOTE-SPLICE (or ',@' for short)." (cadr x.))
     (!? (backquote-1 .x)
         `(%nconc (copy-list ,(let tr *transpiler*
                                (? (transpiler-assert? tr)
                                   (frontend-macroexpansions `(aprog1 ,(cadr x.)
                                                                (| (list? !) (error ",@ expects a list instead of ~A." !))))
                                   (cadr x.))))
                   ,(backquote-1 .x))
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
    (atom x.)               `(cons ,(quote-literal x.)
                                   ,(backquote-2 .x))
    (quasiquote? x.)        (backquote-quasiquote x)
    (quasiquote-splice? x.) (backquote-quasiquote-splice x)
    `(cons ,(backquote-1 x.)
           ,(backquote-2 .x))))

(defun simple-quote-expand (x)
  (? (atom x)
     (quote-literal x)
     `(cons ,(simple-quote-expand x.)
            ,(simple-quote-expand .x))))

(defun backquote-expand (l)
  (tree-walk l
	  :ascending [?
                   (quote? _)     (simple-quote-expand ._.)
                   (backquote? _) (backquote-1 ._.)
                   _]))
