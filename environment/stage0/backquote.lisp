;;;;; tré – Copyright (c) 2006–2014 Sven Michael Klose <pixel@copei.de>

(%defun any-quasiquote? (x)
  (? (cons? x)
     (?
       (eq (car x) 'quasiquote)         t
       (eq (car x) 'quasiquote-splice)  t)))

(%defun %quasiquote-eval (x)
  (eval (car (cdr (car x)))))

(%defun %backquote-quasiquote (x)
  (? (cpr x)
     (setq *default-listprop* (cpr x)))
     (#'((p c)
           (rplacp c p))
       *default-listprop*
       (cons (? (any-quasiquote? (car (cdr (car x))))
                (%backquote (car (cdr (car x))))
                (%quasiquote-eval x))
             (%backquote (cdr x)))))

(%defun %backquote-quasiquote-splice (x)
  (? (any-quasiquote? (car (cdr (car x))))
     (progn
       (? (cpr x)
          (setq *default-listprop* (cpr x)))
       (#'((p c)
             (rplacp c p))
         *default-listprop*
         (cons (car (cdr (car x)))
               (%backquote (cdr x)))))
     (#'((evaluated)
           (?
             (not evaluated)  (%backquote (cdr x))
             (atom evaluated) (error "QUASIQUOTE-SPLICE expects a list instead of ~A." evaluated)
             (%nconc (copy-list evaluated)
                     (%backquote (cdr x)))))
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
          (atom (car x))                        (cons (car x)
                                                      (%backquote (cdr x)))
          (eq 'QUASIQUOTE (car (car x)))        (%backquote-quasiquote x)
          (eq 'QUASIQUOTE-SPLICE (car (car x))) (%backquote-quasiquote-splice x)
          (cons (%backquote (car x))
                (%backquote (cdr x))))))))

(%defun quasiquote (x)
  x
  (%error "QUASIQUOTE (or ',' for short) outside backquote."))

(%defun quasiquote-splice (x)
  x
  (%error "QUASIQUOTE-SPLICE (or ',@' for short) outside backquote."))
