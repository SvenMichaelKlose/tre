(defun clone-element-array (x)  ; TODO: Move to application that uses this.
  (let ret (make-array)
    (doarray (i x ret)
	  (ret.push (i.clone t)))))
