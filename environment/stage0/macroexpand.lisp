(%defvar *macros* nil)
(%defvar *macro?* nil)
(%defvar *macrocall* nil)
(%defvar *current-macro* nil)
(%defvar *macroexpand* nil)

(%fn %macroexpand-backquote (x)
  (?
    (atom x)                     x
    (atom x.)                    (. x. (%macroexpand-backquote .x))
    (eq x.. 'quasiquote)         (. (. 'quasiquote
                                       (%macroexpand (cdr x.)))
                                    (%macroexpand-backquote .x))
    (eq x.. 'quasiquote-splice)  (. (. 'quasiquote-splice
                                       (%macroexpand (cdr x.)))
                                    (%macroexpand-backquote .x))
    (. (%macroexpand-backquote x.)
       (%macroexpand-backquote .x))))

(%defvar *macroexpand-backquote* #'%macroexpand-backquote)

(%fn %macroexpand-rest (x)
  (? (atom x)
     x
     (. (%macroexpand x.)
        (%macroexpand-rest .x))))

(%fn %macroexpand (x)
  (?
    (atom x)                    x
    (apply *macro?* (list x))   (#'((x)
                                     (? (cons? x)
                                        (. x. (%macroexpand-rest .x))
                                        x))
                                 (apply *macrocall* (list x)))
    (eq x. 'quote)              x
    (eq x. 'backquote)          (. 'backquote (apply *macroexpand-backquote* (list .x)))
    (eq x. 'quasiquote)         (. 'quasiquote (%macroexpand .x))
    (eq x. 'quasiquote-splice)  (. 'quasiquote-splice (%macroexpand .x))
    (. (%macroexpand x.)
       (%macroexpand-rest .x))))

(%fn native-macroexpand (x)
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
