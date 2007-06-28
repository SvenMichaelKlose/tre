;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (c) 2005-2007 Sven Klose <pixel@copei.de>

(setq *universe* (cons '%defun
                 (cons '%defspecial
                 (cons 'defvar *universe*))))

(%set-atom-fun %defun
  (macro (name args &rest body)
    `(block nil
       (setq *universe* (cons ',name *universe*))
       (%set-atom-fun ,name
         #'(lambda ,args ,@body)))))

(%set-atom-fun %defspecial
  (macro (name args &rest body)
    `(block nil
       (setq *universe* (cons ',name *universe*))
       (%set-atom-fun ,name
         (special ,args ,@body)))))

(%set-atom-fun defvar
  (macro (name &optional (init nil))
    `(block nil
       (setq *universe* (cons ',name *universe*))
       (setq ,name ,init))))
