;;;;; tré – Copyright (c) 2008–2009,2012 Sven Michael Klose <pixel@copei.de>

;;;; QUASIQUOTEs outside BACKQUOTEs are treated here. They serve as
;;;; anonymous macros.

(setq *UNIVERSE*
	  (cons 'quasiquote-expand
	 	    *UNIVERSE*))

(setq *defined-functions*
	  (cons '%quasiquote-expand
	  (cons 'quasiquote-expand
	 	    *defined-functions*)))

(%set-atom-fun %quasiquote-expand
  #'((x)
	   (?
		  (atom x)
			x

		  (atom (car x))
			(cons (car x)
				  (%quasiquote-expand (cdr x)))
		  (eq (car (car x)) 'quote)
			(cons (car x)
				  (%quasiquote-expand (cdr x)))
		  (eq (car (car x)) 'backquote)
			(cons (car x)
				  (%quasiquote-expand (cdr x)))

		  (eq (car (car x)) 'quasiquote)
			(cons (eval (cadar x))
				  (%quasiquote-expand (cdr x)))
		  (eq (car (car x)) 'quasiquote-splice)
			(append (eval (cadar x))
					(%quasiquote-expand (cdr x)))

		  (cons (%quasiquote-expand (car x))
				(%quasiquote-expand (cdr x))))))

(%set-atom-fun quasiquote-expand
  #'((x)
	   (car (%quasiquote-expand (list x)))))

(%set-atom-fun *QUASIQUOTEEXPAND-HOOK* #'quasiquote-expand)
