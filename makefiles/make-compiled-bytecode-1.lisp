(defun fnord ()
  (= *milestone* t)
  (with (rec (fn print _))
    (rec 65)))
