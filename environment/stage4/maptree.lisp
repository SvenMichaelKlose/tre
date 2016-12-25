(defun maptree (fun x)
  (? (atom x)
     (funcall fun x)
     (@ [? (cons? _)
           (funcall fun (maptree fun (funcall fun _)))
           (funcall fun _)]
        x)))
