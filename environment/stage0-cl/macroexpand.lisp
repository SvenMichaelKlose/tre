;;;;; tré – Copyright (c) 2006–2009,2012–2013 Sven Michael Klose <pixel@copei.de>

(%defvar *macro?-diversion* nil)
(%defvar *macrocall-diversion* nil)
(%defvar *current-macro* nil)
(%defvar *macroexpand-backquote-diversion* nil)
(%defvar *macroexpand-print?* nil)

(%defun %macroexpand-backquote (%g)
  (?
    (atom %g) %g
    (atom (car %g))
        (cons (car %g)
              (%macroexpand-backquote (cdr %g)))

    (eq (car (car %g)) 'QUASIQUOTE)
        (cons (cons 'QUASIQUOTE
                    (%macroexpand (cdr (car %g))))
              (%macroexpand-backquote (cdr %g)))

    (eq (car (car %g)) 'QUASIQUOTE-SPLICE)
        (cons (cons 'QUASIQUOTE-SPLICE
                    (%macroexpand (cdr (car %g))))
              (%macroexpand-backquote (cdr %g)))

    (cons (%macroexpand-backquote (car %g))
          (%macroexpand-backquote (cdr %g)))))

(setq *macroexpand-backquote-diversion* #'%macroexpand-backquote)

(%defun %macroexpand-rest (%g)
  (? (atom %g)
     %g
     (cons (%macroexpand (car %g))
           (%macroexpand-rest (cdr %g)))))

(%defun %macroexpand-xlat (%g)
  (? *macroexpand-print?*
     (progn
       (print '*macroexpand-print?*)
       (print %g)))
  (setq *current-macro* (car %g))
  (#'((%g)
        (? *macroexpand-print?*
           (print %g))
        (setq *current-macro* nil)
        %g)
    (apply *macrocall-diversion* (list %g))))

(%defun %macroexpand-call (%g)
  (? (? (atom (car %g))
        (apply *macro?-diversion* (list %g)))
     (%macroexpand-xlat %g)
     %g))

(%defun %macroexpand (%g)
  (?
    (atom %g) %g
    (eq (car %g) 'QUOTE)             %g
    (eq (car %g) 'BACKQUOTE)         (cons 'BACKQUOTE
                                           (apply *macroexpand-backquote-diversion* (list (cdr %g))))
    (eq (car %g) 'QUASIQUOTE)        (cons 'QUASIQUOTE
                                           (%macroexpand (cdr %g)))
    (eq (car %g) 'QUASIQUOTE-SPLICE) (cons 'QUASIQUOTE-SPLICE
                                           (%macroexpand (cdr %g)))
    (%macroexpand-call (%macroexpand-rest %g))))

(%defun %%macro? (%g)
  (? (symbol? (car %g))
     (%%%macro? (car %g))))

(%defun %%env-macro? (%g)
  (%%macro? %g))

(%defun %%env-macrocall (%g)
  (%%macrocall %g))

(%defun native-macroexpand (%g)
  (#'((%gp %gc %gcm)
        (setq *macro?-diversion*    #'%%macro?
              *macrocall-diversion* #'%%macrocall
              *current-macro*       nil)
        (#'((%g)
              (setq *macro?-diversion*    %gp
                    *macrocall-diversion* %gc
                    *current-macro*       %gcm)
              %g)
          (%macroexpand %g)))
     *macro?-diversion* *macrocall-diversion* *current-macro*))

(setq *macroexpand-hook* #'native-macroexpand)
