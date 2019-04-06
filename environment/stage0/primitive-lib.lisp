(%defun identity (x) x)
(%defun list (&rest x) x)
(%defun funcall (fun &rest x) (apply fun x))

(%defun + (&rest x)
  (#'((a)
        (? a
           (apply (?
                    (cons? a)   #'append
                    (string? a) #'string-concat
                    #'number+)
                  x)
           (? .x
              (apply #'+ .x))))
    x.))
