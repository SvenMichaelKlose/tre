;;;;; tré – Copyright (c) 2005–2009,2011–2014 Sven Michael Klose <pixel@copei.de>

(functional append)

(defun append (&rest lists)
  (when lists
    (let f nil
      (let l nil
        (dolist (i lists f)
          (when i
            (? l
               (setq l (last (rplacd l (copy-list i))))
               (setq f (copy-list i)
                     l (last f)))))))))

(defmacro append! (place &rest args)
  `(= ,place (append ,place ,@args)))

(define-test "APPEND works with two lists"
  ((append '(l i) '(s p)))
  '(l i s p))

(define-test "APPEND works with empty lists"
  ((append nil '(l i) nil '(s p) nil))
  '(l i s p))

(define-test "APPEND works with three lists"
  ((append '(i) '(l i k e) '(l i s p)))
  '(i l i k e l i s p))

(define-test "APPEND copies last"
  ((let tmp '(s)
     (eq tmp (cdr (append '(l) tmp)))))
  nil)
