;;;; TRE environment
;;;; Copyright (C) 2005 Sven Klose <pixel@copei.de>
;;;;
;;;; Generic symbols for use inside macros.

(defvar *gensym-counter* 0)

;; Returns newly created, unique symbol.
(%defun gensym-number ()
  (setq *gensym-counter* (+ 1 *gensym-counter*)))

(functional gensym)

;; Returns newly created, unique symbol.
(%defun gensym ()
  (make-symbol (string-concat "~G" (string (gensym-number)))))
