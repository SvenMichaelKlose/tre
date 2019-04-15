(var *gensym-counter* 0)

;; Returns newly created, unique symbol.
(%fn gensym-number ()
  (setq *gensym-counter* (+ 1 *gensym-counter*)))

(functional gensym)

;; Returns newly created, unique symbol.
(%fn gensym (&optional (prefix "~G"))
  (#'((x)
       (? (eq (symbol-value x) x)
          (? (symbol-function x)
             (gensym)
             x)
          (gensym)))
     (make-symbol (string-concat prefix (string (gensym-number))))))
