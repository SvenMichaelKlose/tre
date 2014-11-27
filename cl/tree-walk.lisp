;;;;; tré – Copyright (c) 2005–2007,2012–2014 Sven Michael Klose <pixel@copei.de>

(defun tree-walk (i &key (ascending nil) (dont-ascend-if nil) (dont-ascend-after-if nil))
  (? (atom i)
	 (funcall ascending i)
	 (let* ((y (car i))
            (a (or (and dont-ascend-if (funcall dont-ascend-if y) y)
                   (? (and dont-ascend-after-if (funcall dont-ascend-after-if y))
                      (funcall ascending y)
                      (tree-walk (? ascending
                                    (funcall ascending y)
                                    y)
                                 :ascending ascending
                                 :dont-ascend-if dont-ascend-if
                                 :dont-ascend-after-if dont-ascend-after-if)))))
       (cons a (tree-walk (cdr i) :ascending ascending
                                  :dont-ascend-if dont-ascend-if
                                  :dont-ascend-after-if dont-ascend-after-if)))))
