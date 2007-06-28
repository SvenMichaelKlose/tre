;;;; nix operating system project
;;;; list processor environment
;;;; Copyright (C) 2005 Sven Klose <pixel@copei.de>
;;;;
;;;; Generic symbols for use inside macros.

(defvar *gensym-counter* 0)

;; Returns newly created, unique symbol.
(%defun gensym ()
  (progn
    (setq *gensym-counter* (+ 1 *gensym-counter*))
    (make-symbol (string-concat "~G" (string *gensym-counter*)))))
