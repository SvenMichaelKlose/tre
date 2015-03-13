; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

(defun tre2cl (x)
  (make-lambdas (quote-expand (specialexpand (quote-expand x)))))

(defbuiltin eval (x)
  (cl:eval (tre2cl x)))
