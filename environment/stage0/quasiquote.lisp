;;;; TRE environment
;;;; Copyright (c) 2008-2009 Sven Klose <pixel@copei.de>
;;;;
;;;; This expansion takes place after macro expansion to allow
;;;; inlining generated code without need to define macros.

(setq
	*UNIVERSE*
	(cons 'quasiquote-expand
	 	  *UNIVERSE*))

(setq
	*defined-functions*
	(cons '%quasiquote-expand
	(cons 'quasiquote-expand
	 	  *defined-functions*)))

(%set-atom-fun %quasiquote-expand
  #'((x)
	   (if
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
