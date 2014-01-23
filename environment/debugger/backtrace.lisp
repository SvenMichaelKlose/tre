;;;;; tré – Copyright (c) 2013–2014 Sven Michael Klose <pixel@copei.de>

(defvar *backtrace* nil)

(defun backtrace (&optional (str))
  (with-default-stream s str)
    (with (print-repetition
               #'((former next repetitions)
                    (format s "~A (~A times) " former repetitions)
                    (f next nil 0))
           f #'((x former repetitions)
                  (? (not x)
                     (| (zero? repetitions)
                        (print-repetition x repetitions))))
                     (?
                       (eq x. former)       (f .x former (++ repetitions))
                       (zero? repetitions)  (format s "~A " x.)
                       (print-repetition x repetitions))
      (format s "Backtrace: ")
      (f (copy-list *backtrace*) nil 0))))
