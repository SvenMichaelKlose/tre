;;;;; tré – Copyright (c) 2005–2008,2011–2013 Sven Michael Klose <pixel@copei.de>

(defvar *documentation* nil)
(defvar *macros* nil)

(early-defun %add-documentation (name body)
  (? (? (string? (car body))
        (cdr body))
     (progn
       (setq *documentation* (cons (cons name (car body)) *documentation*))
       (cdr body))
     body))

(setq *universe* (cons 'defmacro *universe*))

(%set-atom-fun defmacro
  (macro (name args &body body)
    `(block nil
	   (print-definition `(defmacro ,name ,args))
       (setq *universe* (cons ',name *universe*))
       (setq *macros* (cons ',name *macros*))
       (%set-atom-fun ,name
         			  (macro ,args
	       			    (block ,name
	         			  ,@(%add-documentation name body)))))))
