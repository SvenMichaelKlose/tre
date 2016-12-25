(functional copy-head group)

(defun copy-head (x size)
  (? (& x (< 0 size))
     (. x. (copy-head .x (-- size)))))

(defun group (x size)
  (& x
     (. (copy-head x size)
        (group (nthcdr size x) size))))
