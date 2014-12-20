;;;; tré – Copyright (c) 2006–2014 Sven Michael Klose <pixel@copei.de>

(%defun any-quasiquote? (x)
  (? (cons? x)
     (?
       (eq x. 'quasiquote)         t
       (eq x. 'quasiquote-splice)  t)))

(%defun %quasiquote-eval (x)
  (eval (car (cdr (car x)))))

(%defun %backquote-quasiquote (x)
  (? (cpr x)
     (setq *default-listprop* (cpr x)))
     (#'((p c)
           (rplacp c p))
       *default-listprop*
       (. (? (any-quasiquote? (car (cdr x.)))
             (%backquote (car (cdr x.)))
             (%quasiquote-eval x))
          (%backquote .x))))

(%defun %backquote-quasiquote-splice (x)
  (? (any-quasiquote? (car (cdr x.)))
     (progn
       (? (cpr x)
          (setq *default-listprop* (cpr x)))
       (#'((p c)
             (rplacp c p))
         *default-listprop*
         (. (car (cdr x.))
            (%backquote .x))))
     (#'((evaluated)
           (?
             (not evaluated)  (%backquote .x)
             (atom evaluated) (error "QUASIQUOTE-SPLICE expects a list instead of ~A." evaluated)
             (%nconc (copy-list evaluated)
                     (%backquote .x))))
       (%quasiquote-eval x))))

;; Expand BACKQUOTE arguments.
(%defun %backquote (x)
  (?
    (atom x) x
    (progn
      (? (cpr x)
         (setq *default-listprop* (cpr x)))
      (#'((p c)
            (? (cons? c)
               (rplacp c (setq *default-listprop* p))))
        *default-listprop*
        (?
          (atom x.)                    (. x. (%backquote .x))
          (eq 'QUASIQUOTE x..)         (%backquote-quasiquote x)
          (eq 'QUASIQUOTE-SPLICE x..)  (%backquote-quasiquote-splice x)
          (. (%backquote x.)
             (%backquote .x)))))))

(%defun quasiquote (x)
  x
  (%error "QUASIQUOTE (or ',' for short) outside backquote."))

(%defun quasiquote-splice (x)
  x
  (%error "QUASIQUOTE-SPLICE (or ',@' for short) outside backquote."))
