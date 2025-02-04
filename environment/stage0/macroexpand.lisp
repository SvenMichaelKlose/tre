; All macros defined in the host environment.
(%defvar *macros* nil)

; Predicate if symbol belongs to a named macro.
(%defvar *macro?* nil)

; Function currently expanding a macro.
(%defvar *macrocall* nil)

; Current version of MACROEXPAND.
(%defvar *macroexpand* nil)

(%fn %macroexpand-backquote (x)
  (?
    (atom x) x
    (atom x.)
      (. x. (%macroexpand-backquote .x))
    (eq x.. 'quasiquote)
      (. (. 'quasiquote (%macroexpand (cdr x.)))
         (%macroexpand-backquote .x))
    (eq x.. 'quasiquote-splice)
      (. (. 'quasiquote-splice (%macroexpand (cdr x.)))
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
    (atom x) x
    (apply *macro?* (list x))
      (#'((x)
           (? (cons? x)
              (. x. (%macroexpand-rest .x))
              x))
        (apply *macrocall* (list x)))
    (eq x. 'quote) x
    (eq x. 'backquote)
      (. 'backquote (apply *macroexpand-backquote* (list .x)))
    (eq x. 'quasiquote)
      (. 'quasiquote (%macroexpand .x))
    (eq x. 'quasiquote-splice)
      (. 'quasiquote-splice (%macroexpand .x))
    (. (%macroexpand x.)
       (%macroexpand-rest .x))))

(%fn native-macroexpand (x)
  (#'((predicate caller)
        (setq *macro?*         #'%%macro?
              *macrocall*      #'%%macrocall)
        (#'((x)
              (setq *macro?*         predicate
                    *macrocall*      caller)
              x)
          (%macroexpand x)))
     *macro?* *macrocall*))

(setq *macroexpand* #'native-macroexpand)
