;;;;; tré – Copyright (c) 2005–2014 Sven Michael Klose <pixel@copei.de>

(%defun identity (x) x)

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

(%defun - (&rest x)
  (apply #'number- x))
