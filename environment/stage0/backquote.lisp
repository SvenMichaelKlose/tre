;;;;; tré – Copyright (c) 2006–2014 Sven Michael Klose <pixel@copei.de>

(%defun any-quasiquote? (x)
       (? (cons? x)
          (?
            (eq (car x) 'quasiquote)         t
            (eq (car x) 'quasiquote-splice)  t)))

(%defun %quasiquote-eval (%gsbq)
  (eval (car (cdr (car %gsbq)))))

(%defun %backquote-quasiquote (%gsbq)
       (? (cpr %gsbq)
          (setq *default-listprop* (cpr %gsbq)))
       (#'((p c)
             (rplacp c p))
         *default-listprop*
         (cons (? (any-quasiquote? (car (cdr (car %gsbq))))
                  (%backquote (car (cdr (car %gsbq))))
                  (%quasiquote-eval %gsbq))
               (%backquote (cdr %gsbq)))))

(%defun %backquote-quasiquote-splice (%gsbq)
       (? (any-quasiquote? (car (cdr (car %gsbq))))
          (progn
            (? (cpr %gsbq)
               (setq *default-listprop* (cpr %gsbq)))
            (#'((p c)
                  (rplacp c p))
              *default-listprop*
              (cons (car (cdr (car %gsbq)))
                    (%backquote (cdr %gsbq)))))
          (#'((%gstmp)
                (?
                  (not %gstmp)  (%backquote (cdr %gsbq))
                  (atom %gstmp) (error "QUASIQUOTE-SPLICE expects a list instead of ~A." %gstmp)
                  (%nconc (copy-list %gstmp)
                          (%backquote (cdr %gsbq)))))
            (%quasiquote-eval %gsbq))))

;; Expand BACKQUOTE arguments.
(%defun %backquote (%gsbq)
       (?
         (atom %gsbq) %gsbq
         (progn
           (? (cpr %gsbq)
              (setq *default-listprop* (cpr %gsbq)))
           (#'((p c)
                 (? (cons? c)
                    (rplacp c (setq *default-listprop* p))))
             *default-listprop*
             (?
               (atom (car %gsbq))                        (cons (car %gsbq)
                                                               (%backquote (cdr %gsbq)))
               (eq 'QUASIQUOTE (car (car %gsbq)))        (%backquote-quasiquote %gsbq)
               (eq 'QUASIQUOTE-SPLICE (car (car %gsbq))) (%backquote-quasiquote-splice %gsbq)
               (cons (%backquote (car %gsbq))
                     (%backquote (cdr %gsbq))))))))

(%defun quasiquote (x)
  x
  (%error "QUASIQUOTE (or ',' for short) outside backquote."))

(%defun quasiquote-splice (x)
  x
  (%error "QUASIQUOTE-SPLICE (or ',@' for short) outside backquote."))
