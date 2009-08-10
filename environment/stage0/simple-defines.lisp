;;;; TRE environment
;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>

(setq
	*universe*
	(cons '%defun
	(cons '%defspecial
	(cons 'defvar
	(cons 'defconstant
		  *universe*)))))

(setq
	*defined-functions*
	(cons '%defun
	(cons '%defspecial
		  *defined-functions*)))

(%set-atom-fun %defun
  (macro (name args &rest body)
    `(block nil
       (setq *universe* (cons ',name *universe*))
       (setq *defined-functions* (cons ',name *defined-functions*))
       (%set-atom-fun ,name
         #'(,args ,@body)))))

(%set-atom-fun %defspecial
  (macro (name args &rest body)
    `(block nil
       (setq *universe* (cons ',name *universe*))
       (%set-atom-fun ,name
         (special ,args ,@body)))))

(%set-atom-fun defvar
  (macro (name &optional (init nil))
    `(progn
	   (if *show-definitions*
	       (print `(defvar ,name)))
	   (setq *universe* (cons ',name *universe*)
		     *variables* (cons (cons ',name
								     ',init)
							   *variables*)
             ,name ,init))))

(defvar *constants* nil)

(%set-atom-fun defconstant
  (macro (name &optional (init nil))
    `(progn
	   (if *show-definitions*
	       (print `(defconstant ,name)))
	   (defvar ,name ,init)
	   (setq *constants* (cons ',name *constants*)))))
