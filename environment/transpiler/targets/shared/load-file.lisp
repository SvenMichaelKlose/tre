(defun load-file-stream (s)
  (with-queue q
    (while (seek-char s)
           (queue-list q)
      (alet (read s)
        (? (cons? !)
           (?
             (eq 'defpackage !.)  (eval `(cl:defpackage ,@.!))
             (eq 'in-package !.)  (= *package* (make-symbol (symbol-name .!.)))
             (enqueue q !))
           (enqueue q !))))))

(defun load-file (name)
  (with-open-file s (open name :direction 'input)
    (load-file-stream s)))

(defun load-string (x)
  (with-stream-string s x
    (load-file-stream s)))
