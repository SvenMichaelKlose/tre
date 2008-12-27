;;;;; TRE environment
;;;;; Copyright (c) 2005-2008 Sven Klose <pixel@copei.de>
;;;;;
;;;;; Macro definition

(defvar *documentation* nil)

(%defun %add-documentation (name body)
  (if (stringp (car body)) ; XXX incomplete
      (progn
        (setq *documentation* (cons (cons name
										  (car body))
									*documentation*))
        (cdr body))
      body))

(setq *universe* (cons 'defmacro *universe*))

;; Define a special form 'macro' surrogate.
(%set-atom-fun defmacro
  (macro (name args &rest body)
    `(block nil
       (setq *universe* (cons ',name *universe*))
       (%set-atom-fun ,name
         			  (macro ,args
	       			    (block ,name
	         			  ,@(%add-documentation name body)))))))
