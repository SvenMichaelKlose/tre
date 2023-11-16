(var *tre-revision* 
     ,(with-open-file in (open "environment/_git-revision" :direction 'input)
        (read-number in)))
