;;;;; tré – Copyright (c) 2008–2009,2012–2013 Sven Michael Klose <pixel@copei.de>

;;;; QUASIQUOTEs outside BACKQUOTEs are treated here. They serve as
;;;; anonymous macros.

(setq *UNIVERSE*
	  (cons 'quasiquote-expand
	 	    *UNIVERSE*))

(setq *defined-functions*
	  (cons '%quasiquote-expand
	  (cons 'quasiquote-expand
	 	    *defined-functions*)))

(%defun %quasiquote-expand (x)
  (?
    (atom x) x
          (progn
            (? (cpr x)
               (setq *default-listprop* (cpr x)))
            (#'((p c) (rplacp c p))
              *default-listprop*
		      (?
                (atom (car x))                 (cons (car x) (%quasiquote-expand (cdr x)))
		        (eq (car (car x)) 'quote)      (cons (car x) (%quasiquote-expand (cdr x)))
		        (eq (car (car x)) 'backquote)  (cons (car x) (%quasiquote-expand (cdr x)))
		        (eq (car (car x)) 'quasiquote) (cons (eval (macroexpand (cadar x))) (%quasiquote-expand (cdr x)))
		        (eq (car (car x)) 'quasiquote-splice) (append (eval (macroexpand (cadar x))) (%quasiquote-expand (cdr x)))
		        (cons (%quasiquote-expand (car x))
				      (%quasiquote-expand (cdr x))))))))

(%defun quasiquote-expand (x)
  (car (%quasiquote-expand (list x))))

(%set-atom-fun *QUASIQUOTEEXPAND-HOOK* #'quasiquote-expand)
