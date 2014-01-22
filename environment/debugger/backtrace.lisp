;;;;; tré – Copyright (c) 2013 Sven Michael Klose <pixel@copei.de>

(defvar *backtrace* nil)

(defun backtrace ()
  (with (print-repetition
             #'((x repetitions)
                  (format t "~A (~A times) " (symbol-name x.) (++ repetitions))
                  (rec .x nil 0))
         rec #'((x former repetitions)
                  (?
                    x
                      (?
                        (eq x. former)      (rec .x former (++ repetitions))
                        (zero? repetitions) (format t "~A " (symbol-name x.))
                        (print-repetition (list former) repetitions))
                    (not (zero? repetitions))
                      (print-repetition (list former) repetitions))))
    (format t "Backtrace: ")
    (rec (copy-list *backtrace*) nil 0)))
