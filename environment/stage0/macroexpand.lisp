(%defvar *macros* nil)
(%defvar *macro?* nil)
(%defvar *macrocall* nil)
(%defvar *current-macro* nil)
(%defvar *macroexpand* nil)

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

(%defvar *macroexpand-backquote* #'%macroexpand-backquote)

(%defun %macroexpand-rest (x)
  (? (atom x)
     x
     (. (%macroexpand x.)
        (%macroexpand-rest .x))))

(%defun %macroexpand (x)
  (?
    (atom x)                    x
    (apply *macro?* (list x))   (#'((x)
                                     (? (cons? x)
                                        (. x. (%macroexpand-rest .x))
                                        x))
                                 (apply *macrocall* (list x)))
    (eq x. 'QUOTE)              x
    (eq x. 'BACKQUOTE)          (. 'BACKQUOTE (apply *macroexpand-backquote* (list .x)))
    (eq x. 'QUASIQUOTE)         (. 'QUASIQUOTE (%macroexpand .x))
    (eq x. 'QUASIQUOTE-SPLICE)  (. 'QUASIQUOTE-SPLICE (%macroexpand .x))
    (. (%macroexpand x.)
       (%macroexpand-rest .x))))

(%defun native-macroexpand (x)
  (#'((predicate caller current-macro)
        (setq *macro?*         #'%%macro?
              *macrocall*      #'%%macrocall
              *current-macro*  nil)
        (#'((x)
              (setq *macro?*         predicate
                    *macrocall*      caller
                    *current-macro*  current-macro)
              x)
          (%macroexpand x)))
     *macro?* *macrocall* *current-macro*))

(setq *macroexpand* #'native-macroexpand)
