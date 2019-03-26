;;;; tré – Copyright (c) 2005,2011–2014 Sven Michael Klose <pixel@hugbox.org>

(defvar *gensym-prefix* "~G")
(defvar *gensym-counter* 0)

;; Returns newly created, unique symbol.
(%defun gensym-number ()
  (setq *gensym-counter* (+ 1 *gensym-counter*)))

(functional gensym)

;; Returns newly created, unique symbol.
(%defun gensym ()
  (#'((x)
       (? (eq (symbol-value x) x)
          (? (symbol-function x)
             (gensym)
             x)
          (gensym)))
     (make-symbol (string-concat *gensym-prefix* (string (gensym-number))))))
