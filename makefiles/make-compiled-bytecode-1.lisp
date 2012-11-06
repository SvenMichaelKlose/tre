(defvar *bla* nil)

(defun bc-test ()
  (format t "klkjhlkjhkljhkljhklhklhj")
  (with (a nil
         rec #'((b)
                 (= *bla* b)
                 (= a (+ 1 2))))
    (rec 1)))
