;;;;; tré – Copyright (c) 2009–2013 Sven Michael Klose <pixel@copei.de>

(defun %=-make-call-to-local-function (x)
  (with-%= place value x
    (expex-body (frontend-1 `((%= ,place (apply ,value. ,(compiled-list .value))))))))

(defun expex-compiled-funcall (x)
  (alet (%=-value x)
    (? (& (cons? !)
          (| (function-expr? !.)
             (funinfo-find *funinfo* !.)))
       (%=-make-call-to-local-function x)
       (list x))))
