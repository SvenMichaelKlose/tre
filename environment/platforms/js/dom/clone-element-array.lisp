;;;;; tré – Copyright (c) 2008–2010,2013 Sven Michael Klose <pixel@copei.de>

(defun clone-element-array (x)
  (let ret (make-array)
    (doarray (i x ret)
	  (ret.push (i.clone t)))))
