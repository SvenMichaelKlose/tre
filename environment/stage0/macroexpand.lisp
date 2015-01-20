; tré – Copyright (c) 2006–2009,2012–2014 Sven Michael Klose <pixel@copei.de>

(%defvar *macros* nil)
(%defvar *macro?-diversion* nil)
(%defvar *macrocall-diversion* nil)
(%defvar *current-macro* nil)
(%defvar *macroexpand-backquote-diversion* nil)
(%defvar *macroexpand-print?* nil)

(%defun %macroexpand-backquote (x)
  (?
    (atom x)                    x
    (atom x.)                   (. x. (%macroexpand-backquote .x))
    (eq x.. 'QUASIQUOTE)        (. (. 'QUASIQUOTE
                                      (%macroexpand (cdr x.)))
                                   (%macroexpand-backquote .x))
    (eq x.. 'QUASIQUOTE-SPLICE) (. (. 'QUASIQUOTE-SPLICE
                                      (%macroexpand (cdr x.)))
                                   (%macroexpand-backquote .x))
    (. (%macroexpand-backquote x.)
       (%macroexpand-backquote .x))))

(setq *macroexpand-backquote-diversion* #'%macroexpand-backquote)

(%defun %macroexpand-rest (x)
  (? (atom x)
     x
     (. (%macroexpand x.)
        (%macroexpand-rest .x))))

(%defun %macroexpand-xlat (x)
  (? *macroexpand-print?*
     (progn
       (print '*macroexpand-print?*)
       (print x)))
  (setq *current-macro* x.)
  (#'((x)
        (? *macroexpand-print?*
           (print x))
        (setq *current-macro* nil)
        x)
    (apply *macrocall-diversion* (list x))))

(%defun %macroexpand-call (x)
  (? (apply *macro?-diversion* (list x))
     (%macroexpand-xlat x)
     x))

(%defun %macroexpand (x)
  (?
    (atom x)                   x
    (eq x. 'QUOTE)             x
    (eq x. 'BACKQUOTE)         (. 'BACKQUOTE (apply *macroexpand-backquote-diversion* (list .x)))
    (eq x. 'QUASIQUOTE)        (. 'QUASIQUOTE (%macroexpand .x))
    (eq x. 'QUASIQUOTE-SPLICE) (. 'QUASIQUOTE-SPLICE (%macroexpand .x))
    (%macroexpand-call (%macroexpand-rest x))))

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
