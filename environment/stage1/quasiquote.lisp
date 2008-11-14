;;;; TRE environment
;;;; Copyright (c) 2008 Sven Klose <pixel@copei.de>
;;;;
;;;; QUASIQUOTE expansion
;;;;
;;;; This expansion takes place after macro expansion to allow
;;;; inlining generated code without need to define macros.

(setq *UNIVERSE* (cons 'quasiquote-expand
				 	   *UNIVERSE*))

(%set-atom-fun %quasiquote-expand
  #'((x)
	   (cond
		  ((atom x) x)
			 ((atom (car x))
				(cons (car x)
					  (%quasiquote-expand (cdr x))))
			 ((eq (car (car x)) 'quote)
				(cons (car x)
					  (%quasiquote-expand (cdr x))))
			 ((eq (car (car x)) 'backquote)
				(cons (car x)
					  (%quasiquote-expand (cdr x))))

			 ((eq (car (car x)) 'quasiquote)
				(cons (eval (cadar x))
					  (%quasiquote-expand (cdr x))))
			 ((eq (car (car x)) 'quasiquote-splice)
				(append (eval (cadar x))
						(%quasiquote-expand (cdr x))))

			 (t (cons (%quasiquote-expand (car x))
					  (%quasiquote-expand (cdr x)))))))

(%set-atom-fun quasiquote-expand
  #'((x)
	   (car (%quasiquote-expand (list x)))))

(%set-atom-fun *QUASIQUOTEEXPAND-HOOK* #'quasiquote-expand)
