; QUASIQUOTEs outside BACKQUOTEs are treated here. They serve as anonymous macros.

(%defun any-quasiquote? (x)
  (? (cons? x)
     (?
       (eq x. 'QUASIQUOTE)         t
       (eq x. 'QUASIQUOTE-SPLICE)  t)))

(%defun %quasiquote-expand (x)
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

(%defun quasiquote-expand (x)
  (car (%quasiquote-expand (list x))))

(%defvar *quasiquote-expand* #'quasiquote-expand)
