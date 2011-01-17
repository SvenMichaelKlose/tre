;;;;; TRE environment
;;;;; Copyright (c) 2009,2011 Sven Klose <pixel@copei.de>

(defvar *tre-revision*
    ,(with-open-file in (open "_current-version" :direction 'input)
       (let l (string-list (read-line in))
         (list-string (subseq l
                              (aif (position #\: l)
                                   (1+ !)
                                   0)
                              (1- (length l)))))))
