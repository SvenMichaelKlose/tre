;;;;; tré – Copyright (c) 2005–2008,2012–2014 Sven Michael Klose <pixel@copei.de>

(%defvar *definition-printer* #'print)

(%defun print-definition (x)
  (? *show-definitions?*
     (apply *definition-printer* (list x))))

(%defmacro defvar (name &optional (init nil))
  (print-definition `(defvar ,name))
  `(setq *universe* (cons ',name *universe*)
         *variables* (cons (cons ',name ',init) *variables*)
         ,name ,init))

(defvar *constants* nil)

(%defmacro defconstant (name &optional (init nil))
  (print-definition `(defconstant ,name))
  `(progn
     (defvar ,name ,init)
     (setq *constants* (cons (cons ',name ',init) *constants*)
           ,name ,init)))
