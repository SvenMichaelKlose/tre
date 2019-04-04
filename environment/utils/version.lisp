(var *tre-revision* 
     ,(with-open-file in (open "environment/_current-version" :direction 'input)
        (read-number in)))
