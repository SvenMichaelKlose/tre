; tré – Copyright (c) 2007,2011–2014 Sven Michael Klose <pixel@copei.de>

(functional copy-head group)

(defun copy-head (x size)
  (? (& x (< 0 size))
     (. x. (copy-head .x (-- size)))))

(defun group (x size)
  (& x
     (. (copy-head x size)
        (group (nthcdr size x) size))))
