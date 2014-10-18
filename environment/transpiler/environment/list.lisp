;;;;; tré – Copyright (c) 2008–2014 Sven Michael Klose <pixel@copei.de>

(declare-cps-exception list-length)

(defun list-length (x)
  (let len 0
    (while (cons? x)
           len
      (= x .x)
      (++! len))))

(defun last (x)
  (& x
     (? .x
        (last .x)
        x)))
