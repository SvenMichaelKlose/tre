;;;; TRE environment Copyright (c) 2005,2011 Sven Klose <pixel@copei.de>

(defvar *gensym-prefix* "~G")
(defvar *gensym-counter* 0)

;; Returns newly created, unique symbol.
(%defun gensym-number ()
  (setq *gensym-counter* (+ 1 *gensym-counter*)))

(functional gensym)

;; Returns newly created, unique symbol.
(%defun gensym ()
  (make-symbol (string-concat *gensym-prefix* (string (gensym-number)))))
