;;;;; tré – Copyright (c) 2005–2008,2012–2013 Sven Michael Klose <pixel@copei.de>

(setq *universe*
	  (cons 'early-defun
	  (cons 'print-definition
	  (cons 'defvar
	  (cons 'defconstant
		    *universe*)))))

(setq *defined-functions*
	  (cons 'print-definition
		    *defined-functions*))

(setq *variables*
	  (cons (cons '*definition-printer* nil)
		    *variables*))

(setq *definition-printer* #'print)

(%set-atom-fun print-definition
  #'((x)
       (? *show-definitions?*
          (apply *definition-printer* (list x)))))

(%set-atom-fun early-defun
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
