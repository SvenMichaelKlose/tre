;;;;; tré – Copyright (c) 2005–2008,2012 Sven Michael Klose <pixel@copei.de>

(setq *universe*
	  (cons '%defun
	  (cons 'defvar
	  (cons 'defconstant
		    *universe*))))

(setq *defined-functions*
	  (cons '%defun
		    *defined-functions*))

(%set-atom-fun print-definition
  #'((x)
       (? *show-definitions?*
          (? #'late-print
             (late-print x)
             (print x)))))

(%set-atom-fun %defun
  (macro (name args &rest body)
    `(block nil
       (setq *universe* (cons ',name *universe*))
       (setq *defined-functions* (cons ',name *defined-functions*))
       (%set-atom-fun ,name
         #'(,args ,@body)))))

(%set-atom-fun defvar
  (macro (name &optional (init nil))
	(print-definition `(defvar ,name))
    `(setq *universe* (cons ',name *universe*)
		   *variables* (cons (cons ',name
								   ',init)
							 *variables*)
           ,name ,init)))

(defvar *constants* nil)

(%set-atom-fun defconstant
  (macro (name &optional (init nil))
	(print-definition `(defconstant ,name))
    `(progn
	   (defvar ,name ,init)
	   (setq *constants* (cons (cons ',name
								     ',init)
							   *constants*)
           ,name ,init))))
