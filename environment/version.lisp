(var *tre-revision* 
     ,(with-open-file in (open "environment/_current-version" :direction 'input)
        (+ 3291 ; Repository 'tre-historic'.
           (read-number in))))
