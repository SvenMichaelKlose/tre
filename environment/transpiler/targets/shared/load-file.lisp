(defun load-file (name)
  (with-open-file s (open name :direction 'input)
    (with-queue q
      (while (seek-char s)
             (queue-list q)
        (alet (read s)
          (? (cons? !)
             (?
               (eq 'defpackage !.)  (eval `(cl:defpackage ,@.!))
               (eq 'in-package !.)  (= *package* (make-symbol (symbol-name .!.)))
               (enqueue q !))
             (enqueue q !)))))))
