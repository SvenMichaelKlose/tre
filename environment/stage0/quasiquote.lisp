(%fn %quasiquote-expand (x)
  (?
    (atom x)                     x
    (atom x.)                    (. x. (%quasiquote-expand .x))
    (eq x.. 'quote)              (. x. (%quasiquote-expand .x))
    (eq x.. 'backquote)          (. x. (%quasiquote-expand .x))
    (eq x.. 'quasiquote)         (. (eval (macroexpand (car (cdr x.))))
                                    (%quasiquote-expand .x))
    (eq x.. 'quasiquote-splice)  (append (eval (macroexpand (car (cdr x.))))
                                         (%quasiquote-expand .x))
    (. (%quasiquote-expand x.)
       (%quasiquote-expand .x))))

(%fn quasiquote-expand (x)
  (car (%quasiquote-expand (list x))))

(%defvar *quasiquote-expand* #'quasiquote-expand)
