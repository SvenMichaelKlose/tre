;;;;; tré – Copyright (c) 2006–2013 Sven Michael Klose <pixel@copei.de>

(defun backquote-cons-quasiquote (x)
  (? (any-quasiquote? (cadr x.))
     `(cons ,(backquote-cons (cadr x.))
            ,(backquote-cons-1 .x))
     `(cons ,(copy-tree (cadr x.))
            ,(backquote-cons-1 .x))))

(defun backquote-cons-quasiquote-splice (x)
  (? (any-quasiquote? (cadr x.))
     `(cons ,(copy-tree (cadr x.))
            ,(backquote-cons-1 .x))
     (!? (backquote-cons-1 .x)
         `(%nconc ,(? *transpiler-assert*
                      (compiler-macroexpand (transpiler-macroexpand *current-transpiler*
                                                                    `(aprog1 ,(copy-tree (cadr x.))
                                                                       (| (list? !) (error ",@ expects a list instead of ~A" !)))))
                      (copy-tree (cadr x.)))
                  ,(backquote-cons-1 .x))
         (copy-tree (cadr x.)))))

(defun quote-literal (x)
  (? (constant-literal? x)
     x
     `(%quote ,x)))

(defun backquote-cons-2 (x)
  (?
    (atom x)        x
    (quasiquote? x) .x.
    (backquote-cons-1 x)))

(defun backquote-cons-1 (x)
  (?
    (atom x)                (quote-literal x)
    (atom x.)               `(cons ,(quote-literal x.)
                                   ,(backquote-cons-2 .x))
    (quasiquote? x.)        (backquote-cons-quasiquote x)
    (quasiquote-splice? x.) (backquote-cons-quasiquote-splice x)
    `(cons ,(backquote-cons x.)
           ,(backquote-cons-2 .x))))

(defun backquote-cons (x)
  (?
    (atom x)       (quote-literal x)
    (backquote? x) `(cons 'BACKQUOTE ,(backquote-cons .x))
    (backquote-cons-1 x)))

(defun simple-quote-expand (x)
  (? (atom x)
     (quote-literal x)
     `(cons ,(simple-quote-expand x.)
            ,(simple-quote-expand .x))))

(defun backquote-expand (l)
  (tree-walk l
	  :ascending [?
                   (quote? _)     (simple-quote-expand ._.)
                   (backquote? _) (backquote-cons ._.)
                   _]))
