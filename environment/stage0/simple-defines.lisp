;;;;; tré – Copyright (c) 2005–2008,2012–2014 Sven Michael Klose <pixel@copei.de>

(setq *universe*
	  (. 'early-defun
	  (. 'print-definition
	  (. 'defvar
	  (. 'defconstant
         *universe*)))))

(setq *defined-functions*
	  (. 'print-definition
		 *defined-functions*))

(setq *variables*
	  (. (. '*definition-printer* nil)
		 *variables*))

(setq *definition-printer* #'print)

(%set-atom-fun print-definition
  #'((x)
       (? *show-definitions?*
          (apply *definition-printer* (list x)))))

(%set-atom-fun early-defun
  (macro (name args &body body)
    `(block nil
       (setq *universe* (. ',name *universe*))
       (setq *defined-functions* (. ',name *defined-functions*))
       (%set-atom-fun ,name
         #'(,args ,@body)))))

(%set-atom-fun defvar
  (macro (name &optional (init nil))
	(print-definition `(defvar ,name))
    `(setq *universe* (. ',name *universe*)
		   *variables* (. (. ',name
                             ',init)
                          *variables*)
           ,name ,init)))

(defvar *constants* nil)

(%set-atom-fun defconstant
  (macro (name &optional (init nil))
	(print-definition `(defconstant ,name))
    `(progn
       (defvar ,name ,init)
         (setq *constants* (. (. ',name
                                 ',init)
                              *constants*)
               ,name ,init))))
