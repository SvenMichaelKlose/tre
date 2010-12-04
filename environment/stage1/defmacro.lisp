;;;;; TRE environment
;;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>

(defvar *documentation* nil)
(defvar *macros* nil)

(%defun %add-documentation (name body)
  (if (stringp (car body)) ; XXX incomplete
      (progn
        (setq *documentation* (cons (cons name
										  (car body))
									*documentation*))
        (cdr body))
      body))

(setq *universe* (cons 'defmacro *universe*))

(%set-atom-fun defmacro
  (macro (name args &rest body)
    `(block nil
	   (if *show-definitions*
           (print `(defmacro ,name)))
       (setq *universe* (cons ',name *universe*))
       (setq *macros* (cons ',name *macros*))
       (%set-atom-fun ,name
         			  (macro ,args
	       			    (block ,name
	         			  ,@(%add-documentation name body)))))))
