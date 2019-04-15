(%fn identity (x)
  x)

(%fn list (&rest x)
  x)

(%fn funcall (fun &rest x)
  (apply fun x))

(%fn atom (x)
  (not (cons? x)))

(%fn + (&rest x)
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
