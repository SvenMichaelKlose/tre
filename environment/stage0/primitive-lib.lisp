; tré – Copyright (c) 2005–2014,2016 Sven Michael Klose <pixel@hugbox.org>

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
