(defvar *tre-revision* 0)
;    ,(with-open-file in (open "environment/_current-version" :direction 'input)
;       (let l (string-list (read-line in))
;         (list-string
;           (alet (subseq l
;                         (!? (position #\: l)
;                             (++ !)
;                             0)
;                         (-- (length l)))
;             (? (== #\M (car (last !)))
;                (butlast !)
;                !))))))

(format t "; Revision ~A.~%" *tre-revision*)
