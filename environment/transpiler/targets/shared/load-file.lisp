(fn load-file-stream (s)
  (with-queue q
    (while (seek-char s)
           (queue-list q)
      (!= (read s)
        (? (cons? !)
           (?
             (eq 'defpackage !.)  (eval (transpiler-macroexpand `(defpackage ,@.!)))
             (eq 'in-package !.)  (eval (transpiler-macroexpand `(in-package ,@.!)))))
        (enqueue q !)))))

(fn load-file (name)
  (with-open-file s (open name :direction 'input)
    (load-file-stream s)))

(fn load-string (x)
  (with-stream-string s x
    (load-file-stream s)))
