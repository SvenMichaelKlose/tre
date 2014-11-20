;;;;; tré – Copyright (c) 2008–2009,2012–2014 Sven Michael Klose <pixel@copei.de>

;;;; QUASIQUOTEs outside BACKQUOTEs are treated here. They serve as
;;;; anonymous macros.

(%defun %quasiquote-expand (x)
  (?
    (atom x) x
    (atom (car x))                 (cons (car x) (%quasiquote-expand (cdr x)))
	(eq (car (car x)) 'quote)      (cons (car x) (%quasiquote-expand (cdr x)))
	(eq (car (car x)) 'backquote)  (cons (car x) (%quasiquote-expand (cdr x)))
	(eq (car (car x)) 'quasiquote) (cons (eval (macroexpand (car (cdr (car x)))))
                                         (%quasiquote-expand (cdr x)))
	(eq (car (car x)) 'quasiquote-splice) (append (eval (macroexpand (car (cdr (car x)))))
                                                  (%quasiquote-expand (cdr x)))
	(cons (%quasiquote-expand (car x))
		  (%quasiquote-expand (cdr x)))))

(%defun quasiquote-expand (x)
  (car (%quasiquote-expand (list x))))

(setq *QUASIQUOTEEXPAND-HOOK* #'quasiquote-expand)
