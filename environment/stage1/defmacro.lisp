;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>
;;;;
;;;; Macro definition

(defvar *documentation* nil)

(%defun %add-documentation (name body)
  (cond
    ((stringp (car body))
      (progn
        (setq *documentation* (cons (cons name (car body)) *documentation*))
        (cdr body)))
    (t body)))

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
