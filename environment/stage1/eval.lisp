;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005-2006 Sven Klose <pixel@copei.de>
;;;;
;;;; Evaluation

(defmacro return (expr)
  `(return-from nil ,expr))

(defun funcall (fun &rest args)
  (apply fun args))

(defmacro prog1 (&rest body)
  (let ((g (gensym)))
    `(let ((,g ,(car body)))
      ,@(cdr body)
      ,g)))
