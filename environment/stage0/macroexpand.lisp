;;;;; tré – Copyright (c) 2006–2009,2012–2014 Sven Michael Klose <pixel@copei.de>

(%defvar *macro?-diversion* nil)
(%defvar *macrocall-diversion* nil)
(%defvar *current-macro* nil)
(%defvar *macroexpand-backquote-diversion* nil)
(%defvar *macroexpand-print?* nil)

(%defun %macroexpand-backquote (x)
  (?
    (atom x) x
    (atom (car x))
        (cons (car x)
              (%macroexpand-backquote (cdr x)))

    (eq (car (car x)) 'QUASIQUOTE)
        (cons (cons 'QUASIQUOTE
                    (%macroexpand (cdr (car x))))
              (%macroexpand-backquote (cdr x)))

    (eq (car (car x)) 'QUASIQUOTE-SPLICE)
        (cons (cons 'QUASIQUOTE-SPLICE
                    (%macroexpand (cdr (car x))))
              (%macroexpand-backquote (cdr x)))

    (cons (%macroexpand-backquote (car x))
          (%macroexpand-backquote (cdr x)))))

(setq *macroexpand-backquote-diversion* #'%macroexpand-backquote)

(%defun %macroexpand-rest (x)
  (? (atom x)
     x
     (cons (%macroexpand (car x))
           (%macroexpand-rest (cdr x)))))

(%defun %macroexpand-xlat (x)
  (? *macroexpand-print?*
     (progn
       (print '*macroexpand-print?*)
       (print x)))
  (setq *current-macro* (car x))
  (#'((x)
        (? *macroexpand-print?*
           (print x))
        (setq *current-macro* nil)
        x)
    (apply *macrocall-diversion* (list x))))

(%defun %macroexpand-call (x)
  (? (? (atom (car x))
        (apply *macro?-diversion* (list x)))
     (%macroexpand-xlat x)
     x))

(%defun %macroexpand (x)
  (?
    (atom x) x
    (eq (car x) 'QUOTE)             x
    (eq (car x) 'BACKQUOTE)         (cons 'BACKQUOTE
                                           (apply *macroexpand-backquote-diversion* (list (cdr x))))
    (eq (car x) 'QUASIQUOTE)        (cons 'QUASIQUOTE
                                           (%macroexpand (cdr x)))
    (eq (car x) 'QUASIQUOTE-SPLICE) (cons 'QUASIQUOTE-SPLICE
                                           (%macroexpand (cdr x)))
    (%macroexpand-call (%macroexpand-rest x))))

(%defun %%macro? (x)
  (? (symbol? (car x))
     (%%%macro? (car x))))

(%defun %%env-macro? (x)
  (%%macro? x))

(%defun %%env-macrocall (x)
  (%%macrocall x))

(%defun native-macroexpand (x)
  (#'((predicate caller current-macro)
        (setq *macro?-diversion*    #'%%macro?
              *macrocall-diversion* #'%%macrocall
              *current-macro*       nil)
        (#'((x)
              (setq *macro?-diversion*    predicate
                    *macrocall-diversion* caller
                    *current-macro*       current-macro)
              x)
          (%macroexpand x)))
     *macro?-diversion* *macrocall-diversion* *current-macro*))

(setq *macroexpand-hook* #'native-macroexpand)
