; tré – Copyright (c) 2014–2015 Sven Michael Klose <pixel@hugbox.org>

(defun tre2cl (x)
  (make-lambdas (quote-expand (specialexpand (quote-expand x)))))

(defvar *eval* nil)

(defbuiltin eval (x)
  (cl:eval (= *eval* (tre2cl x))))
