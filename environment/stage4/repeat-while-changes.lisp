(defun repeat-while-changes (fun x)
  (awhile (funcall fun x)
          x
    (!? (equal x !)
        (return x))
    (= x !)))
