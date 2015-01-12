;;;; tré – Copyright (c) 2006–2014 Sven Michael Klose <pixel@copei.de>

(%defun any-quasiquote? (x)
  (? (cons? x)
     (?
       (eq x. 'QUASIQUOTE)         t
       (eq x. 'QUASIQUOTE-SPLICE)  t)))

(%defun %quasiquote-eval (x)
  (eval (car (cdr (car x)))))

(%defun %backquote-quasiquote (x)
  (. (? (any-quasiquote? (car (cdr x.)))
        (%backquote (car (cdr x.)))
        (%quasiquote-eval x))
     (%backquote .x)))

(%defun %backquote-quasiquote-splice (x)
  (? (any-quasiquote? (car (cdr x.)))
     (. (car (cdr x.))
        (%backquote .x))
     (#'((evaluated)
           (?
             (not evaluated)  (%backquote .x)
             (atom evaluated) (error "QUASIQUOTE-SPLICE expects a list instead of ~A." evaluated)
             (%nconc (copy-list evaluated)
                     (%backquote .x))))
       (%quasiquote-eval x))))

(%defun %backquote (x)
        (print x)
  (?
    (atom x) x
    (atom (print x.))                   (. x. (%backquote .x))
    (eq x.. 'QUASIQUOTE)        (%backquote-quasiquote x)
    (eq x.. 'QUASIQUOTE-SPLICE) (%backquote-quasiquote-splice x)
    (. (%backquote x.)
       (%backquote .x))))

(%defun quasiquote (x)
  x
  (%error "QUASIQUOTE (or ',' for short) outside backquote."))

(%defun quasiquote-splice (x)
  x
  (%error "QUASIQUOTE-SPLICE (or ',@' for short) outside backquote."))
