(functional equal)

(defun equal (x y)
  (?
	(| (atom x)
       (atom y))   (eql x y)
    (equal x. y.)  (equal .x .y)))
